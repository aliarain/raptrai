import 'registry.dart';

/// Multi-thread template - AI chat with conversation history sidebar.
final multiThreadTemplate = Template(
  name: 'multi-thread',
  description: 'AI chat with conversation history and persistence',
  files: [
    TemplateFile(
      path: 'ai_chat/ai_chat_multi_thread.dart',
      content: r'''import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

/// AI Chat with Multiple Threads - Conversation history sidebar.
///
/// Features:
/// - Multiple conversation threads
/// - Persistent storage with Hive
/// - Conversation list sidebar
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const AIChatMultiThread(),
/// ));
/// ```
class AIChatMultiThread extends StatefulWidget {
  const AIChatMultiThread({super.key});

  @override
  State<AIChatMultiThread> createState() => _AIChatMultiThreadState();
}

class _AIChatMultiThreadState extends State<AIChatMultiThread> {
  late final RaptrAIHiveStorage _storage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = RaptrAIHiveStorage();
    await _storage.initialize();
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    if (_initialized) {
      _storage.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RaptrAIChatWithSidebar(
        // TODO: Replace with your API key
        provider: RaptrAIOpenAI(apiKey: 'YOUR_API_KEY'),
        model: 'gpt-4-turbo',
        systemPrompt: 'You are a helpful assistant.',
        storage: _storage,
        sidebarWidth: 280,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message)),
          );
        },
      ),
    );
  }
}

/// Compact version without sidebar - just the chat with persistence.
class AIChatPersistent extends StatefulWidget {
  const AIChatPersistent({
    super.key,
    this.conversationId,
  });

  /// Optional conversation ID to load.
  final String? conversationId;

  @override
  State<AIChatPersistent> createState() => _AIChatPersistentState();
}

class _AIChatPersistentState extends State<AIChatPersistent> {
  late final RaptrAIHiveStorage _storage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = RaptrAIHiveStorage();
    await _storage.initialize();
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    if (_initialized) {
      _storage.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
      ),
      body: RaptrAIChat(
        // TODO: Replace with your API key
        provider: RaptrAIOpenAI(apiKey: 'YOUR_API_KEY'),
        model: 'gpt-4-turbo',
        systemPrompt: 'You are a helpful assistant.',
        storage: _storage,
        conversationId: widget.conversationId,
        welcomeGreeting: 'Hello!',
        welcomeSubtitle: 'How can I help you today?',
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message)),
          );
        },
      ),
    );
  }
}
''',
    ),
  ],
  postInstall: '''
  1. Replace 'YOUR_API_KEY' with your OpenAI API key

  2. Add Hive to your pubspec.yaml if not already:
     dependencies:
       hive: ^2.2.3
       hive_flutter: ^1.1.0

  3. Initialize Hive in main.dart:
     await Hive.initFlutter();

  4. Use the widgets:

     // Full sidebar experience:
     Navigator.push(context, MaterialPageRoute(
       builder: (_) => const AIChatMultiThread(),
     ));

     // Or just persistent chat:
     Navigator.push(context, MaterialPageRoute(
       builder: (_) => const AIChatPersistent(),
     ));
''',
);
