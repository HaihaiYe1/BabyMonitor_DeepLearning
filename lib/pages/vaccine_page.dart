import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class VaccineSchedulePage extends StatefulWidget {
  @override
  _VaccineSchedulePageState createState() => _VaccineSchedulePageState();
}

class _VaccineSchedulePageState extends State<VaccineSchedulePage> {
  int _selectedChildIndex = 0;
  List<ChildProfile> _children = [];
  late SharedPreferences _prefs;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<VaccineItem> defaultVaccines = [
    VaccineItem("卡介苗", 0, true),
    VaccineItem("乙肝疫苗第1针", 0, true),
    VaccineItem("乙肝疫苗第2针", 1, true),
    VaccineItem("脊灰灭活疫苗第1针", 2, true),
    VaccineItem("百白破疫苗第1针", 2, true),
    VaccineItem("脊灰灭活疫苗第2针", 3, true),
    VaccineItem("百白破疫苗第2针", 3, true),
    VaccineItem("脊灰减毒活疫苗第1针", 4, true),
    VaccineItem("百白破疫苗第3针", 4, true),
    VaccineItem("百白破疫苗第4针", 5, true),
    VaccineItem("乙肝疫苗第3针", 6, true),
    VaccineItem("A群流脑多糖疫苗第1针", 6, true),
    VaccineItem("百白破疫苗第5针", 6, true),
    VaccineItem("麻风疫苗", 8, true),
    VaccineItem("乙脑减毒活疫苗第1针", 8, true),
    VaccineItem("A群流脑多糖疫苗第2针", 9, true),
    VaccineItem("麻腮风疫苗", 18, true),
    VaccineItem("百白破加强针", 18, true),
    VaccineItem("甲肝减毒活疫苗", 18, true),
    VaccineItem("乙脑减毒活疫苗第2针", 24, true),
    VaccineItem("A群C群流脑多糖疫苗第1针", 36, true),
    VaccineItem("脊灰减毒活疫苗第2针", 48, true),
    VaccineItem("白破疫苗", 72, true),
    VaccineItem("A群C群流脑多糖疫苗第2针", 72, true),
    VaccineItem("乙脑灭活疫苗第4针", 72, true),
    VaccineItem("流感疫苗", 6, false),
    VaccineItem("水痘疫苗第1针", 12, false),
    VaccineItem("水痘疫苗第2针", 48, false),
    VaccineItem("肺炎球菌结合疫苗(13价)", 2, false),
    VaccineItem("肺炎球菌结合疫苗(13价)加强", 15, false),
    VaccineItem("肺炎球菌多糖疫苗(23价)", 24, false),
    VaccineItem("HPV疫苗(男)", 108, false),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadPrefs();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'baby_vaccine_channel',
      'Baby Vaccine Reminders',
      description: 'Notifications for vaccine schedules',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('notification'),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final data = _prefs.getString('children_data');
    if (data != null) {
      final list = json.decode(data) as List;
      _children = list.map((e) => ChildProfile.fromJson(e)).toList();
    } else {
      _children = [
        ChildProfile(
          name: '宝宝',
          ageMonths: 0,
          vaccines: {
            for (var v in defaultVaccines) v.name: VaccineRecord(vaccine: v),
          },
        ),
      ];
    }
    setState(() {});
  }

  Future<void> _savePrefs() async {
    final data = json.encode(_children.map((e) => e.toJson()).toList());
    await _prefs.setString('children_data', data);
  }

  void _updateAge(int months) {
    setState(() => _children[_selectedChildIndex].ageMonths = months);
    _savePrefs();
    _scheduleVaccineNotifications();
  }

  void _toggleVaccineStatus(String name) async {
    final record = _children[_selectedChildIndex].vaccines[name]!;
    setState(() {
      record.isDone = !record.isDone;
      record.date = record.isDone ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : null;
    });
    _savePrefs();
    if (record.isDone) await flutterLocalNotificationsPlugin.cancel(name.hashCode);
    _scheduleVaccineNotifications();
  }

  void _updateRemindDays(String name, int days) {
    final record = _children[_selectedChildIndex].vaccines[name]!;
    setState(() => record.remindBeforeDays = days);
    _savePrefs();
    _scheduleVaccineNotifications();
  }

  void _scheduleVaccineNotifications() {
    final child = _children[_selectedChildIndex];
    for (var entry in child.vaccines.entries) {
      final v = entry.value.vaccine;
      final status = entry.value.isDone;
      final remindDays = entry.value.remindBeforeDays;
      if (!status && child.ageMonths >= v.month - remindDays ~/ 1) {
        final scheduledDate = DateTime.now().add(Duration(seconds: 5));
        _scheduleNotification(v.name, scheduledDate);
      }
    }
  }

