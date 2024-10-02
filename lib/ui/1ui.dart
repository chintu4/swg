import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:clipboard/clipboard.dart';
import 'package:http/http.dart' as http;

class ChatGPTLikeUI extends StatefulWidget {
  const ChatGPTLikeUI({super.key});

  @override
  _ChatGPTLikeUIState createState() => _ChatGPTLikeUIState();
}

class _ChatGPTLikeUIState extends State<ChatGPTLikeUI> {
  final List<String> _conversationHistory = [];
  final TextEditingController _inputController = TextEditingController();
  final String _apiKey =
      'AIzaSyBBeYUQvva-CDGJUZa7VFZTSLrxEDzViCQ'; // Replace with your actual API key
  bool _isLoading = false;

  // Function to check for updates (Dummy implementation)
  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking for updates...')),
    );
    // Simulate update check (replace this with actual update logic)
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App is up-to-date!')),
      );
    });
  }

  // Function to show Developer Info
  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Developer Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Name: Chintu Sharma'),
              Text('Twitter: @chintus179'),
              Text('GitHub: github.com/chintu4'),
              Text('LinkedIn: linkedin.com/in/chintu-sharma'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() async {
    setState(() {
      _isLoading = true;
    });

    final String userInput = _inputController.text;
    final String url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Updated API request body to match the working cURL request
    final Map<String, dynamic> data = {
      'contents': [
        {
          'parts': [
            {
              'text': userInput,
            }
          ]
        }
      ]
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String responseText = _extractResponseText(responseData);

        setState(() {
          _conversationHistory.add('User: $userInput');
          _conversationHistory.add('AI: $responseText');
          Markdown(data: _conversationHistory.last);
          _inputController.clear();
          _isLoading = false;
        });
      } else {
        _showErrorMessage('Error: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      _showErrorMessage('Error: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _extractResponseText(Map<String, dynamic> responseData) {
    String responseText = '';

    if (responseData.containsKey('candidates')) {
      final List<dynamic> candidates = responseData['candidates'];
      if (candidates.isNotEmpty) {
        final Map<String, dynamic> content = candidates[0]['content'];
        if (content.containsKey('parts') && content['parts'].isNotEmpty) {
          responseText = content['parts'][0]['text'];
        }
      }
    }

    return responseText;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT-like UI'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Developer Info'),
              onTap: _showDeveloperInfo,
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Check for Updates'),
              onTap: _checkForUpdates,
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Close Drawer'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _conversationHistory.length,
              itemBuilder: (context, index) {
                final String message = _conversationHistory[index];
                final bool isCode =
                    message.startsWith('```') && message.endsWith('```');

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: index % 2 == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isCode
                                  ? Colors.grey[200]
                                  : index % 2 == 0
                                      ? Colors.blue[100]
                                      : Colors.green[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isCode
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MarkdownBody(
                                        data: message,
                                        styleSheet: MarkdownStyleSheet(
                                          code: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'monospace',
                                            backgroundColor: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.copy),
                                          tooltip: 'Copy code to clipboard',
                                          onPressed: () {
                                            final String pureCode = message
                                                .replaceAll('```', '')
                                                .trim();
                                            FlutterClipboard.copy(pureCode).then(
                                                (value) => ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            "Code copied to clipboard!"))));
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : MarkdownBody(
                                    data: message,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                          ),
                        ),
                        if (!isCode)
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy text to clipboard',
                            onPressed: () {
                              FlutterClipboard.copy(message).then((value) =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Text copied to clipboard!"))));
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    maxLines: 5,
                    minLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
