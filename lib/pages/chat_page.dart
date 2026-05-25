import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/agent_service.dart';
import '../generated/l10n.dart';

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
      appBar: AppBar(
        title: Text(S.of(context).agent_chat ?? 'AI Agent对话'),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAgentStatus,
            tooltip: '刷新状态',
          ),
          if (!_isAgentReady)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _initializeAgent,
              tooltip: '初始化Agent',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Agent状态栏
            _buildStatusBar(),
            // 消息列表
            Expanded(child: _buildMessageList()),
            // 输入框
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAgentReady ? Icons.check_circle : Icons.warning,
            color: _isAgentReady ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Agent状态: $_agentStatus',
            style: TextStyle(
              color: _isAgentReady ? Colors.green[700] : Colors.orange[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '开始与AI Agent对话',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '可以询问育儿问题或请求帮助',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.blue[100]
              : message.isError
                  ? Colors.red[100]
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isError ? Colors.red[700] : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _sendMessage,
            ),
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
