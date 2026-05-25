import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/smart_home_service.dart';

// 智能家居服务提供者
final smartHomeServiceProvider = Provider<SmartHomeService>((ref) {
  return SmartHomeService();
});

// 智能家居状态
class SmartHomeState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? systemStatus;
  final Map<String, dynamic>? availableScenes;
  final String selectedSpeakerContent;
  final int speakerVolume;
  final int lightBrightness;
  final String selectedLightColor;
  final String selectedLightMode;

  SmartHomeState({
    this.isLoading = false,
    this.error,
    this.systemStatus,
    this.availableScenes,
    this.selectedSpeakerContent = 'whitenoise',
    this.speakerVolume = 50,
    this.lightBrightness = 100,
    this.selectedLightColor = 'warm',
    this.selectedLightMode = 'normal',
  });

  SmartHomeState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? systemStatus,
    Map<String, dynamic>? availableScenes,
    String? selectedSpeakerContent,
    int? speakerVolume,
    int? lightBrightness,
    String? selectedLightColor,
    String? selectedLightMode,
  }) {
    return SmartHomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      systemStatus: systemStatus ?? this.systemStatus,
      availableScenes: availableScenes ?? this.availableScenes,
      selectedSpeakerContent: selectedSpeakerContent ?? this.selectedSpeakerContent,
      speakerVolume: speakerVolume ?? this.speakerVolume,
      lightBrightness: lightBrightness ?? this.lightBrightness,
      selectedLightColor: selectedLightColor ?? this.selectedLightColor,
      selectedLightMode: selectedLightMode ?? this.selectedLightMode,
    );
  }
}

// 智能家居状态管理
class SmartHomeNotifier extends StateNotifier<SmartHomeState> {
  final SmartHomeService _smartHomeService;

  SmartHomeNotifier(this._smartHomeService) : super(SmartHomeState());

  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final statusResult = await _smartHomeService.getSmartHomeStatus();
      final scenesResult = await _smartHomeService.getAvailableScenes();
      
      state = state.copyWith(
        isLoading: false,
        systemStatus: statusResult,
        availableScenes: scenesResult,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> controlSpeaker({
    required String action,
    String? content,
    int? volume,
    int? duration,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _smartHomeService.controlSpeaker(
        action: action,
        content: content ?? state.selectedSpeakerContent,
        volume: volume ?? state.speakerVolume,
        duration: duration,
      );
      
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> controlLight({
    required String action,
    int? brightness,
    String? color,
    String? mode,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _smartHomeService.controlLight(
        action: action,
        brightness: brightness ?? state.lightBrightness,
        color: color ?? state.selectedLightColor,
        mode: mode ?? state.selectedLightMode,
      );
      
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> activateScene(String scene) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _smartHomeService.activateScene(scene: scene);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> quickAction(String action) async {
    state = state.copyWith(isLoading: true);
    
    try {
      Map<String, dynamic> result;
      switch (action) {
        case 'sleep':
          result = await _smartHomeService.quickSleepMode();
          break;
        case 'comfort':
          result = await _smartHomeService.quickComfortMode();
          break;
        case 'alert':
          result = await _smartHomeService.quickAlertMode();
          break;
        default:
          result = {'success': false, 'error': '未知操作'};
      }
      
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  void updateSpeakerContent(String content) {
    state = state.copyWith(selectedSpeakerContent: content);
  }

  void updateSpeakerVolume(int volume) {
    state = state.copyWith(speakerVolume: volume);
  }

  void updateLightBrightness(int brightness) {
    state = state.copyWith(lightBrightness: brightness);
  }

  void updateLightColor(String color) {
    state = state.copyWith(selectedLightColor: color);
  }

  void updateLightMode(String mode) {
    state = state.copyWith(selectedLightMode: mode);
  }
}

// 智能家居状态提供者
final smartHomeProvider = StateNotifierProvider<SmartHomeNotifier, SmartHomeState>((ref) {
  final smartHomeService = ref.watch(smartHomeServiceProvider);
  return SmartHomeNotifier(smartHomeService);
});
