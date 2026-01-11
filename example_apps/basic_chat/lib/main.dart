import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Chat',
      theme: RaptrAITheme.light(),
      darkTheme: RaptrAITheme.dark(),
      themeMode: ThemeMode.system,
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RaptrAI Chat')),
      body: RaptrAIChat(
        // Replace with your API key
        provider: RaptrAIOpenAI(apiKey: 'sk-your-api-key'),
        // Or use Anthropic:
        // provider: RaptrAIAnthropic(apiKey: 'sk-ant-your-key'),
        // Or Google Gemini:
        // provider: RaptrAIGoogle(apiKey: 'your-gemini-key'),
        welcomeGreeting: 'Hello!',
        welcomeSubtitle: 'How can I help you today?',
        suggestions: const [
          RaptrAISuggestion(title: 'Write a poem', subtitle: 'about Flutter'),
          RaptrAISuggestion(title: 'Explain', subtitle: 'how AI works'),
          RaptrAISuggestion(title: 'Help me', subtitle: 'debug my code'),
        ],
      ),
    );
  }
}
