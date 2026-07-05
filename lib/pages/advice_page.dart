import 'package:flutter/material.dart';
import '../services/rag_service.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({Key? key}) : super(key: key);

  @override
  _AdvicePageState createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  final RagService _ragService = RagService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _selectedCategory = 'general';

  final List<String> _categories = [
    'general',
    'sleep',
    'feeding',
    'safety',
    'health',
    'development',
  ];

  final Map<String, String> _categoryNames = {
    'general': 'All',
    'sleep': 'Sleep',
    'feeding': 'Feeding',
    'safety': 'Safety',
    'health': 'Health',
    'development': 'Development',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchKnowledge() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter search content'),
          backgroundColor: SereneColors.primary,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final result = await _ragService.searchKnowledge(
        query: query,
        category: _selectedCategory == 'general' ? null : _selectedCategory,
      );

      if (result['success'] == true) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(result['results'] ?? []);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${result['error']}'),
            backgroundColor: SereneColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search error: $e'),
          backgroundColor: SereneColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Expert Advice',
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
            // 主内容
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
                  // 搜索区域
                  _buildSearchSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 结果列表
                  if (_isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(SereneSpacing.xl),
                        child: CircularProgressIndicator(
                          color: SereneColors.primary,
                        ),
                      ),
                    )
                  else if (_searchResults.isNotEmpty)
                    _buildSearchResults()
                  else
                    _buildDefaultAdviceCards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索区域
  Widget _buildSearchSection() {
    return Column(
      children: [
        // 搜索框
        Container(
          decoration: BoxDecoration(
            color: SereneColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
            border: Border.all(
              color: SereneColors.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: SereneSpacing.md),
                child: Icon(
                  Icons.search,
                  color: SereneColors.outline,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _searchKnowledge(),
                  style: SereneTypography.bodyMedium.copyWith(
                    color: SereneColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search parenting advice...',
                    hintStyle: SereneTypography.bodyMedium.copyWith(
                      color: SereneColors.outline,
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
              Padding(
                padding: const EdgeInsets.only(right: SereneSpacing.sm),
                child: GestureDetector(
                  onTap: _isLoading ? null : _searchKnowledge,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SereneColors.primary,
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 18,
                      color: SereneColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SereneSpacing.md),
        // 筛选芯片
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: SereneSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SereneSpacing.md,
                      vertical: SereneSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? SereneColors.primaryContainer
                          : SereneColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : SereneColors.outlineVariant.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _categoryNames[category] ?? category,
                      style: SereneTypography.labelMedium.copyWith(
                        color: isSelected
                            ? SereneColors.onPrimaryContainer
                            : SereneColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        const SizedBox(height: SereneSpacing.md),
        ..._searchResults.map((result) {
          final content = result['content'] ?? '';
          final metadata = result['metadata'] ?? {};
          final score = result['score'] ?? 0.0;
          final source = metadata['source'] ?? 'Unknown Source';

          return Padding(
            padding: const EdgeInsets.only(bottom: SereneSpacing.md),
            child: _buildAdviceCard(
              title: source,
              content: content,
              source: source,
              score: score,
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 构建默认建议卡片
  Widget _buildDefaultAdviceCards() {
    final List<Map<String, String>> defaultAdvice = [
      {
        'title': 'Safe Sleep Positions',
        'content': 'Always place your baby on their back to sleep, for naps and at night, to reduce the risk of SIDS.',
        'source': 'AAP Guidelines',
      },
      {
        'title': 'Starting Solid Foods',
        'content': 'Signs your baby is ready for solids include sitting up with minimal support and showing interest in your food.',
        'source': 'Nutritionist',
      },
      {
        'title': 'Tummy Time Tips',
        'content': 'Start with brief sessions of tummy time a few times a day when your baby is awake and alert.',
        'source': 'Physical Therapy',
      },
      {
        'title': 'Managing Fever',
        'content': 'Learn when a fever is a sign of normal immune response versus when to contact your healthcare provider immediately.',
        'source': 'Pediatrician',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Advice',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        const SizedBox(height: SereneSpacing.md),
        ...defaultAdvice.map((advice) {
          return Padding(
            padding: const EdgeInsets.only(bottom: SereneSpacing.md),
            child: _buildAdviceCard(
              title: advice['title']!,
              content: advice['content']!,
              source: advice['source']!,
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 构建建议卡片
  Widget _buildAdviceCard({
    required String title,
    required String content,
    required String source,
    double? score,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: SereneTypography.headlineSmall.copyWith(
                    color: SereneColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SereneColors.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
                ),
                child: Text(
                  source,
                  style: SereneTypography.labelMedium.copyWith(
                    color: SereneColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            content,
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SereneSpacing.md),
          Row(
            children: [
              Text(
                'Read more',
                style: SereneTypography.labelMedium.copyWith(
                  color: SereneColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: SereneColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
