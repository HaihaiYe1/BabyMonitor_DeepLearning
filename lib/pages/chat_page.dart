import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/agent_service.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AgentService _agentService = AgentService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isAgentReady = false;
  String _agentStatus = '未初始化';

  @override
  void initState() {
    super.initState();
    _checkAgentStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAgentStatus() async {
    try {
      final result = await _agentService.getAgentStatus();
      if (result['success'] == true) {
        setState(() {
          _isAgentReady = true;
          _agentStatus = '已就绪';
        });
      } else {
        setState(() {
          _agentStatus = '未初始化';
        });
      }
    } catch (e) {
      setState(() {
        _agentStatus = '检查失败';
      });
    }
  }

  Future<void> _initializeAgent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _agentService.initializeAgent();
      if (result['success'] == true) {
        setState(() {
          _isAgentReady = true;
          _agentStatus = '已就绪';
        });
        _addMessage(ChatMessage(
          text: 'Agent已初始化，可以开始对话了！',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        _addMessage(ChatMessage(
          text: '初始化失败: ${result['error']}',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      }
    } catch (e) {
      _addMessage(ChatMessage(
        text: '初始化异常: $e',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addMessage(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _agentService.chatWithAgent(message);
      if (result['success'] == true) {
        _addMessage(ChatMessage(
          text: result['agent_response'] ?? '无响应',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        _addMessage(ChatMessage(
          text: '发送失败: ${result['error']}',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      }
    } catch (e) {
      _addMessage(ChatMessage(
        text: '发送异常: $e',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: SereneColors.surface,
      appBar: GlassAppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back,
              color: SereneColors.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          'AI Assistant',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: SereneIconButton(
              icon: Icons.delete_sweep_outlined,
              iconColor: SereneColors.onSurfaceVariant,
              size: 40,
              tooltip: 'Clear chat',
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景色
            Container(
              color: SereneColors.surface,
            ),
            // 聊天内容
            Column(
              children: [
                // 消息列表
                Expanded(
                  child: _messages.isEmpty
                      ? _buildWelcomeMessage()
                      : _buildChatMessages(),
                ),
                // 加载指示器
                if (_isLoading) _buildTypingIndicator(),
                // 输入区域
                _buildInputArea(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建欢迎消息
  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SereneColors.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: SereneColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 32,
              color: SereneColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          Text(
            'BabyApp Assistant',
            style: SereneTypography.labelLarge.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SereneSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SereneSpacing.xl),
            child: Text(
              'I can help you analyze sleep patterns, suggest feeding schedules, or answer general questions.',
              style: SereneTypography.bodySmall.copyWith(
                color: SereneColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建聊天消息列表
  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.md,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: SereneSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            message.isUser
                ? _buildUserMessage(message)
                : _buildBotMessage(message),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: SereneTypography.labelMedium.copyWith(
                color: SereneColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户消息
  Widget _buildUserMessage(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(SereneSpacing.md),
      decoration: BoxDecoration(
        color: SereneColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(SereneSpacing.radiusXl),
          topRight: const Radius.circular(SereneSpacing.radiusXl),
          bottomLeft: const Radius.circular(SereneSpacing.radiusXl),
          bottomRight: const Radius.circular(SereneSpacing.radiusSm),
        ),
        boxShadow: [
          BoxShadow(
            color: SereneColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: SereneTypography.bodyMedium.copyWith(
          color: SereneColors.onPrimary,
        ),
      ),
    );
  }

  /// 构建AI消息
  Widget _buildBotMessage(ChatMessage message) {
    return GlassPanel(
      padding: const EdgeInsets.all(SereneSpacing.md),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(SereneSpacing.radiusXl),
        topRight: Radius.circular(SereneSpacing.radiusXl),
        bottomLeft: Radius.circular(SereneSpacing.radiusSm),
        bottomRight: Radius.circular(SereneSpacing.radiusXl),
      ),
      child: Text(
        message.text,
        style: SereneTypography.bodyMedium.copyWith(
          color: message.isError ? SereneColors.error : SereneColors.onSurface,
        ),
      ),
    );
  }

  /// 构建打字指示器
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SereneColors.surfaceVariant,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: SereneSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SereneSpacing.md,
              vertical: SereneSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: SereneColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建打字指示器的圆点
  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SereneColors.outline.withValues(alpha: 0.5),
      ),
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SereneSpacing.sm,
        SereneSpacing.sm,
        SereneSpacing.sm,
        SereneSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        color: SereneColors.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: SereneColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 添加按钮
          SereneIconButton(
            icon: Icons.add_circle_outline,
            iconColor: SereneColors.primary,
            size: 40,
            tooltip: 'Add attachment',
            onPressed: () {
              // TODO: 添加附件
            },
          ),
          const SizedBox(width: SereneSpacing.sm),
          // 输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: SereneColors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                border: Border.all(
                  color: SereneColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      style: SereneTypography.bodyMedium.copyWith(
                        color: SereneColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: SereneTypography.bodyMedium.copyWith(
                          color: SereneColors.outline,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SereneSpacing.md,
                          vertical: SereneSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: SereneSpacing.sm),
                    child: GestureDetector(
                      onTap: _isLoading ? null : _sendMessage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SereneColors.primary,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          size: 18,
                          color: SereneColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: SereneSpacing.sm),
          // 麦克风按钮
          SereneIconButton(
            icon: Icons.mic_outlined,
            iconColor: SereneColors.onSurfaceVariant,
            size: 40,
            tooltip: 'Voice input',
            onPressed: () {
              // TODO: 语音输入
            },
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
