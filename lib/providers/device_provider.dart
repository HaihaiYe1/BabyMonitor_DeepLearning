import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:my_first_app/services/api_service.dart';
import '../models/device_model.dart';

/// 设备数据仓库 Provider
final deviceRepositoryProvider = Provider((ref) => DeviceRepository());

/// 设备状态管理 Notifier
class CameraNotifier extends StateNotifier<List<Device>> {
  final DeviceRepository repository;

  CameraNotifier(this.repository) : super([]);


  /// 根据 JWT Token 获取设备列表
  Future<void> fetchDevicesByToken(String token) async {
    try {
      final devices = await repository.getDevicesByToken(token);
      state = devices;
    } catch (e) {
      print('通过 Token 获取设备失败: $e');
    }
  }

  /// 添加设备（前端状态更新，不影响后端）
  void addDevice(Device device) {
    state = [...state, device];
  }


  /// 更新设备信息并同步到后端
  Future<void> updateDevice(Device updatedDevice) async {
    try {
      await repository.updateDevice(updatedDevice);
      state = state.map((device) => device.id == updatedDevice.id ? updatedDevice : device).toList();
    } catch (e) {
      print('更新设备失败: $e');
    }
  }
}

/// 设备管理 Provider（绑定 `CameraNotifier`）
final cameraProvider = StateNotifierProvider<CameraNotifier, List<Device>>((ref) {
  final repository = ref.read(deviceRepositoryProvider);
  return CameraNotifier(repository);
});

/// 设备数据请求类
class DeviceRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiService.deviceBase));

  /// 根据 email 获取设备列表
  Future<List<Device>> getDevicesByEmail(String email) async {
    try {
      final response = await _dio.get('/list', queryParameters: {'email': email});
      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List).map((e) => Device.fromJson(e)).toList();
        } else {
          throw Exception('设备数据格式错误');
        }
      } else {
        throw Exception('后端返回错误代码: ${response.statusCode}');
      }
    } catch (e) {
      print("请求设备数据失败: $e");
      throw Exception("设备数据加载失败");
    }
  }

  /// 根据 JWT Token 获取设备列表
  Future<List<Device>> getDevicesByToken(String token) async {
    try {
      final response = await _dio.get(
        '/list',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List).map((e) => Device.fromJson(e)).toList();
        } else {
          throw Exception('设备数据格式错误');
        }
      } else {
        throw Exception('后端返回错误代码: ${response.statusCode}');
      }
    } catch (e) {
      print("通过 Token 请求设备数据失败: $e");
      throw Exception("设备数据加载失败");
    }
  }

  /// 更新设备信息到后端
  Future<void> updateDevice(Device device) async {
    try {
      final response = await _dio.put('/update', data: {
        'id': device.id,
        'name': device.name,
        'ip': device.ip,
        'status': device.status,
        'rtsp_url': device.rtspUrl, // 确保字段名匹配后端
        'email': device.email,
      });

      if (response.statusCode != 200) {
        throw Exception('设备更新失败: ${response.statusCode}');
      }
    } catch (e) {
      print("更新设备请求失败: $e");
      throw Exception("设备更新失败");
    }
  }
}