  void _scheduleNotification(String vaccineName, DateTime dateTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      vaccineName.hashCode,
      '疫苗接种提醒',
      '$vaccineName 接种时间临近，请及时确认',
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'baby_vaccine_channel',
          'Baby Vaccine Reminders',
          channelDescription: 'Vaccine reminder alerts',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'notification',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _addCustomVaccine({VaccineItem? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final monthController = TextEditingController(text: existing?.month.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? "添加自定义疫苗" : "编辑自定义疫苗"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: '疫苗名称')),
            TextField(controller: monthController, decoration: InputDecoration(labelText: '建议接种月龄'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("取消")),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final month = int.tryParse(monthController.text);
              if (name.isEmpty || month == null) return;
              final vaccine = VaccineItem(name, month, false);
              setState(() {
                _children[_selectedChildIndex].vaccines.remove(existing?.name ?? name);
                _children[_selectedChildIndex].vaccines[name] = VaccineRecord(vaccine: vaccine);
              });
              _savePrefs();
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? "添加" : "保存"),
          )
        ],
      ),
    );
  }

  void _deleteCustomVaccine(String name) {
    setState(() {
      _children[_selectedChildIndex].vaccines.remove(name);
    });
    _savePrefs();
  }

  void _addChild() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("添加孩童"),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: '孩童名称')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("取消")),
          TextButton(
            onPressed: () {
              final profile = ChildProfile(name: controller.text, ageMonths: 0, vaccines: {
                for (var v in defaultVaccines) v.name: VaccineRecord(vaccine: v),
              });
              setState(() => _children.add(profile));
              _savePrefs();
              Navigator.pop(ctx);
            },
            child: Text("添加"),
          )
        ],
      ),
    );
  }

  String _formatMonthAge(int months) {
    if (months < 12) return "$months 月龄";
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    return remainingMonths == 0 ? "$years 岁" : "$years 岁 $remainingMonths 月";
  }

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) return Center(child: Text("暂无孩童"));
    final child = _children[_selectedChildIndex];
    final vaccines = child.vaccines.values.toList()
      ..sort((a, b) => a.vaccine.month.compareTo(b.vaccine.month));

    return Scaffold(
      appBar: AppBar(
        title: Text("疫苗接种计划 - ${child.name}"),
        backgroundColor: Colors.grey,
      ),
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Divider(),
          ...vaccines.map((v) => _buildVaccineCard(v)),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).primaryColor,
        overlayOpacity: 0.4,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(Icons.person_add),
            label: '添加孩童',
            onTap: _addChild,
          ),
          SpeedDialChild(
            child: Icon(Icons.add),
            label: '添加自定义疫苗',
            onTap: () => _addCustomVaccine(),
          ),
          SpeedDialChild(
            child: Icon(Icons.child_care),
            label: '选择宝宝',
            onTap: () async {
              final selected = await showDialog<int>(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: Text("选择宝宝"),
                  children: List.generate(
                    _children.length,
                        (i) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, i),
                      child: Text(_children[i].name),
                    ),
                  ),
                ),
              );
              if (selected != null) {
                setState(() => _selectedChildIndex = selected);
              }
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.cake),
            label: '选择年龄',
            onTap: () async {
              final selected = await showDialog<int>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("选择月龄"),
                  content: Container(
                    width: double.maxFinite,
                    height: 300,
                    child: ListView.builder(
                      itemCount: 121,
                      itemBuilder: (ctx, i) => ListTile(
                        title: Text("$i 月龄"),
                        onTap: () => Navigator.pop(ctx, i),
                      ),
                    ),
                  ),
                ),
              );
              if (selected != null) _updateAge(selected);
            },
          ),
        ],
      ),
    );
  }


  Widget _buildVaccineCard(VaccineRecord record) {
    final vaccine = record.vaccine;
    final overdue = _children[_selectedChildIndex].ageMonths > vaccine.month + 1 && !record.isDone;
    final isCustom = !vaccine.isPrimary;

    return Card(
      color: overdue ? Colors.grey[300] : Colors.white,
      child: ListTile(
        title: Text(vaccine.name),
        subtitle: Text("建议接种：${_formatMonthAge(vaccine.month)}${record.date != null ? "\n接种日期：${record.date}" : ""}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: record.isDone,
              onChanged: (_) => _toggleVaccineStatus(vaccine.name),
            ),
            PopupMenuButton<int>(
              icon: Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 1) _updateRemindDays(vaccine.name, 1);
                else if (val == 3) _updateRemindDays(vaccine.name, 3);
                else if (val == 7) _updateRemindDays(vaccine.name, 7);
                else if (val == 10) _addCustomVaccine(existing: vaccine);
                else if (val == 99) _deleteCustomVaccine(vaccine.name);
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 1, child: Text("提前1天提醒")),
                PopupMenuItem(value: 3, child: Text("提前3天提醒")),
                PopupMenuItem(value: 7, child: Text("提前7天提醒")),
                if (isCustom) ...[
                  PopupMenuItem(value: 10, child: Text("编辑")),
                  PopupMenuItem(value: 99, child: Text("删除")),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VaccineItem {
  final String name;
  final int month;
  final bool isPrimary;
  VaccineItem(this.name, this.month, this.isPrimary);

  Map<String, dynamic> toJson() => {'name': name, 'month': month, 'isPrimary': isPrimary};
  factory VaccineItem.fromJson(Map<String, dynamic> json) => VaccineItem(json['name'], json['month'], json['isPrimary']);
}

class VaccineRecord {
  final VaccineItem vaccine;
  bool isDone;
  int remindBeforeDays;
  String? date;

  VaccineRecord({required this.vaccine, this.isDone = false, this.remindBeforeDays = 7, this.date});

  Map<String, dynamic> toJson() => {
    'vaccine': vaccine.toJson(),
    'isDone': isDone,
    'remindBeforeDays': remindBeforeDays,
    'date': date,
  };
  factory VaccineRecord.fromJson(Map<String, dynamic> json) => VaccineRecord(
    vaccine: VaccineItem.fromJson(json['vaccine']),
    isDone: json['isDone'],
    remindBeforeDays: json['remindBeforeDays'],
    date: json['date'],
  );
}

class ChildProfile {
  String name;
  int ageMonths;
  Map<String, VaccineRecord> vaccines;

  ChildProfile({
    required this.name,
    required this.ageMonths,
    required this.vaccines,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'ageMonths': ageMonths,
    'vaccines': vaccines.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    name: json['name'],
    ageMonths: json['ageMonths'],
    vaccines: (json['vaccines'] as Map<String, dynamic>).map((k, v) => MapEntry(k, VaccineRecord.fromJson(v))),
  );
}
