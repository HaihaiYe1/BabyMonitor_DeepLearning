import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
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

  /// 删除设备并同步到后端
  Future<bool> deleteDevice(int deviceId) async {
    try {
      final success = await repository.deleteDevice(deviceId);
      if (success) {
        state = state.where((device) => device.id != deviceId.toString()).toList();
      }
      return success;
    } catch (e) {
      print('删除设备失败: $e');
      return false;
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

  /// 添加新设备到后端
  Future<Map<String, dynamic>> addDevice({
    required String name,
    required String ip,
    String status = 'offline',
  }) async {
    try {
      final response = await _dio.post(
        '/add',
        data: {
          'name': name,
          'ip': ip,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('添加设备失败: ${response.statusCode}');
      }
    } catch (e) {
      print("添加设备请求失败: $e");
      throw Exception("添加设备失败");
    }
  }

  /// 获取第一个设备的RTSP地址
  Future<String?> getRtspUrl() async {
    try {
      final response = await _dio.get('/get_rtsp_url');

      if (response.statusCode == 200) {
        return response.data['rtspUrl'];
      } else {
        throw Exception('获取RTSP地址失败: ${response.statusCode}');
      }
    } catch (e) {
      print("获取RTSP地址请求失败: $e");
      return null;
    }
  }

  /// 删除设备
  Future<bool> deleteDevice(int deviceId) async {
    try {
      final response = await _dio.delete(
        '/delete',
        queryParameters: {'device_id': deviceId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('删除设备失败: ${response.statusCode}');
      }
    } catch (e) {
      print("删除设备请求失败: $e");
      return false;
    }
  }

  /// 获取指定设备详情
  Future<Device?> getDeviceById(int deviceId) async {
    try {
      final response = await _dio.get('/$deviceId');

      if (response.statusCode == 200) {
        return Device.fromJson(response.data);
      } else {
        throw Exception('获取设备详情失败: ${response.statusCode}');
      }
    } catch (e) {
      print("获取设备详情请求失败: $e");
      return null;
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
