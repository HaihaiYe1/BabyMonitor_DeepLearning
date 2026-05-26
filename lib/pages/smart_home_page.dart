import 'package:flutter/material.dart';
import '../services/smart_home_service.dart';
import '../generated/l10n.dart';

class SmartHomePage extends StatefulWidget {
  const SmartHomePage({Key? key}) : super(key: key);

  @override
  _SmartHomePageState createState() => _SmartHomePageState();
}

class _SmartHomePageState extends State<SmartHomePage> {
  final SmartHomeService _smartHomeService = SmartHomeService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _systemStatus;
  Map<String, dynamic>? _availableScenes;
  
  // 音箱控制
  String _selectedSpeakerContent = 'whitenoise';
  int _speakerVolume = 50;
  int _speakerDuration = 30;
  
  // 灯光控制
  int _lightBrightness = 100;
  String _selectedLightColor = 'warm';
  String _selectedLightMode = 'normal';
  
  final List<Map<String, dynamic>> _speakerContents = [
    {'value': 'whitenoise', 'name': '白噪音', 'icon': Icons.noise_aware},
    {'value': 'lullaby', 'name': '摇篮曲', 'icon': Icons.music_note},
    {'value': 'ocean', 'name': '海浪声', 'icon': Icons.waves},
    {'value': 'rain', 'name': '雨声', 'icon': Icons.water_drop},
    {'value': 'heartbeat', 'name': '心跳声', 'icon': Icons.favorite},
    {'value': 'bird', 'name': '鸟鸣声', 'icon': Icons.flutter_dash},
  ];
  
  final List<Map<String, dynamic>> _lightColors = [
    {'value': 'warm', 'name': '暖光', 'color': Colors.orange},
    {'value': 'cool', 'name': '冷光', 'color': Colors.blue},
    {'value': 'night', 'name': '夜灯', 'color': Colors.amber},
    {'value': 'soft', 'name': '柔光', 'color': Colors.yellow},
  ];
  
