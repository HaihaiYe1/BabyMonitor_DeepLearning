import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class FaqPage extends ConsumerStatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends ConsumerState<FaqPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  WebSocketChannel? _channel;
  bool _isLoading = false;

  final String appId = "59944ba0";
  final String apiKey = "b6a6e9b81e99352a3fa23b768cb05bc6";
  final String apiSecret = "NGUzMDY1OWE4NzNiYmRlZWViYTliZWQ0";

  final ScrollController _scrollController = ScrollController();

  String _selectedModel = "4.0Ultra";
  final Map<String, String> _modelEndpoints = {
    "4.0Ultra": "wss://spark-api.xf-yun.com/v4.0/chat",
    "lite": "wss://spark-api.xf-yun.com/v1.1/chat",
  };

  final List<String> _suggestedQuestions = [
    "When should a baby start solid foods?",
    "How to establish a sleep routine?",
    "What are signs of teething?",
  ];

  @override
  void dispose() {
    _controller.dispose();
    _channel?.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add({"role": "user", "content": text});
    });

    _controller.clear();

    final sparkUrl = _modelEndpoints[_selectedModel]!;
    String authUrl = _buildAuthUrl(sparkUrl);

    _channel = WebSocketChannel.connect(Uri.parse(authUrl));

    final requestPayload = json.encode({
      "header": {
        "app_id": appId,
        "uid": "user_${Random().nextInt(99999)}"
      },
      "parameter": {
        "chat": {
          "domain": _selectedModel,
          "temperature": 0.5,
          "max_tokens": 1024
        }
      },
      "payload": {
        "message": {
          "text": [
            {"role": "user", "content": text}
          ]
        }
      }
    });

    _channel!.sink.add(requestPayload);

    StringBuffer responseBuffer = StringBuffer();

    _channel!.stream.listen((event) {
      final data = json.decode(event);
      final choices = data['payload']?['choices']?['text'];
      if (choices != null && choices.isNotEmpty) {
        responseBuffer.write(choices[0]['content']);
      }

      if (data['header']['status'] == 2) {
        setState(() {
          _messages.add({"role": "assistant", "content": responseBuffer.toString()});
          _isLoading = false;
        });
        _channel?.sink.close();
        _scrollToBottom();
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  String _buildAuthUrl(String sparkUrl) {
    final date = HttpDate.format(DateTime.now().toUtc());

    final path = Uri.parse(sparkUrl).path;
    final signatureOrigin = "host: spark-api.xf-yun.com\ndate: $date\nGET $path HTTP/1.1";
    final signatureSha = Hmac(sha256, utf8.encode(apiSecret)).convert(utf8.encode(signatureOrigin));
    final signature = base64.encode(signatureSha.bytes);

    final authorizationOrigin =
        'api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signature"';
    final authorization = base64.encode(utf8.encode(authorizationOrigin));

    return "$sparkUrl?authorization=$authorization&date=${Uri.encodeComponent(date)}&host=spark-api.xf-yun.com";
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
              color: SereneColors.primary,
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'FAQ Bot',
              style: SereneTypography.headlineSmall.copyWith(
                color: SereneColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            // 模型选择器
            GestureDetector(
              onTap: _showModelSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SereneColors.surfaceContainerLow,
                  borderRadius: SereneSpacing.chipRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedModel == "4.0Ultra" ? "Pro-Logic Model" : "Fast-Response",
                      style: SereneTypography.labelMedium.copyWith(
                        color: SereneColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 16,
                      color: SereneColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: SereneIconButton(
              icon: Icons.more_vert,
              iconColor: SereneColors.primary,
              size: 40,
              tooltip: 'More options',
              onPressed: () {
                // TODO: 显示更多选项
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
                // 聊天消息列表
                Expanded(
                  child: _messages.isEmpty
                      ? _buildWelcomeMessage()
                      : _buildChatMessages(),
                ),
                // 加载指示器
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(SereneSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SereneColors.primary,
                          ),
                        ),
                        const SizedBox(width: SereneSpacing.sm),
                        Text(
                          'Thinking...',
                          style: SereneTypography.bodySmall.copyWith(
                            color: SereneColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                // 输入区域
                _buildInputArea(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示模型选择器
  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: SereneColors.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SereneSpacing.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: SereneSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SereneColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SereneSpacing.lg),
              child: Text(
                'Select Model',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
            ),
            _buildModelOption(
              title: 'Pro-Logic Model',
              subtitle: 'Detailed, evidence-based answers',
              value: '4.0Ultra',
            ),
            _buildModelOption(
              title: 'Fast-Response',
              subtitle: 'Quick answers for simple questions',
              value: 'lite',
            ),
            const SizedBox(height: SereneSpacing.lg),
          ],
        ),
      ),
    );
  }

  /// 构建模型选项
  Widget _buildModelOption({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedModel == value;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? SereneColors.primaryContainer
              : SereneColors.surfaceContainerHigh,
        ),
        child: Icon(
          Icons.smart_toy_outlined,
          color: isSelected
              ? SereneColors.onPrimaryContainer
              : SereneColors.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: SereneTypography.labelLarge.copyWith(
          color: SereneColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: SereneTypography.bodySmall.copyWith(
          color: SereneColors.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: SereneColors.primary,
            )
          : null,
      onTap: () {
        setState(() {
          _selectedModel = value;
        });
        Navigator.pop(context);
      },
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
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 32,
              color: SereneColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          Text(
            'How can I help you today?',
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            'Ask me anything about feeding, sleep, or care.',
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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
        final isUser = message["role"] == "user";
        return _buildMessageBubble(
          content: message["content"] ?? '',
          isUser: isUser,
        );
      },
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble({
    required String content,
    required bool isUser,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: SereneSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: isUser
            ? _buildUserMessage(content)
            : _buildBotMessage(content),
      ),
    );
  }

  /// 构建用户消息
  Widget _buildUserMessage(String content) {
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
      ),
      child: Text(
        content,
        style: SereneTypography.bodyMedium.copyWith(
          color: SereneColors.onPrimary,
        ),
      ),
    );
  }

  /// 构建AI消息
  Widget _buildBotMessage(String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Expanded(
          child: GlassPanel(
            padding: const EdgeInsets.all(SereneSpacing.md),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(SereneSpacing.radiusXl),
              topRight: Radius.circular(SereneSpacing.radiusXl),
              bottomLeft: Radius.circular(SereneSpacing.radiusSm),
              bottomRight: Radius.circular(SereneSpacing.radiusXl),
            ),
            child: Text(
              content,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SereneSpacing.marginMobile,
        SereneSpacing.sm,
        SereneSpacing.marginMobile,
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
      child: Column(
        children: [
          // 建议问题
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedQuestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: SereneSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      _controller.text = _suggestedQuestions[index];
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SereneSpacing.md,
                        vertical: SereneSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: SereneColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(SereneSpacing.radiusMd),
                        border: Border.all(
                          color: SereneColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _suggestedQuestions[index],
                        style: SereneTypography.labelMedium.copyWith(
                          color: SereneColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: SereneSpacing.sm),
          // 输入框
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
              border: Border.all(
                color: SereneColors.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    style: SereneTypography.bodyMedium.copyWith(
                      color: SereneColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      hintStyle: SereneTypography.bodyMedium.copyWith(
                        color: SereneColors.onSurfaceVariant.withValues(alpha: 0.5),
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
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SereneColors.primary,
                      ),
                      child: const Icon(
                        Icons.send,
                        size: 18,
                        color: SereneColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 免责声明
          const SizedBox(height: SereneSpacing.xs),
          Text(
            'AI can make mistakes. Verify critical care info.',
            style: SereneTypography.labelMedium.copyWith(
              color: SereneColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
