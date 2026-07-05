import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

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
        backgroundColor: SereneColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: SereneSpacing.dialogRadius,
        ),
        title: Text(
          existing == null ? "添加自定义疫苗" : "编辑自定义疫苗",
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(
              controller: nameController,
              hintText: '疫苗名称',
              icon: Icons.vaccines_outlined,
            ),
            const SizedBox(height: SereneSpacing.md),
            _buildDialogTextField(
              controller: monthController,
              hintText: '建议接种月龄',
              icon: Icons.calendar_month_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "取消",
              style: SereneTypography.labelLarge.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
            ),
          ),
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
            child: Text(
              existing == null ? "添加" : "保存",
              style: SereneTypography.labelLarge.copyWith(
                color: SereneColors.primary,
              ),
            ),
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
        backgroundColor: SereneColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: SereneSpacing.dialogRadius,
        ),
        title: Text(
          "添加孩童",
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        content: _buildDialogTextField(
          controller: controller,
          hintText: '孩童名称',
          icon: Icons.child_care_outlined,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "取消",
              style: SereneTypography.labelLarge.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final profile = ChildProfile(name: controller.text, ageMonths: 0, vaccines: {
                for (var v in defaultVaccines) v.name: VaccineRecord(vaccine: v),
              });
              setState(() => _children.add(profile));
              _savePrefs();
              Navigator.pop(ctx);
            },
            child: Text(
              "添加",
              style: SereneTypography.labelLarge.copyWith(
                color: SereneColors.primary,
              ),
            ),
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

    // 按月龄分组
    final Map<int, List<VaccineRecord>> groupedVaccines = {};
    for (var v in vaccines) {
      final month = v.vaccine.month;
      if (!groupedVaccines.containsKey(month)) {
        groupedVaccines[month] = [];
      }
      groupedVaccines[month]!.add(v);
    }
    final sortedMonths = groupedVaccines.keys.toList()..sort();

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
              color: SereneColors.primary,
            ),
          ),
        ),
        title: Text(
          'Vaccine Schedule',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: SereneIconButton(
              icon: Icons.child_care_outlined,
              iconColor: SereneColors.primary,
              size: 40,
              tooltip: 'Add child',
              onPressed: _addChild,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景色
            Container(
              color: SereneColors.surface,
            ),
            // 主内容
            Column(
              children: [
                // 孩子选择器
                _buildChildSelector(),
                // 疫苗列表
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      SereneSpacing.marginMobile,
                      SereneSpacing.lg,
                      SereneSpacing.marginMobile,
                      SereneSpacing.xl,
                    ),
                    child: Column(
                      children: sortedMonths.map((month) {
                        final records = groupedVaccines[month]!;
                        return _buildTimelineSection(month, records);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// 构建孩子选择器
  Widget _buildChildSelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: SereneSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SereneSpacing.marginMobile),
        itemCount: _children.length + 1,
        itemBuilder: (context, index) {
          if (index < _children.length) {
            final child = _children[index];
            final isSelected = index == _selectedChildIndex;
            return Padding(
              padding: const EdgeInsets.only(right: SereneSpacing.md),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedChildIndex = index;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? SereneColors.primaryContainer
                              : SereneColors.outlineVariant,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: isSelected
                            ? SereneColors.primaryContainer.withValues(alpha: 0.3)
                            : SereneColors.surfaceContainerLow,
                        child: Text(
                          child.name[0],
                          style: SereneTypography.headlineSmall.copyWith(
                            color: isSelected
                                ? SereneColors.primary
                                : SereneColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.name,
                      style: SereneTypography.labelMedium.copyWith(
                        color: isSelected
                            ? SereneColors.primary
                            : SereneColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // 添加按钮
            return GestureDetector(
              onTap: _addChild,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SereneColors.outlineVariant,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      color: SereneColors.surfaceContainerLow,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: SereneColors.outline,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add',
                    style: SereneTypography.labelMedium.copyWith(
                      color: SereneColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  /// 构建时间线区域
  Widget _buildTimelineSection(int month, List<VaccineRecord> records) {
    final child = _children[_selectedChildIndex];
    final isOverdue = child.ageMonths > month + 1 && records.any((r) => !r.isDone);
    final isCurrent = child.ageMonths >= month && child.ageMonths <= month + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: SereneSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线指示器
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOverdue
                      ? SereneColors.errorContainer
                      : isCurrent
                          ? SereneColors.primaryContainer
                          : SereneColors.surfaceVariant,
                  border: Border.all(
                    color: SereneColors.surface,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOverdue
                          ? SereneColors.error
                          : isCurrent
                              ? SereneColors.primary
                              : SereneColors.outline,
                    ),
                  ),
                ),
              ),
              Container(
                width: 2,
                height: records.length * 80.0,
                color: SereneColors.surfaceVariant,
              ),
            ],
          ),
          const SizedBox(width: SereneSpacing.md),
          // 疫苗卡片
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMonthAge(month),
                  style: SereneTypography.headlineSmall.copyWith(
                    color: isOverdue
                        ? SereneColors.error
                        : SereneColors.onSurface,
                  ),
                ),
                const SizedBox(height: SereneSpacing.sm),
                ...records.map((record) => _buildVaccineCard(record)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建疫苗卡片
  Widget _buildVaccineCard(VaccineRecord record) {
    final vaccine = record.vaccine;
    final child = _children[_selectedChildIndex];
    final overdue = child.ageMonths > vaccine.month + 1 && !record.isDone;
    final isCustom = !vaccine.isPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: SereneSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(SereneSpacing.md),
        child: Row(
          children: [
            // 状态指示器
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: record.isDone
                    ? SereneColors.primary
                    : overdue
                        ? SereneColors.errorContainer
                        : Colors.transparent,
                border: Border.all(
                  color: record.isDone
                      ? Colors.transparent
                      : overdue
                          ? SereneColors.error
                          : SereneColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: record.isDone
                  ? const Icon(
                      Icons.check,
                      color: SereneColors.onPrimary,
                      size: 18,
                    )
                  : overdue
                      ? const Icon(
                          Icons.priority_high,
                          color: SereneColors.error,
                          size: 18,
                        )
                      : null,
            ),
            const SizedBox(width: SereneSpacing.md),
            // 疫苗信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccine.name,
                    style: SereneTypography.labelLarge.copyWith(
                      color: overdue
                          ? SereneColors.error
                          : SereneColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.isDone
                        ? '接种日期：${record.date}'
                        : '建议接种：${_formatMonthAge(vaccine.month)}',
                    style: SereneTypography.bodySmall.copyWith(
                      color: overdue
                          ? SereneColors.onErrorContainer
                          : SereneColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // 操作按钮
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: record.isDone,
                  onChanged: (_) => _toggleVaccineStatus(vaccine.name),
                  activeColor: SereneColors.primary,
                ),
                PopupMenuButton<int>(
                  icon: Icon(
                    Icons.more_vert,
                    color: SereneColors.outline,
                    size: 20,
                  ),
                  onSelected: (val) {
                    if (val == 1) _updateRemindDays(vaccine.name, 1);
                    else if (val == 3) _updateRemindDays(vaccine.name, 3);
                    else if (val == 7) _updateRemindDays(vaccine.name, 7);
                    else if (val == 10) _addCustomVaccine(existing: vaccine);
                    else if (val == 99) _deleteCustomVaccine(vaccine.name);
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        "提前1天提醒",
                        style: SereneTypography.bodyMedium,
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text(
                        "提前3天提醒",
                        style: SereneTypography.bodyMedium,
                      ),
                    ),
                    PopupMenuItem(
                      value: 7,
                      child: Text(
                        "提前7天提醒",
                        style: SereneTypography.bodyMedium,
                      ),
                    ),
                    if (isCustom) ...[
                      PopupMenuItem(
                        value: 10,
                        child: Text(
                          "编辑",
                          style: SereneTypography.bodyMedium,
                        ),
                      ),
                      PopupMenuItem(
                        value: 99,
                        child: Text(
                          "删除",
                          style: SereneTypography.bodyMedium.copyWith(
                            color: SereneColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建FAB
  Widget _buildFAB() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SereneSpacing.radiusLg),
        color: SereneColors.primary,
        boxShadow: [
          BoxShadow(
            color: SereneColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusLg),
          onTap: () => _addCustomVaccine(),
          child: const Icon(
            Icons.add,
            size: 28,
            color: SereneColors.onPrimary,
          ),
        ),
      ),
    );
  }

  /// 构建对话框输入框
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.inputRadius,
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: SereneSpacing.md),
            child: Icon(
              icon,
              color: SereneColors.outline,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: SereneTypography.bodyMedium.copyWith(
                  color: SereneColors.outlineVariant,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SereneSpacing.sm,
                  vertical: SereneSpacing.md,
                ),
              ),
            ),
          ),
        ],
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
