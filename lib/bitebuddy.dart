import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'bite_buddy_service.dart';

class BiteBuddyChatScreen extends StatefulWidget {
  const BiteBuddyChatScreen({super.key});

  @override
  State<BiteBuddyChatScreen> createState() => _BiteBuddyChatScreenState();
}

class _BiteBuddyChatScreenState extends State<BiteBuddyChatScreen> {
  final _user = const types.User(id: 'user_1');
  final _bot = const types.User(id: 'bitebuddy_bot', firstName: 'BiteBuddy');
  final BiteBuddyEngine _engine = BiteBuddyEngine();
  final List<types.Message> _messages = [];

  final Color lightPeach = const Color(0xFFFFF1DC);

  Timer? _typingTimer;
  bool _isBotTyping = false;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _engine.loadKnowledge().then((_) {
      _addBotMessage(
        "Hello! I am BiteBuddy, your recipe assistant. What can I help you cook today?",
      );
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _addBotMessage(String text) {
    final message = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void _addUserMessage(String text) {
    final message = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void _startTypingAnimation() {
    _isBotTyping = true;
    _dotCount = 1;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isBotTyping) return;

      _dotCount = (_dotCount % 3) + 1;
      final dots = '.' * _dotCount;

      final typingMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: 'typing',
        text: 'Typing$dots',
      );

      setState(() {
        _messages.removeWhere((m) => m.id == 'typing');
        _messages.insert(0, typingMessage);
      });
    });
  }

  void _stopTypingAnimation() {
    _typingTimer?.cancel();
    _typingTimer = null;
    _isBotTyping = false;

    setState(() {
      _messages.removeWhere((m) => m.id == 'typing');
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final userText = message.text;
    _addUserMessage(userText);

    if (_isBotTyping) return;

    _startTypingAnimation();

    // ⏱️ Fixed 3-second delay
    await Future.delayed(const Duration(seconds: 3));

    _stopTypingAnimation();

    final botReply = _engine.getFuzzyResponse(userText);
    _addBotMessage(botReply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPeach,

      // 🖤 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '🍴 BiteBuddy Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
      ),

      // 💬 CHAT UI
      body: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          theme: DefaultChatTheme(
            backgroundColor: lightPeach,
            inputBackgroundColor: Colors.white,
            inputTextColor: Colors.black,
            sendButtonIcon: const Icon(
              Icons.send_rounded,
              color: Color(0xFFFF69B4),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
