import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:my_first_app/generated/l10n.dart';

class FaqPage extends ConsumerStatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends ConsumerState<FaqPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  WebSocketChannel? _channel;
  bool _isLoading = false;

  final String appId = "59944ba0";
  final String apiKey = "b6a6e9b81e99352a3fa23b768cb05bc6";
  final String apiSecret = "NGUzMDY1OWE4NzNiYmRlZWViYTliZWQ0";

  final ScrollController _scrollController = ScrollController();

  String _selectedModel = "4.0Ultra";
  final Map<String, String> _modelEndpoints = {
    "4.0Ultra": "wss://spark-api.xf-yun.com/v4.0/chat",
    "lite": "wss://spark-api.xf-yun.com/v1.1/chat",
  };

  @override
  void dispose() {
    _controller.dispose();
    _channel?.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add({"role": "user", "content": text});
    });

    _controller.clear();

    final sparkUrl = _modelEndpoints[_selectedModel]!;
    String authUrl = _buildAuthUrl(sparkUrl);

    _channel = WebSocketChannel.connect(Uri.parse(authUrl));

    final requestPayload = json.encode({
      "header": {
        "app_id": appId,
        "uid": "user_${Random().nextInt(99999)}"
      },
      "parameter": {
        "chat": {
          "domain": _selectedModel,
          "temperature": 0.5,
          "max_tokens": 1024
        }
      },
      "payload": {
        "message": {
          "text": [
            {"role": "user", "content": text}
          ]
        }
      }
    });

    print("Sending Request Payload: $requestPayload");

    _channel!.sink.add(requestPayload);

    StringBuffer responseBuffer = StringBuffer();

    _channel!.stream.listen((event) {
      print("Received WebSocket Data: $event");

      final data = json.decode(event);
      final choices = data['payload']?['choices']?['text'];
      if (choices != null && choices.isNotEmpty) {
        responseBuffer.write(choices[0]['content']);
      }

      if (data['header']['status'] == 2) {
        setState(() {
          _messages.add({"role": "assistant", "content": responseBuffer.toString()});
          _isLoading = false;
        });
        _channel?.sink.close();
        _scrollToBottom();
      }
    }, onError: (error) {
      print("Error: $error");
      setState(() {
        _isLoading = false;
      });
    });
  }

  String _buildAuthUrl(String sparkUrl) {
    final date = HttpDate.format(DateTime.now().toUtc());

    final path = Uri.parse(sparkUrl).path;
    final signatureOrigin = "host: spark-api.xf-yun.com\ndate: $date\nGET $path HTTP/1.1";
    final signatureSha = Hmac(sha256, utf8.encode(apiSecret)).convert(utf8.encode(signatureOrigin));
    final signature = base64.encode(signatureSha.bytes);

    final authorizationOrigin =
        'api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signature"';
    final authorization = base64.encode(utf8.encode(authorizationOrigin));

    return "$sparkUrl?authorization=$authorization&date=${Uri.encodeComponent(date)}&host=spark-api.xf-yun.com";
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          S.of(context).faq,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text("模型选择：", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedModel,
                      items: _modelEndpoints.keys.map((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedModel = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              _buildPresetQuestions(),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._messages.map((msg) => Align(
                      alignment: msg["role"] == "user" ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: msg["role"] == "user" ? Colors.deepPurple[100] : Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg["content"] ?? ''),
                      ),
                    )),
                  ],
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: "请输入问题...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(_controller.text),
              color: Colors.blueAccent,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPresetQuestions() {
    final List<String> presetQuestions = [
      "孩子发烧怎么办？",
      "孩子不吃饭怎么办？",
      "如何教宝宝说话？",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          const Text("常见问题：", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            hint: const Text("选择一个问题"),
            value: null,
            items: presetQuestions.map((question) {
              return DropdownMenuItem<String>(
                value: question,
                child: Text(question),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _controller.text = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
