# Serene Guardian 设计系统

基于 stitch 项目的 DESIGN.md 完全还原的 Flutter 设计系统。

## 概述

Serene Guardian 设计系统是一个现代极简风格，带有毛玻璃效果（Glassmorphism）的 UI 组件库，专为婴儿监控应用设计。

## 设计原则

- **Modern Minimalist with Glassmorphic accents** - 现代极简风格搭配毛玻璃效果
- **Calm-tech** - 通过高可读性字体和宽敞布局减少用户焦虑
- **Layered depth** - 使用半透明层和背景模糊分离关键监控数据

## 颜色系统

### 基础色
- **主色调 (Primary)**: `#3B6376` - 温柔蓝，用于主动监控状态、主要操作
- **次要色 (Secondary)**: `#755844` - 温暖棕，用于高亮、睡眠追踪
- **第三色 (Tertiary)**: `#566246` - 自然绿
- **错误色 (Error)**: `#BA1A1A` - 用于危险状态

### 表面色
- **Surface**: `#FAF8FF` - 主背景色
- **Surface Container**: `#EBEDFF` - 容器背景
- **Surface Container High**: `#E4E7FE` - 高层级容器

### 玻璃效果
- **Glass Background**: `rgba(255, 255, 255, 0.7)` + 30px blur
- **Glass Float**: `rgba(255, 255, 255, 0.8)` + 20px blur

## 字体系统

使用 **Inter** 字体，提供以下样式：

| 样式 | 大小 | 字重 | 行高 |
|------|------|------|------|
| Headline Large | 32px | Bold (700) | 40px |
| Headline Medium | 24px | Semi-bold (600) | 32px |
| Headline Small | 20px | Semi-bold (600) | 28px |
| Body Large | 18px | Regular (400) | 28px |
| Body Medium | 16px | Regular (400) | 24px |
| Body Small | 14px | Regular (400) | 20px |
| Label Large | 14px | Semi-bold (600) | 20px |
| Label Medium | 12px | Medium (500) | 16px |

## 间距系统

基于 8px 线性刻度：

| 名称 | 大小 | 用途 |
|------|------|------|
| xs | 4px | 最小间距 |
| sm | 8px | 小间距 |
| md | 16px | 中间距 |
| lg | 24px | 大间距 |
| xl | 32px | 超大间距 |

## 组件库

### 毛玻璃组件

1. **GlassPanel** - 毛玻璃面板
   - 70% 透明度白色背景
   - 30px 背景模糊
   - 1px 白色边框

2. **GlassFloat** - 毛玻璃浮动元素
   - 80% 透明度白色背景
   - 20px 背景模糊
   - 轻微阴影

3. **GlassCard** - 毛玻璃卡片
   - 用于内容展示
   - 支持点击事件

4. **GlassBottomNavBar** - 毛玻璃底部导航栏
   - 半透明背景
   - 圆角顶部

5. **GlassAppBar** - 毛玻璃应用栏
   - 半透明背景
   - 背景模糊效果

6. **GlassDrawer** - 毛玻璃抽屉
   - 圆角设计
   - 边框效果

7. **GlassTextField** - 毛玻璃输入框
   - 浅色主色调填充
   - 圆角边框

### 基础组件

1. **SerenePrimaryButton** - 主要按钮
   - 主容器色背景
   - 16px 圆角

2. **SereneSecondaryButton** - 次要按钮
   - 毛玻璃效果
   - 白色边框

3. **SereneIconButton** - 图标按钮
   - 圆形毛玻璃容器
   - 中性图标

4. **SereneStatusChip** - 状态芯片
   - 大写标签
   - 可选脉冲动画

5. **SereneDataCard** - 数据展示卡片
   - 用于显示关键数据
   - 图标 + 数值 + 标签

6. **SereneQuickActionButton** - 快捷操作按钮
   - 图标 + 标签
   - 用于首页功能入口

7. **SereneVideoOverlay** - 视频覆盖控制
   - 实时状态指示
   - 对讲/截图按钮

8. **SereneAIStatusIndicator** - AI 状态指示器
   - 脉冲点动画
   - 温度显示

## 使用方法

### 导入设计系统

```dart
import '../theme/serene_design_system.dart';
```

### 使用主题

```dart
MaterialApp(
  theme: SereneTheme.lightTheme,
  // ...
)
```

### 使用组件

```dart
// 毛玻璃面板
GlassPanel(
  child: Text('Hello Glassmorphism'),
)

// 主要按钮
SerenePrimaryButton(
  text: 'Click Me',
  onPressed: () {},
)

// 数据卡片
SereneDataCard(
  title: 'Heart Rate',
  value: '120',
  unit: 'bpm',
  icon: Icons.favorite,
)
```

## 最佳实践

1. **背景**: 使用 `SereneColors.backgroundGradient` 作为页面背景
2. **卡片**: 使用 `GlassCard` 或 `GlassPanel` 包装内容
3. **按钮**: 优先使用 `SerenePrimaryButton` 或 `SereneSecondaryButton`
4. **状态**: 使用 `SereneStatusChip` 显示状态信息
5. **数据**: 使用 `SereneDataCard` 展示关键数据

## 示例

参考 `serene_home_page.dart` 查看完整的使用示例。
