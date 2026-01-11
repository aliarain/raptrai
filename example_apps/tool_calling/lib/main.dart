import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tool Calling',
      theme: RaptrAITheme.light(),
      darkTheme: RaptrAITheme.dark(),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final RaptrAIToolRegistry _toolRegistry;

  @override
  void initState() {
    super.initState();
    _toolRegistry = RaptrAIToolRegistry();
    _registerTools();
  }

  void _registerTools() {
    // Weather tool using builder API
    final weatherTool = RaptrAIToolBuilder('get_weather')
        .description('Get the current weather for a location')
        .addStringParam('location', description: 'City name (e.g., "San Francisco")', required: true)
        .handler((args) async {
          final location = args['location'] as String;
          await Future.delayed(const Duration(milliseconds: 500));
          return {
            'location': location,
            'temperature': 72,
            'unit': 'fahrenheit',
            'condition': 'sunny',
          };
        })
        .build();

    // Calculator tool using builder API
    final calculatorTool = RaptrAIToolBuilder('calculate')
        .description('Perform a mathematical calculation')
        .addStringParam('expression', description: 'Math expression (e.g., "2 + 2")', required: true)
        .handler((args) async {
          final expr = args['expression'] as String;
          try {
            final result = _evaluateSimple(expr);
            return {'result': result, 'expression': expr};
          } catch (e) {
            return {'error': 'Could not evaluate: $expr'};
          }
        })
        .build();

    _toolRegistry.register(weatherTool);
    _toolRegistry.register(calculatorTool);
  }

  double _evaluateSimple(String expr) {
    // Very basic: handles "a + b", "a - b", "a * b", "a / b"
    final parts = expr.split(RegExp(r'\s*([+\-*/])\s*'));
    if (parts.length >= 2) {
      final a = double.parse(parts[0].trim());
      final op = expr.contains('+') ? '+' : expr.contains('-') ? '-' : expr.contains('*') ? '*' : '/';
      final b = double.parse(parts.last.trim());
      switch (op) {
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '/': return a / b;
      }
    }
    throw const FormatException('Invalid expression');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tool Calling Demo')),
      body: RaptrAIChat(
        provider: RaptrAIOpenAI(apiKey: 'sk-your-api-key'),
        tools: _toolRegistry.definitions,
        toolRegistry: _toolRegistry,
        systemPrompt: 'You are a helpful assistant with access to weather and calculator tools. Use them when appropriate.',
        welcomeGreeting: 'Hi! I can help with weather and calculations.',
        welcomeSubtitle: 'Try asking about the weather or a math problem.',
        suggestions: const [
          RaptrAISuggestion(title: 'Weather in', subtitle: 'San Francisco'),
          RaptrAISuggestion(title: 'Calculate', subtitle: '42 * 3.14'),
        ],
      ),
    );
  }
}
