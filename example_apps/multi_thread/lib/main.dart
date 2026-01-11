import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Thread Chat',
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
      body: RaptrAIChatWithSidebar(
        // Replace with your API key
        provider: RaptrAIOpenAI(apiKey: 'sk-your-api-key'),
        // Use memory storage (or RaptrAIHiveStorage for persistence)
        storage: RaptrAIMemoryStorage(),
        systemPrompt: 'You are a helpful assistant.',
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
