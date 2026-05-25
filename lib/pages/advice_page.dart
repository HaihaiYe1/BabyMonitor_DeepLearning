import 'package:flutter/material.dart';
import '../services/rag_service.dart';
import '../generated/l10n.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({Key? key}) : super(key: key);

  @override
  _AdvicePageState createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  final RagService _ragService = RagService();
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _adviceResult;
  List<Map<String, dynamic>> _searchResults = [];
  String _selectedCategory = 'general';
  int? _babyAgeMonths;

  final List<String> _categories = [
    'general',
    'sleep',
    'feeding',
    'safety',
    'health',
    'development',
  ];

  final Map<String, String> _categoryNames = {
    'general': '通用',
    'sleep': '睡眠',
    'feeding': '喂养',
    'safety': '安全',
    'health': '健康',
    'development': '发育',
  };

  @override
  void dispose() {
    _situationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAdvice() async {
    final situation = _situationController.text.trim();
    if (situation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入情况描述')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _adviceResult = null;
    });

    try {
      final result = await _ragService.getAdvice(
        situation: situation,
        babyAgeMonths: _babyAgeMonths,
      );

      setState(() {
        _adviceResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取建议失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchKnowledge() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入搜索内容')),
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
          SnackBar(content: Text('搜索失败: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索异常: $e')),
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
      appBar: AppBar(
        title: Text(S.of(context).parenting_advice ?? '育儿建议'),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdviceSection(),
              const SizedBox(height: 24),
              _buildSearchSection(),
              const SizedBox(height: 24),
              if (_adviceResult != null) _buildAdviceResult(),
              if (_searchResults.isNotEmpty) _buildSearchResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdviceSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  '获取育儿建议',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _situationController,
              decoration: InputDecoration(
                labelText: '情况描述',
                hintText: '例如：宝宝晚上总是哭闹...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: '婴儿月龄（可选）',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    value: _babyAgeMonths,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('不指定')),
                      ...List.generate(24, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}个月'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _babyAgeMonths = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getAdvice,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('获取建议'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '搜索知识库',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: '搜索内容',
                      hintText: '例如：婴儿睡眠...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchKnowledge,
                  icon: const Icon(Icons.search),
                  label: const Text('搜索'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
                return ChoiceChip(
                  label: Text(_categoryNames[category] ?? category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceResult() {
    final success = _adviceResult!['success'] == true;
    final result = _adviceResult!['result'] ?? {};
    final advice = result['advice'] ?? {};
    final retrievedKnowledge = result['retrieved_knowledge'] ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  '育儿建议',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (advice['generated_advice'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  advice['generated_advice'],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            if (retrievedKnowledge.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '参考知识',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...retrievedKnowledge.take(3).map((knowledge) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    knowledge['content'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  '搜索结果',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._searchResults.map((result) {
              final content = result['content'] ?? '';
              final metadata = result['metadata'] ?? {};
              final score = result['score'] ?? 0.0;
              final source = metadata['source'] ?? '未知来源';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.source, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            source,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(score * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
