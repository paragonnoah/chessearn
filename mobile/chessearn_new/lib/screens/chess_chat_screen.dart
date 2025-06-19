import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:chessearn_new/theme.dart';

class ChessChatScreen extends StatefulWidget {
  final String currentUserName;
  final String opponentName;

  const ChessChatScreen({
    super.key,
    required this.currentUserName,
    required this.opponentName,
  });

  @override
  State<ChessChatScreen> createState() => _ChessChatScreenState();
}

class _ChessChatScreenState extends State<ChessChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [
    {'sender': 'You', 'text': 'Hi! 👋'},
    {'sender': 'Opponent', 'text': 'Hey! Ready to play?'},
  ];
  bool _showEmojiPicker = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add({'sender': 'You', 'text': text});
      _controller.clear();
      _showEmojiPicker = false;
    });
    // Simulate opponent reply (remove if using real backend)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        messages.add({'sender': widget.opponentName, 'text': '👍'});
      });
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessEarnTheme.themeColors['background-dark'],
      appBar: AppBar(
        backgroundColor: ChessEarnTheme.themeColors['brand-dark'],
        title: Row(
          children: [
            const Icon(Icons.forum, color: Colors.white),
            const SizedBox(width: 8),
            Text("Chat with ${widget.opponentName}"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['sender'] == 'You' || msg['sender'] == widget.currentUserName;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser) ...[
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? ChessEarnTheme.themeColors['brand-accent']
                                  : ChessEarnTheme.themeColors['surface-dark'],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 0),
                                bottomRight: Radius.circular(isUser ? 0 : 16),
                              ),
                            ),
                            child: Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : ChessEarnTheme.themeColors['text-light'],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 6),
                          const CircleAvatar(child: Icon(Icons.person_outline)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input + emoji
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      color: ChessEarnTheme.themeColors['brand-accent'],
                      onPressed: () {
                        setState(() => _showEmojiPicker = !_showEmojiPicker);
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          filled: true,
                          fillColor: ChessEarnTheme.themeColors['surface-dark'],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        onTap: () => setState(() => _showEmojiPicker = false),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: ChessEarnTheme.themeColors['brand-accent'],
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
                Offstage(
                  offstage: !_showEmojiPicker,
                  child: SizedBox(
                    height: 300,
                    child: EmojiPicker(
                      textEditingController: _controller,
                      onEmojiSelected: (category, emoji) {
                        _controller
                          ..text += emoji.emoji
                          ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length));
                      },
                      // Remove config or use empty Config if required
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}