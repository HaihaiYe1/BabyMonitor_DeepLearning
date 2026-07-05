import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/chart_widget.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

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
          s.pageTitle,
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景色
            Container(
              color: SereneColors.surface,
            ),
            // 页面内容
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SereneSpacing.marginMobile,
                SereneSpacing.lg,
                SereneSpacing.marginMobile,
                SereneSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 生长记录表单
                  _buildGrowthForm(s),
                  const SizedBox(height: SereneSpacing.lg),
                  // 体重趋势图
                  if (records.isNotEmpty) ...[
                    _buildChart(
                      title: s.weightTrend,
                      dataSeries: weightData,
                      color: SereneColors.primary,
                    ),
                    const SizedBox(height: SereneSpacing.lg),
                    _buildChart(
                      title: s.heightTrend,
                      dataSeries: heightData,
                      color: SereneColors.safe,
                    ),
                    const SizedBox(height: SereneSpacing.lg),
                  ],
                  // 里程碑提示
                  _buildMilestoneTips(s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建生长记录表单
  Widget _buildGrowthForm(S s) {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.growthTitle,
              style: SereneTypography.headlineSmall.copyWith(
                color: SereneColors.onSurface,
              ),
            ),
            const SizedBox(height: SereneSpacing.md),
            // 月龄和体重
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: s.monthLabel,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? s.requiredField : null,
                    onSaved: (v) => _month = int.parse(v!),
                  ),
                ),
                const SizedBox(width: SereneSpacing.md),
                Expanded(
                  child: _buildInputField(
                    label: s.weightLabel,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? s.requiredField : null,
                    onSaved: (v) => _weight = double.parse(v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SereneSpacing.md),
            // 身高和头围
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: s.heightLabel,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? s.requiredField : null,
                    onSaved: (v) => _height = double.parse(v!),
                  ),
                ),
                const SizedBox(width: SereneSpacing.md),
                Expanded(
                  child: _buildInputField(
                    label: s.headCircLabel,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? s.requiredField : null,
                    onSaved: (v) => _headCirc = double.parse(v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SereneSpacing.lg),
            // 添加按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SereneColors.primary,
                  foregroundColor: SereneColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: SereneSpacing.buttonRadius,
                  ),
                ),
                child: Text(
                  s.addRecord,
                  style: SereneTypography.labelLarge.copyWith(
                    color: SereneColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建输入框
  Widget _buildInputField({
    required String label,
    required TextInputType keyboardType,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: SereneTypography.bodyMedium.copyWith(
          color: SereneColors.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: SereneTypography.bodySmall.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SereneSpacing.md,
            vertical: SereneSpacing.md,
          ),
        ),
      ),
    );
  }

  /// 构建图表
  Widget _buildChart({
    required String title,
    required Map<String, List<FlSpot>> dataSeries,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
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
          SizedBox(
            height: 200,
            child: MultiLineChart(
              title: title,
              dataSeries: dataSeries,
              colorMap: {dataSeries.keys.first: color},
              xLabelUnit: 'Month',
              interval: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建里程碑提示
  Widget _buildMilestoneTips(S s) {
    if (records.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.milestoneTitle,
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          ...records.map((r) {
            final tips = _milestoneTips(r.month, s);
            return tips.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: SereneSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.milestonePrefix(r.month),
                          style: SereneTypography.labelLarge.copyWith(
                            color: SereneColors.primary,
                          ),
                        ),
                        const SizedBox(height: SereneSpacing.xs),
                        ...tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 6, right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SereneColors.primaryContainer,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: SereneTypography.bodyMedium.copyWith(
                                    color: SereneColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  );
          }).toList(),
        ],
      ),
    );
  }
}
