import 'registry.dart';

/// Tool calling template - AI chat with function calling.
final toolCallingTemplate = Template(
  name: 'tool-calling',
  description: 'AI chat with tool/function calling support',
  files: [
    TemplateFile(
      path: 'ai_chat/ai_chat_with_tools.dart',
      content: r'''import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

/// AI Chat with Tools - Function calling enabled.
///
/// Includes example tools: weather, calculator.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => const AIChatWithTools(),
/// ));
/// ```
class AIChatWithTools extends StatefulWidget {
  const AIChatWithTools({super.key});

  @override
  State<AIChatWithTools> createState() => _AIChatWithToolsState();
}

class _AIChatWithToolsState extends State<AIChatWithTools> {
  late final RaptrAIToolRegistry _toolRegistry;

  @override
  void initState() {
    super.initState();
    _toolRegistry = RaptrAIToolRegistry();
    _registerTools();
  }

  void _registerTools() {
    // Weather tool
    _toolRegistry.register(
      name: 'get_weather',
      description: 'Get the current weather for a location',
      parameters: {
        'location': RaptrAIToolParameter(
          type: RaptrAIToolParameterType.string,
          description: 'City name (e.g., "San Francisco")',
          required: true,
        ),
        'unit': RaptrAIToolParameter(
          type: RaptrAIToolParameterType.string,
          description: 'Temperature unit',
          required: false,
          enumValues: ['celsius', 'fahrenheit'],
        ),
      },
      handler: (args) async {
        final location = args['location'] as String;
        final unit = args['unit'] as String? ?? 'fahrenheit';

        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Return mock weather data
        return RaptrAIToolResult.success({
          'location': location,
          'temperature': unit == 'celsius' ? 22 : 72,
          'unit': unit,
          'condition': 'sunny',
          'humidity': 45,
        });
      },
    );

    // Calculator tool
    _toolRegistry.register(
      name: 'calculate',
      description: 'Perform mathematical calculations',
      parameters: {
        'expression': RaptrAIToolParameter(
          type: RaptrAIToolParameterType.string,
          description: 'Math expression to evaluate (e.g., "2 + 2")',
          required: true,
        ),
      },
      handler: (args) async {
        final expression = args['expression'] as String;

        try {
          // Simple expression parser (for demo)
          final result = _evaluateExpression(expression);
          return RaptrAIToolResult.success({
            'expression': expression,
            'result': result,
          });
        } catch (e) {
          return RaptrAIToolResult.error('Failed to evaluate: $e');
        }
      },
    );
  }

  double _evaluateExpression(String expr) {
    // Very basic expression evaluator for demo
    expr = expr.replaceAll(' ', '');

    // Handle basic operations
    if (expr.contains('+')) {
      final parts = expr.split('+');
      return double.parse(parts[0]) + double.parse(parts[1]);
    } else if (expr.contains('-')) {
      final parts = expr.split('-');
      return double.parse(parts[0]) - double.parse(parts[1]);
    } else if (expr.contains('*')) {
      final parts = expr.split('*');
      return double.parse(parts[0]) * double.parse(parts[1]);
    } else if (expr.contains('/')) {
      final parts = expr.split('/');
      return double.parse(parts[0]) / double.parse(parts[1]);
    }

    return double.parse(expr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_outlined),
            onPressed: () => _showToolsInfo(context),
          ),
        ],
      ),
      body: RaptrAIChat(
        // TODO: Replace with your API key
        provider: RaptrAIOpenAI(apiKey: 'YOUR_API_KEY'),
        model: 'gpt-4-turbo',
        systemPrompt: 'You are a helpful assistant with access to tools. '
            'You can check the weather and perform calculations. '
            'Always use the appropriate tool when the user asks about weather or math.',
        tools: _toolRegistry.getToolDefinitions(),
        toolRegistry: _toolRegistry,
        welcomeGreeting: 'Hello!',
        welcomeSubtitle: 'I can check weather and do math.',
        suggestions: const [
          RaptrAISuggestion(
            title: 'Weather',
            subtitle: 'What\'s the weather in Tokyo?',
          ),
          RaptrAISuggestion(
            title: 'Calculate',
            subtitle: 'What is 15% of 280?',
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

  void _showToolsInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Tools',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.cloud),
              title: Text('get_weather'),
              subtitle: Text('Get weather for any city'),
            ),
            const ListTile(
              leading: Icon(Icons.calculate),
              title: Text('calculate'),
              subtitle: Text('Evaluate math expressions'),
            ),
          ],
        ),
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

     import 'ai_chat/ai_chat_with_tools.dart';

     Navigator.push(context, MaterialPageRoute(
       builder: (_) => const AIChatWithTools(),
     ));

  3. Customize the tools in _registerTools() for your use case
''',
);
