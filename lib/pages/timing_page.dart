import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class TimingPage extends StatefulWidget {
  const TimingPage({Key? key}) : super(key: key);

  @override
  _TimingPageState createState() => _TimingPageState();
}

class _TimingPageState extends State<TimingPage> {
  Map<String, dynamic>? timingResult;
  bool isLoading = false;

  Future<void> _pickAndUploadVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _uploadVideo(file);
    }
  }

  Future<void> _uploadVideo(File file) async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:8000/timing/timing'); // 注意这里是 /timing
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          timingResult = data;
        });
      } else {
        throw Exception('上传失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('上传失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('上传或解析视频失败')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTimingResult(Map<String, dynamic> data) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('帧数: ${data["frame_count"]}', style: const TextStyle(fontSize: 16)),
                Text('Preprocess: ${data["preprocess"]} 秒'),
                Text('Inference: ${data["inference"]} 秒'),
                Text('Postprocess: ${data["postprocess"]} 秒'),
                Text('总耗时: ${data["total"]} 秒'),
                Text('平均每帧耗时: ${data["avg_per_frame"]} 秒'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 1.3,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (data["total"] as num).toDouble() * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text("Pre");
                          case 1:
                            return const Text("Inf");
                          case 2:
                            return const Text("Post");
                          case 3:
                            return const Text("Total");
                          default:
                            return const Text("");
                        }
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                      toY: (data["preprocess"] as num).toDouble(),
                      color: Colors.blue,
                      width: 16,
                    ),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                      toY: (data["inference"] as num).toDouble(),
                      color: Colors.green,
                      width: 16,
                    ),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                      toY: (data["postprocess"] as num).toDouble(),
                      color: Colors.orange,
                      width: 16,
                    ),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(
                      toY: (data["total"] as num).toDouble(),
                      color: Colors.red,
                      width: 16,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('检测耗时统计'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _pickAndUploadVideo,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3FDFD), Color(0xFFD2F6C5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : timingResult == null
                ? const Center(child: Text('请上传视频以查看检测耗时'))
                : SingleChildScrollView(child: _buildTimingResult(timingResult!)),
      ),
    );
  }
}
