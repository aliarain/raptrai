import 'registry.dart';

/// Basic chat template - minimal AI chat screen.
final basicChatTemplate = Template(
  name: 'basic-chat',
  description: 'Minimal AI chat screen with streaming responses',
  files: [
    TemplateFile(
      path: 'ai_chat/ai_chat_screen.dart',
      content: r'''import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

/// AI Chat Screen - Basic chat with streaming responses.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const AIChatScreen(),
/// ));
/// ```
class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Clear conversation
            },
          ),
        ],
      ),
      body: RaptrAIChat(
        // TODO: Replace with your API key
        provider: RaptrAIOpenAI(apiKey: 'YOUR_API_KEY'),
        model: 'gpt-4-turbo',
        systemPrompt: 'You are a helpful assistant.',
        welcomeGreeting: 'Hello!',
        welcomeSubtitle: 'How can I help you today?',
        suggestions: const [
          RaptrAISuggestion(
            title: 'Write code',
            subtitle: 'Help me build something',
          ),
          RaptrAISuggestion(
            title: 'Explain concept',
            subtitle: 'Teach me something new',
          ),
          RaptrAISuggestion(
            title: 'Brainstorm',
            subtitle: 'Help me think through ideas',
          ),
        ],
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
  2. Import and use the screen:

     import 'ai_chat/ai_chat_screen.dart';

     Navigator.push(context, MaterialPageRoute(
       builder: (_) => const AIChatScreen(),
     ));
''',
);
