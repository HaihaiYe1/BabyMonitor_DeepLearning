import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/chart_widget.dart';
import '../generated/l10n.dart';

class DataAnalysisPage extends StatefulWidget {
  @override
  _DataAnalysisPageState createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  List<NotificationStat> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotificationData();
  }

  Future<void> fetchNotificationData() async {
    try {
      final data = await NotificationServiceUpdate.fetchNotifications();
      setState(() {
        notifications = data;
      });
    } catch (e) {
      print(S.of(context).errorLoadNotification);
    }
  }

  Map<int, Map<String, int>> calculateHourlyStats() {
    Map<int, Map<String, int>> hourlyStats = {};
    for (var item in notifications) {
      final hour = item.timestamp.hour;
      hourlyStats.putIfAbsent(hour, () => {
        "danger": 0,
        "warning": 0,
        "safe": 0,
      });
      hourlyStats[hour]![item.level] = hourlyStats[hour]![item.level]! + 1;
    }
    return hourlyStats;
  }

  @override
  Widget build(BuildContext context) {
    final hourlyStats = calculateHourlyStats();
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(S.of(context).titleDataAnalysis),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE3FDFD),
                    Color(0xFFFFE6FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            notifications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).labelHourlyAlert,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 240,
                          child: HourlyBarChart(hourlyStats: hourlyStats),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          S.of(context).labelDangerTrend,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 240,
                          child: MultiLineChart(
                            dataSeries: {
                              S.of(context).levelDanger: hourlyStats.entries
                                  .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      (e.value['danger'] ?? 0).toDouble()))
                                  .toList(),
                              S.of(context).levelWarning: hourlyStats.entries
                                  .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      (e.value['warning'] ?? 0).toDouble()))
                                  .toList(),
                              S.of(context).levelSafe: hourlyStats.entries
                                  .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      (e.value['safe'] ?? 0).toDouble()))
                                  .toList(),
                            },
                            colorMap: {
                              S.of(context).levelDanger: Colors.redAccent,
                              S.of(context).levelWarning: Colors.orange,
                              S.of(context).levelSafe: Colors.green,
                            },
                            xLabelUnit: 'h',
                            interval: 2,
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
}

class NotificationStat {
  final DateTime timestamp;
  final String level;

  NotificationStat({required this.timestamp, required this.level});

  factory NotificationStat.fromJson(Map<String, dynamic> json) {
    return NotificationStat(
      timestamp: DateTime.parse(json['timestamp']),
      level: json['level'],
    );
  }
}

class NotificationServiceUpdate {
  static Future<List<NotificationStat>> fetchNotifications() async {
    final token = await SharedPreferences.getInstance().then((prefs) => prefs.getString("token"));
    final url = Uri.parse(ApiService.notificationList); // 用 ApiService 里的 URL
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((item) => NotificationStat.fromJson(item)).toList();
    } else {
      throw Exception(S.current.errorFetchNotification);
    }
  }
}
