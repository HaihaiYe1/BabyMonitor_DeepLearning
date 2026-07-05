import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final Map<String, String> audioFiles;
  late final Map<String, IconData> audioIcons;
  late final Map<String, String> localizedLabels;

  String? _playingAudio;
  bool _isLooping = false;
  double _volume = 0.65;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final s = S.of(context);
    audioFiles = {
      s.soundFetal: "lib/assets/audios/fetal_environment.mp3",
      s.soundShhh: "lib/assets/audios/shhh.mp3",
      s.soundVacuum: "lib/assets/audios/vacuum_cleaner.mp3",
      s.soundCar: "lib/assets/audios/car_sound.mp3",
      s.soundFan: "lib/assets/audios/fan.mp3",
      s.soundStream: "lib/assets/audios/stream.mp3",
      s.soundRain: "lib/assets/audios/rain.mp3",
      s.soundMarket: "lib/assets/audios/market.mp3",
      s.soundOcean: "lib/assets/audios/ocean.mp3",
      s.soundPond: "lib/assets/audios/pond.mp3",
      s.soundBeach: "lib/assets/audios/beach.mp3",
      s.soundOceanWaves: "lib/assets/audios/ocean_waves.mp3",
      s.soundHeartbeat: "lib/assets/audios/mothers_heartbeat.mp3",
      s.soundLullaby: "lib/assets/audios/lullaby.mp3",
      s.soundBird: "lib/assets/audios/bird_chirping.mp3",
      s.soundCat: "lib/assets/audios/cat_meowing.mp3",
    };

    audioIcons = {
      s.soundFetal: Icons.cloud_outlined,
      s.soundShhh: Icons.volume_up_outlined,
      s.soundVacuum: Icons.cleaning_services_outlined,
      s.soundCar: Icons.directions_car_outlined,
      s.soundFan: Icons.air_outlined,
      s.soundStream: Icons.water_outlined,
      s.soundRain: Icons.water_drop_outlined,
      s.soundMarket: Icons.store_outlined,
      s.soundOcean: Icons.waves_outlined,
      s.soundPond: Icons.pool_outlined,
      s.soundBeach: Icons.beach_access_outlined,
      s.soundOceanWaves: Icons.tsunami_outlined,
      s.soundHeartbeat: Icons.favorite_outlined,
      s.soundLullaby: Icons.bed_outlined,
      s.soundBird: Icons.flutter_dash_outlined,
      s.soundCat: Icons.pets_outlined,
    };

    localizedLabels = Map.from(audioFiles);
  }

  void _playAudio(String label) async {
    String? audioPath = audioFiles[label];
    if (audioPath != null) {
      if (_playingAudio == label) {
        if (_isLooping) {
          await _audioPlayer.setLoopMode(LoopMode.off);
          setState(() => _isLooping = false);
        } else {
          await _audioPlayer.stop();
          setState(() => _playingAudio = null);
        }
      } else {
        await _audioPlayer.setAsset(audioPath);
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play();
        setState(() {
          _playingAudio = label;
          _isLooping = false;
        });
      }
    }
  }

  void _longPressAudio(String label) async {
    String? audioPath = audioFiles[label];
    if (audioPath != null) {
      await _audioPlayer.setAsset(audioPath);
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play();
      setState(() {
        _playingAudio = label;
        _isLooping = true;
      });
    }
  }

  void _toggleLoop() async {
    if (_isLooping) {
      await _audioPlayer.setLoopMode(LoopMode.off);
    } else {
      await _audioPlayer.setLoopMode(LoopMode.all);
    }
    setState(() => _isLooping = !_isLooping);
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _playingAudio = null;
      _isLooping = false;
    });
  }

  void _setVolume(double value) async {
    await _audioPlayer.setVolume(value);
    setState(() => _volume = value);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    // 按类别分组声音
    final categories = [
      {
        'title': s.suitableFor0To6Months,
        'sounds': [s.soundFetal, s.soundShhh, s.soundVacuum, s.soundHeartbeat],
      },
      {
        'title': s.suitableFor6To18Months,
        'sounds': [s.soundCar, s.soundFan, s.soundStream, s.soundRain, s.soundBird, s.soundLullaby],
      },
      {
        'title': s.above18Months,
        'sounds': [s.soundMarket, s.soundOcean, s.soundPond, s.soundBeach, s.soundCat, s.soundOceanWaves],
      },
    ];

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
          'Sleep Aid',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    SereneColors.primaryFixed,
                    SereneColors.surfaceContainerHighest,
                  ],
                ),
              ),
            ),
            // 主内容
            Column(
              children: [
                // 声音网格
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      SereneSpacing.marginMobile,
                      SereneSpacing.lg,
                      SereneSpacing.marginMobile,
                      200, // 为底部播放器预留空间
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categories.map((category) {
                        return _buildCategory(
                          category['title'] as String,
                          category['sounds'] as List<String>,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // 底部播放器
                if (_playingAudio != null) _buildBottomPlayer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分类
  Widget _buildCategory(String title, List<String> sounds) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SereneSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: SereneSpacing.md,
              mainAxisSpacing: SereneSpacing.md,
              childAspectRatio: 1,
            ),
            itemCount: sounds.length,
            itemBuilder: (context, index) {
              return _buildSoundCard(sounds[index]);
            },
          ),
        ],
      ),
    );
  }

  /// 构建声音卡片
  Widget _buildSoundCard(String label) {
    final isPlaying = _playingAudio == label;
    final isLooping = isPlaying && _isLooping;
    final icon = audioIcons[label] ?? Icons.music_note_outlined;

    return GestureDetector(
      onTap: () => _playAudio(label),
      onLongPress: () => _longPressAudio(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          color: isPlaying
              ? SereneColors.primaryContainer.withValues(alpha: 0.3)
              : SereneColors.surface.withValues(alpha: 0.6),
          border: Border.all(
            color: isPlaying
                ? SereneColors.primary
                : SereneColors.surfaceContainerLowest.withValues(alpha: 0.4),
            width: isPlaying ? 2 : 1,
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: SereneColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标容器
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying
                    ? SereneColors.primary.withValues(alpha: 0.1)
                    : SereneColors.surfaceContainer.withValues(alpha: 0.5),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isPlaying
                    ? SereneColors.primary
                    : SereneColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SereneSpacing.sm),
            // 标题
            Text(
              label,
              style: SereneTypography.labelLarge.copyWith(
                color: isPlaying
                    ? SereneColors.primary
                    : SereneColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            // 播放状态
            if (isPlaying)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SereneColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isLooping ? 'Looping' : 'Playing',
                      style: SereneTypography.labelMedium.copyWith(
                        color: SereneColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建底部播放器
  Widget _buildBottomPlayer() {
    final s = S.of(context);
    final currentIcon = audioIcons[_playingAudio] ?? Icons.music_note_outlined;

    return Container(
      decoration: BoxDecoration(
        color: SereneColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SereneSpacing.radiusXl),
        ),
        border: Border(
          top: BorderSide(
            color: SereneColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SereneSpacing.radiusXl),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SereneSpacing.marginMobile,
              SereneSpacing.lg,
              SereneSpacing.marginMobile,
              SereneSpacing.marginMobile,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 当前播放信息
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(SereneSpacing.radiusMd),
                        color: SereneColors.primaryContainer,
                      ),
                      child: Icon(
                        currentIcon,
                        size: 24,
                        color: SereneColors.primary,
                      ),
                    ),
                    const SizedBox(width: SereneSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _playingAudio ?? '',
                            style: SereneTypography.labelLarge.copyWith(
                              color: SereneColors.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SereneColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Now Playing',
                                style: SereneTypography.labelMedium.copyWith(
                                  color: SereneColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 定时器按钮
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: SereneColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: SereneColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '30m',
                            style: SereneTypography.labelMedium.copyWith(
                              color: SereneColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SereneSpacing.lg),
                // 音量控制
                Row(
                  children: [
                    Icon(
                      Icons.volume_down_outlined,
                      size: 20,
                      color: SereneColors.outlineVariant,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: SereneColors.primaryContainer,
                          inactiveTrackColor: SereneColors.surfaceContainerHigh,
                          thumbColor: SereneColors.primary,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: _volume,
                          onChanged: _setVolume,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.volume_up_outlined,
                      size: 20,
                      color: SereneColors.outlineVariant,
                    ),
                  ],
                ),
                const SizedBox(height: SereneSpacing.lg),
                // 播放控制
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 循环按钮
                    GestureDetector(
                      onTap: _toggleLoop,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isLooping
                              ? SereneColors.primaryContainer.withValues(alpha: 0.5)
                              : SereneColors.surfaceContainer,
                        ),
                        child: Icon(
                          Icons.repeat_one_outlined,
                          size: 24,
                          color: _isLooping
                              ? SereneColors.primary
                              : SereneColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: SereneSpacing.xl),
                    // 播放/暂停按钮
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return GestureDetector(
                          onTap: () {
                            if (playing) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SereneColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: SereneColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              size: 36,
                              color: SereneColors.onPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: SereneSpacing.xl),
                    // 停止按钮
                    GestureDetector(
                      onTap: _stopAudio,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SereneColors.surfaceContainer,
                        ),
                        child: const Icon(
                          Icons.stop_outlined,
                          size: 24,
                          color: SereneColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
