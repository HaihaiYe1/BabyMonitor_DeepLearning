import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class GuidancePage extends ConsumerStatefulWidget {
  @override
  _GuidancePageState createState() => _GuidancePageState();
}

class _GuidancePageState extends ConsumerState<GuidancePage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _videoSearchController = TextEditingController();
  WebSocketChannel? _channel;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final String appId = "59944ba0";
  final String apiKey = "b6a6e9b81e99352a3fa23b768cb05bc6";
  final String apiSecret = "NGUzMDY1OWE4NzNiYmRlZWViYTliZWQ0";

  final List<String> presetQuestions = [
    "宝宝多大可以添加辅食？",
    "夜里频繁醒来正常吗？",
    "怎么培养宝宝睡眠规律？",
  ];

  bool _showVideo = true;

  late final WebViewController _webViewController;

  final Map<String, String> bilibiliEmbedMap = {
    "辅食": "BV1eb411k7ZX",
    "宝宝睡眠": "BV1ym411y7Pf",
    "早教": "BV1gm411b7FS",
    "育儿": "BV1eb411k7ZX",
  };

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://player.bilibili.com/player.html?bvid=BV1eb411k7ZX'));
  }

  void _searchVideo(String keyword) {
    String matchedKey = bilibiliEmbedMap.keys.firstWhere(
          (k) => keyword.contains(k),
      orElse: () => "育儿",
    );
    String bvId = bilibiliEmbedMap[matchedKey]!;
    String url = 'https://player.bilibili.com/player.html?bvid=$bvId';
    _webViewController.loadRequest(Uri.parse(url));
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add({"role": "user", "content": text});
    });

    _controller.clear();

    final sparkUrl = "wss://spark-api.xf-yun.com/v1.1/chat";
    String authUrl = _buildAuthUrl(sparkUrl);
    _channel = WebSocketChannel.connect(Uri.parse(authUrl));

    final requestPayload = json.encode({
      "header": {"app_id": appId, "uid": "user_${Random().nextInt(99999)}"},
      "parameter": {
        "chat": {"domain": "lite", "temperature": 0.5, "max_tokens": 1024}
      },
      "payload": {
        "message": {
          "text": [
            {"role": "user", "content": text}
          ]
        }
      }
    });

    _channel!.sink.add(requestPayload);

    StringBuffer responseBuffer = StringBuffer();

    _channel!.stream.listen((event) {
      final data = json.decode(event);
      final choices = data['payload']?['choices']?['text'];
      if (choices != null && choices.isNotEmpty) {
        responseBuffer.write(choices[0]['content']);
      }
      if (data['header']['status'] == 2) {
        setState(() {
          _messages.add(
              {"role": "assistant", "content": responseBuffer.toString()});
          _isLoading = false;
        });
        _channel?.sink.close();
        _scrollToBottom();
      }
    }, onError: (_) {
      setState(() => _isLoading = false);
    });
  }

  String _buildAuthUrl(String sparkUrl) {
    final date = HttpDate.format(DateTime.now().toUtc());
    final path = Uri.parse(sparkUrl).path;
    final signatureOrigin =
        "host: spark-api.xf-yun.com\ndate: $date\nGET $path HTTP/1.1";
    final signatureSha =
    Hmac(sha256, utf8.encode(apiSecret)).convert(utf8.encode(signatureOrigin));
    final signature = base64.encode(signatureSha.bytes);
    final authorizationOrigin =
        'api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signature"';
    final authorization = base64.encode(utf8.encode(authorizationOrigin));

    return "$sparkUrl?authorization=$authorization&date=${Uri.encodeComponent(date)}&host=spark-api.xf-yun.com";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
              color: SereneColors.primary,
            ),
          ),
        ),
        title: Text(
          'Parenting Guide',
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
            Column(
              children: [
                // 预设问题
                _buildPresetQuestions(),
                // 视频区域
                _buildVideoSection(),
                // 聊天消息
                Expanded(child: _buildChatMessages()),
                // 加载指示器
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(SereneSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SereneColors.primary,
                          ),
                        ),
                        const SizedBox(width: SereneSpacing.sm),
                        Text(
                          'Thinking...',
                          style: SereneTypography.bodySmall.copyWith(
                            color: SereneColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                // 输入框
                _buildInputBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建预设问题
  Widget _buildPresetQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Quick questions:',
            style: SereneTypography.labelLarge.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          const SizedBox(width: SereneSpacing.sm),
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: presetQuestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: SereneSpacing.sm),
                    child: GestureDetector(
                      onTap: () {
                        _controller.text = presetQuestions[index];
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SereneSpacing.md,
                          vertical: SereneSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: SereneColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                          border: Border.all(
                            color: SereneColors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          presetQuestions[index],
                          style: SereneTypography.labelMedium.copyWith(
                            color: SereneColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建视频区域
  Widget _buildVideoSection() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.sm,
      ),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 视频搜索
          Padding(
            padding: const EdgeInsets.all(SereneSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
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
                            Icons.search,
                            color: SereneColors.outline,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _videoSearchController,
                            onSubmitted: _searchVideo,
                            style: SereneTypography.bodyMedium.copyWith(
                              color: SereneColors.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search videos...',
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
                  ),
                ),
                const SizedBox(width: SereneSpacing.sm),
                // 搜索按钮
                GestureDetector(
                  onTap: () => _searchVideo(_videoSearchController.text),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SereneColors.primary,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: SereneColors.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: SereneSpacing.sm),
                // 显示/隐藏视频按钮
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showVideo = !_showVideo;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: SereneColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                    ),
                    child: Text(
                      _showVideo ? 'Hide' : 'Show',
                      style: SereneTypography.labelMedium.copyWith(
                        color: SereneColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 视频播放器
          if (_showVideo)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(SereneSpacing.radiusXl),
              ),
              child: SizedBox(
                height: 200,
                child: WebViewWidget(controller: _webViewController),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建聊天消息
  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.md,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg["role"] == "user";
        return _buildMessageBubble(
          content: msg["content"] ?? '',
          isUser: isUser,
        );
      },
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble({
    required String content,
    required bool isUser,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: SereneSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: isUser
            ? _buildUserMessage(content)
            : _buildBotMessage(content),
      ),
    );
  }

  /// 构建用户消息
  Widget _buildUserMessage(String content) {
    return Container(
      padding: const EdgeInsets.all(SereneSpacing.md),
      decoration: BoxDecoration(
        color: SereneColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(SereneSpacing.radiusXl),
          topRight: const Radius.circular(SereneSpacing.radiusXl),
          bottomLeft: const Radius.circular(SereneSpacing.radiusXl),
          bottomRight: const Radius.circular(SereneSpacing.radiusSm),
        ),
        boxShadow: [
          BoxShadow(
            color: SereneColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        content,
        style: SereneTypography.bodyMedium.copyWith(
          color: SereneColors.onPrimary,
        ),
      ),
    );
  }

  /// 构建AI消息
  Widget _buildBotMessage(String content) {
    return GlassPanel(
      padding: const EdgeInsets.all(SereneSpacing.md),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(SereneSpacing.radiusXl),
        topRight: Radius.circular(SereneSpacing.radiusXl),
        bottomLeft: Radius.circular(SereneSpacing.radiusSm),
        bottomRight: Radius.circular(SereneSpacing.radiusXl),
      ),
      child: Text(
        content,
        style: SereneTypography.bodyMedium.copyWith(
          color: SereneColors.onSurface,
        ),
      ),
    );
  }

  /// 构建输入框
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SereneSpacing.marginMobile,
        SereneSpacing.sm,
        SereneSpacing.marginMobile,
        SereneSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        color: SereneColors.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: SereneColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: SereneColors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                border: Border.all(
                  color: SereneColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: _sendMessage,
                style: SereneTypography.bodyMedium.copyWith(
                  color: SereneColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask a parenting question...',
                  hintStyle: SereneTypography.bodyMedium.copyWith(
                    color: SereneColors.outline,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SereneSpacing.md,
                    vertical: SereneSpacing.md,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: SereneSpacing.sm),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.primary,
              ),
              child: const Icon(
                Icons.send,
                size: 20,
                color: SereneColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
