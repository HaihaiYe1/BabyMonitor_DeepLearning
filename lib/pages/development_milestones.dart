import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/chart_widget.dart';
import '../generated/l10n.dart';

class GrowthRecord {
  final int month;
  final double weight;
  final double height;
  final double headCircumference;

  GrowthRecord({
    required this.month,
    required this.weight,
    required this.height,
    required this.headCircumference,
  });

  Map<String, dynamic> toJson() => {
    'month': month,
    'weight': weight,
    'height': height,
    'headCircumference': headCircumference,
  };

  factory GrowthRecord.fromJson(Map<String, dynamic> json) => GrowthRecord(
    month: json['month'],
    weight: json['weight'],
    height: json['height'],
    headCircumference: json['headCircumference'],
  );
}

class DevelopmentMilestonesPage extends StatefulWidget {
  @override
  _DevelopmentMilestonesPageState createState() =>
      _DevelopmentMilestonesPageState();
}

class _DevelopmentMilestonesPageState extends State<DevelopmentMilestonesPage> {
  List<GrowthRecord> records = [];

  final _formKey = GlobalKey<FormState>();
  int? _month;
  double? _weight, _height, _headCirc;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('growthRecords');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      setState(() {
        records = decoded.map((e) => GrowthRecord.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString('growthRecords', jsonString);
  }

  void _addRecord() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final record = GrowthRecord(
        month: _month!,
        weight: _weight!,
        height: _height!,
        headCircumference: _headCirc!,
      );
      setState(() {
        records.add(record);
        records.sort((a, b) => a.month.compareTo(b.month));
      });
      _saveRecords();
    }
  }

  List<String> _milestoneTips(int month, S s) {
    final Map<int, String> tipsMap = {
      1: s.tip1,
      2: s.tip2,
      3: s.tip3,
      4: s.tip4,
      5: s.tip5,
      6: s.tip6,
      7: s.tip7,
      8: s.tip8,
      9: s.tip9,
      10: s.tip10,
      11: s.tip11,
      12: s.tip12,
      15: s.tip15,
      18: s.tip18,
      24: s.tip24,
    };
    return tipsMap.containsKey(month) ? [tipsMap[month]!] : [];
  }


  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final weightData = {
      s.weightLabel: records.map((r) => FlSpot(r.month.toDouble(), r.weight)).toList()
    };
    final heightData = {
      s.heightLabel: records.map((r) => FlSpot(r.month.toDouble(), r.height)).toList()
    };

    return Scaffold(
      extendBody: true, // 使得底部导航栏浮动
      appBar: AppBar(
        title: Text(s.pageTitle),
        centerTitle: true,
        automaticallyImplyLeading: false, // 去掉返回按钮
        backgroundColor: Colors.white.withOpacity(0.8), // 半透明背景
        elevation: 0, // 去掉阴影
      ),
      body: SafeArea(
        bottom: false, // 保留底部区域的渐变效果
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE3FDFD), // 浅蓝色
                    Color(0xFFFFE6FA), // 浅粉色
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // 页面内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(s.growthTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: TextFormField(
                          decoration: InputDecoration(labelText: s.monthLabel),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? s.requiredField : null,
                          onSaved: (v) => _month = int.parse(v!),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(
                          decoration: InputDecoration(labelText: s.weightLabel),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? s.requiredField : null,
                          onSaved: (v) => _weight = double.parse(v!),
                        )),
                      ]),
                      Row(children: [
                        Expanded(child: TextFormField(
                          decoration: InputDecoration(labelText: s.heightLabel),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? s.requiredField : null,
                          onSaved: (v) => _height = double.parse(v!),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(
                          decoration: InputDecoration(labelText: s.headCircLabel),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? s.requiredField : null,
                          onSaved: (v) => _headCirc = double.parse(v!),
                        )),
                      ]),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: _addRecord, child: Text(s.addRecord)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  MultiLineChart(
                    title: s.weightTrend,
                    dataSeries: weightData,
                    colorMap: {s.weightLabel: Colors.blue},
                    xLabelUnit: s.monthLabel,
                    interval: 1,
                  ),
                  const SizedBox(height: 10),
                  MultiLineChart(
                    title: s.heightTrend,
                    dataSeries: heightData,
                    colorMap: {s.heightLabel: Colors.green},
                    xLabelUnit: s.monthLabel,
                    interval: 1,
                  ),
                  const SizedBox(height: 20),
                  Text(s.milestoneTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...records.map((r) {
                    final tips = _milestoneTips(r.month, s);
                    return tips.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(  S.of(context).milestonePrefix(r.month),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          ...tips.map((tip) => Text("• $tip")),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
