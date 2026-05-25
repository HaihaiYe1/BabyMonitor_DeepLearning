import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/agent_service.dart';

// Agent服务提供者
final agentServiceProvider = Provider<AgentService>((ref) {
  return AgentService();
});

// Agent状态
class AgentState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final List<ChatMessage> messages;
  final Map<String, dynamic>? status;

  AgentState({
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.status,
  });

  AgentState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    List<ChatMessage>? messages,
    Map<String, dynamic>? status,
  }) {
    return AgentState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }
}

// 聊天消息
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

// Agent状态管理
class AgentNotifier extends StateNotifier<AgentState> {
  final AgentService _agentService;

  AgentNotifier(this._agentService) : super(AgentState());

  Future<void> checkStatus() async {
    try {
      final result = await _agentService.getAgentStatus();
      state = state.copyWith(
        isInitialized: result['success'] == true,
        status: result,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> initialize({bool useAgentMode = true}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _agentService.initializeAgent(
        useAgentMode: useAgentMode,
      );
      
      if (result['success'] == true) {
        state = state.copyWith(
          isInitialized: true,
          isLoading: false,
          messages: [
            ...state.messages,
            ChatMessage(
              text: 'Agent已初始化，可以开始对话了！',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? '初始化失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 添加用户消息
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: true,
    );

    try {
      final result = await _agentService.chatWithAgent(message);
      
      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          messages: [
            ...state.messages,
            ChatMessage(
              text: result['agent_response'] ?? '无响应',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          messages: [
            ...state.messages,
            ChatMessage(
              text: '发送失败: ${result['error']}',
              isUser: false,
              timestamp: DateTime.now(),
              isError: true,
            ),
          ],
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        messages: [
          ...state.messages,
          ChatMessage(
            text: '发送异常: $e',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        ],
      );
    }
  }

  Future<void> resetMemory() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _agentService.resetAgentMemory();
      state = state.copyWith(
        isLoading: false,
        messages: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }
}

// Agent状态提供者
final agentProvider = StateNotifierProvider<AgentNotifier, AgentState>((ref) {
  final agentService = ref.watch(agentServiceProvider);
  return AgentNotifier(agentService);
});