  final List<Map<String, dynamic>> _lightModes = [
    {'value': 'normal', 'name': '普通模式', 'icon': Icons.light_mode},
    {'value': 'night', 'name': '夜灯模式', 'icon': Icons.nightlight},
    {'value': 'reading', 'name': '阅读模式', 'icon': Icons.menu_book},
    {'value': 'sleep', 'name': '睡眠模式', 'icon': Icons.bedtime},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statusResult = await _smartHomeService.getSmartHomeStatus();
      final scenesResult = await _smartHomeService.getAvailableScenes();
      
      setState(() {
        _systemStatus = statusResult;
        _availableScenes = scenesResult;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载数据失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _controlSpeaker(String action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _smartHomeService.controlSpeaker(
        action: action,
        content: action == 'play' ? _selectedSpeakerContent : null,
        volume: action == 'set_volume' ? _speakerVolume : null,
        duration: action == 'play' ? _speakerDuration : null,
      );

      _showResultSnackBar(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('音箱控制失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _controlLight(String action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _smartHomeService.controlLight(
        action: action,
        brightness: action == 'dim' ? _lightBrightness : null,
        color: action == 'color' ? _selectedLightColor : null,
        mode: action == 'mode' ? _selectedLightMode : null,
      );

      _showResultSnackBar(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('灯光控制失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _activateScene(String scene) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _smartHomeService.activateScene(scene: scene);
      _showResultSnackBar(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('场景激活失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _quickAction(String action) async {
    setState(() {
      _isLoading = true;
    });

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

      _showResultSnackBar(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('快捷操作失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResultSnackBar(Map<String, dynamic> result) {
    final success = result['success'] == true;
    final  message;
    if (success) {
      message = result['result']?['message'] ?? '操作成功'
        : result['error'] ?? '操作失败';
    } else {
      message = "null";
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).smart_home ?? '智能家居控制'),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新状态',
          ),
        ],
      ),
      body: _isLoading && _systemStatus == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildSceneSection(),
                    const SizedBox(height: 24),
                    _buildSpeakerSection(),
                    const SizedBox(height: 24),
                    _buildLightSection(),
                    const SizedBox(height: 24),
                    _buildSystemStatus(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  '快捷操作',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickButton(
                    '睡眠模式',
                    Icons.bedtime,
                    Colors.indigo,
                    () => _quickAction('sleep'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickButton(
                    '安抚模式',
                    Icons.child_care,
                    Colors.pink,
                    () => _quickAction('comfort'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickButton(
                    '警报模式',
                    Icons.warning,
                    Colors.red,
                    () => _quickAction('alert'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneSection() {
    final scenes = _availableScenes?['scenes'] as Map<String, dynamic>? ?? {};
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.scene, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  '场景模式',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scenes.entries.map((entry) {
                final sceneName = entry.key;
                final sceneInfo = entry.value as Map<String, dynamic>;
                return ActionChip(
                  avatar: Icon(
                    _getSceneIcon(sceneName),
                    size: 18,
                    color: _getSceneColor(sceneName),
                  ),
                  label: Text(sceneInfo['name'] ?? sceneName),
                  onPressed: _isLoading ? null : () => _activateScene(sceneName),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSceneIcon(String scene) {
    switch (scene) {
      case 'sleep': return Icons.bedtime;
      case 'wake': return Icons.wb_sunny;
      case 'comfort': return Icons.child_care;
      case 'alert': return Icons.warning;
      case 'calm': return Icons.spa;
      default: return Icons.scene;
    }
  }

  Color _getSceneColor(String scene) {
    switch (scene) {
      case 'sleep': return Colors.indigo;
      case 'wake': return Colors.orange;
      case 'comfort': return Colors.pink;
      case 'alert': return Colors.red;
      case 'calm': return Colors.teal;
      default: return Colors.grey;
    }
  }

  Widget _buildSpeakerSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speaker, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '智能音箱',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 内容选择
            Text(
              '播放内容',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _speakerContents.map((content) {
                return ChoiceChip(
                  avatar: Icon(
                    content['icon'],
                    size: 18,
                    color: _selectedSpeakerContent == content['value']
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                  label: Text(content['name']),
                  selected: _selectedSpeakerContent == content['value'],
                  selectedColor: Colors.blue,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSpeakerContent = content['value'];
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 音量控制
            Row(
              children: [
                Text(
                  '音量: $_speakerVolume',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _speakerVolume.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _speakerVolume = value.round();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _controlSpeaker('play'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('播放'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _controlSpeaker('stop'),
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow[700]),
                const SizedBox(width: 8),
                Text(
                  '智能灯光',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 颜色选择
            Text(
              '灯光颜色',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _lightColors.map((colorInfo) {
                return ChoiceChip(
                  avatar: CircleAvatar(
                    backgroundColor: colorInfo['color'],
                    radius: 10,
                  ),
                  label: Text(colorInfo['name']),
                  selected: _selectedLightColor == colorInfo['value'],
                  selectedColor: colorInfo['color'].withOpacity(0.3),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLightColor = colorInfo['value'];
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 模式选择
            Text(
              '灯光模式',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _lightModes.map((mode) {
                return ChoiceChip(
                  avatar: Icon(
                    mode['icon'],
                    size: 18,
                    color: _selectedLightMode == mode['value']
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                  label: Text(mode['name']),
                  selected: _selectedLightMode == mode['value'],
                  selectedColor: Colors.yellow[700],
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLightMode = mode['value'];
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 亮度控制
            Row(
              children: [
                Text(
                  '亮度: $_lightBrightness',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _lightBrightness.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _lightBrightness = value.round();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _controlLight('on'),
                    icon: const Icon(Icons.light_mode),
                    label: const Text('开灯'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _controlLight('off'),
                    icon: const Icon(Icons.light_mode_outlined),
                    label: const Text('关灯'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _controlLight('mode'),
                    icon: const Icon(Icons.settings),
                    label: const Text('应用'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    final mqtt = _systemStatus?['mqtt'] as Map<String, dynamic>? ?? {};
    final tools = _systemStatus?['tools'] as Map<String, dynamic>? ?? {};
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  '系统状态',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow('MQTT连接', mqtt['connected'] == true ? '已连接' : '未连接'),
            _buildStatusRow('MQTT地址', '${mqtt['broker_host'] ?? 'N/A'}:${mqtt['broker_port'] ?? 'N/A'}'),
            _buildStatusRow('音箱工具', tools['speaker'] ?? 'N/A'),
            _buildStatusRow('灯光工具', tools['light'] ?? 'N/A'),
            _buildStatusRow('场景工具', tools['scene'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
