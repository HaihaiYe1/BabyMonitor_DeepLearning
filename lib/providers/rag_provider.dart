import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rag_service.dart';

// RAG服务提供者
final ragServiceProvider = Provider<RagService>((ref) {
  return RagService();
});

// 育儿建议状态
class AdviceState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? adviceResult;
  final List<Map<String, dynamic>> searchResults;

  AdviceState({
    this.isLoading = false,
    this.error,
    this.adviceResult,
    this.searchResults = const [],
  });

  AdviceState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? adviceResult,
    List<Map<String, dynamic>>? searchResults,
  }) {
    return AdviceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      adviceResult: adviceResult ?? this.adviceResult,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}

// 育儿建议状态管理
class AdviceNotifier extends StateNotifier<AdviceState> {
  final RagService _ragService;

  AdviceNotifier(this._ragService) : super(AdviceState());

  Future<void> getAdvice({
    required String situation,
    int? babyAgeMonths,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _ragService.getAdvice(
        situation: situation,
        babyAgeMonths: babyAgeMonths,
      );
      
      state = state.copyWith(
        isLoading: false,
        adviceResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getEmergencyAdvice({
    required String emergencyType,
    required String details,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _ragService.getEmergencyAdvice(
        emergencyType: emergencyType,
        details: details,
      );
      
      state = state.copyWith(
        isLoading: false,
        adviceResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchKnowledge({
    required String query,
    String? category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _ragService.searchKnowledge(
        query: query,
        category: category,
      );
      
      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          searchResults: List<Map<String, dynamic>>.from(
            result['results'] ?? [],
          ),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? '搜索失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearResults() {
    state = state.copyWith(
      adviceResult: null,
      searchResults: [],
    );
  }
}

// 育儿建议状态提供者
final adviceProvider = StateNotifierProvider<AdviceNotifier, AdviceState>((ref) {
  final ragService = ref.watch(ragServiceProvider);
  return AdviceNotifier(ragService);
});
