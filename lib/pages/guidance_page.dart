import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  // 视频关键词映射到 BV 号（可以扩展更多）
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
    print("🧩 拼接后的 WebSocket URL：$authUrl");
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

  Widget _buildVideoSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _videoSearchController,
                  decoration: const InputDecoration(
                    hintText: "搜索视频，例如：辅食、睡眠、早教",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  onSubmitted: _searchVideo,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchVideo(_videoSearchController.text),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showVideo = !_showVideo;
                  });
                },
                child: Text(_showVideo ? "隐藏视频" : "显示视频"),
              )
            ],
          ),
        ),
        if (_showVideo)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
      ],
    );
  }

  Widget _buildChatMessages() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: _messages.map((msg) {
        final isUser = msg["role"] == "user";
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.deepPurple[100] : Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg["content"] ?? ''),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: "请输入育儿问题...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(_controller.text),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetQuestionDropdown() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Text("快速提问：", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            hint: const Text("选择常见问题"),
            items: presetQuestions.map((q) {
              return DropdownMenuItem(value: q, child: Text(q));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _controller.text = value;
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📘 育儿指南", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              _buildPresetQuestionDropdown(),
              _buildVideoSection(),
              const Divider(),
              Expanded(child: _buildChatMessages()),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              _buildInputBar(),
            ],
          ),
        ],
      ),
    );
  }
}
