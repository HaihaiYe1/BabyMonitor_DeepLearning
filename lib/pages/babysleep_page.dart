import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../generated/l10n.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final Map<String, String> audioFiles;
  late final Map<String, String> localizedLabels;

  String? _playingAudio;
  bool _isLooping = false;

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

    localizedLabels = Map.from(audioFiles); // 用于显示音频标签
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
      await _audioPlayer.play();
      setState(() {
        _playingAudio = label;
        _isLooping = true;
      });
    }
  }

  Widget buildCategory(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            final isPlaying = _playingAudio == item;
            final isLooping = isPlaying && _isLooping;

            return GestureDetector(
              onTap: () => _playAudio(item),
              onLongPress: () => _longPressAudio(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: isPlaying ? Colors.lightBlueAccent : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPlaying
                          ? (isLooping ? Icons.loop : Icons.play_arrow)
                          : Icons.music_note,
                      color: isPlaying ? Colors.white : Colors.black54,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: TextStyle(
                        color: isPlaying ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget buildBottomPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _playingAudio ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return IconButton(
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      if (playing) {
                        _audioPlayer.pause();
                      } else {
                        _audioPlayer.play();
                      }
                    },
                  );
                },
              ),
            ],
          ),
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _audioPlayer.duration ?? Duration.zero;
              return Slider(
                min: 0,
                max: duration.inMilliseconds.toDouble(),
                value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: Text(
          s.sleepWhiteNoise,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCategory(s.suitableFor0To6Months, [
                    s.soundFetal,
                    s.soundShhh,
                    s.soundVacuum,
                    s.soundHeartbeat,
                  ]),
                  buildCategory(s.suitableFor6To18Months, [
                    s.soundCar,
                    s.soundFan,
                    s.soundStream,
                    s.soundRain,
                    s.soundBird,
                    s.soundLullaby,
                  ]),
                  buildCategory(s.above18Months, [
                    s.soundMarket,
                    s.soundOcean,
                    s.soundPond,
                    s.soundBeach,
                    s.soundCat,
                    s.soundOceanWaves,
                  ]),
                  const SizedBox(height: 80), // 预留底部播放器空间
                ],
              ),
            ),
          ),
          if (_playingAudio != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: buildBottomPlayer(),
            ),
        ],
      ),
    );
  }
}
