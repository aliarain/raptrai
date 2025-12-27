import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

void main() {
  // Configure analytics for debugging
  RaptrAIAnalytics.configure(
    onEvent: (event) {
      debugPrint('[Analytics] ${event.name}: ${event.toJson()}');
    },
    enabled: true,
  );

  runApp(const RaptrAIExampleApp());
}

// =============================================================================
// MOCK PROVIDER - Simulates AI responses with streaming
// =============================================================================

class MockAIProvider extends RaptrAIProvider {
  MockAIProvider({this.responseDelay = const Duration(milliseconds: 50)});

  final Duration responseDelay;
  bool _isCancelled = false;

  static const _responses = [
    "I'd be happy to help you with that! Let me think about this for a moment.\n\nBased on my analysis, here are some key points to consider:\n\n1. **First Point**: This is an important consideration that affects the overall outcome.\n\n2. **Second Point**: You might want to look into this aspect as well.\n\n3. **Third Point**: Finally, don't forget about this crucial element.\n\nIs there anything specific you'd like me to elaborate on?",
    "That's a great question! Here's what I can tell you:\n\n```dart\n// Example code snippet\nclass Example {\n  void doSomething() {\n    print('Hello, World!');\n  }\n}\n```\n\nThis demonstrates the basic structure you might use. Would you like me to explain any part in more detail?",
    "Let me break this down for you:\n\n## Overview\nThis topic involves several interconnected concepts that work together.\n\n## Key Concepts\n- **Concept A**: The foundation of everything\n- **Concept B**: Builds upon A to add functionality\n- **Concept C**: The practical application\n\n## Conclusion\nUnderstanding these relationships is crucial for effective implementation.",
    "I've analyzed your request and here's my response:\n\nThe solution involves a few steps:\n\n1. First, you'll need to set up the basic structure\n2. Then, implement the core logic\n3. Finally, add error handling and edge cases\n\nWould you like me to provide more specific guidance on any of these steps?",
    "Thanks for asking! RaptrAI is a comprehensive Flutter framework for building AI-powered applications. It includes:\n\n- **60+ UI Components** - Beautiful, composable widgets\n- **Multi-Provider Support** - OpenAI, Anthropic, Google\n- **Conversation Management** - With branching support\n- **Tool/Function Calling** - Register and execute tools\n- **Persistence Layer** - Offline-first with cloud sync\n- **Business Features** - Usage tracking, analytics\n\nThe library follows a modern design aesthetic with a zinc color palette.",
  ];

  @override
  String get name => 'Mock AI';

  @override
  String get id => 'mock';

  @override
  String get defaultModel => 'mock-gpt-4';

  @override
  List<RaptrAIModelInfo> get availableModels => const [
        RaptrAIModelInfo(
          id: 'mock-gpt-4',
          name: 'Mock GPT-4',
          description: 'Simulated GPT-4 responses',
          contextWindow: 128000,
          supportsVision: true,
          supportsTools: true,
          inputPricePerMillion: 10.0,
          outputPricePerMillion: 30.0,
        ),
        RaptrAIModelInfo(
          id: 'mock-gpt-3.5',
          name: 'Mock GPT-3.5',
          description: 'Simulated GPT-3.5 responses',
          contextWindow: 16000,
          supportsVision: false,
          supportsTools: true,
          inputPricePerMillion: 0.5,
          outputPricePerMillion: 1.5,
        ),
        RaptrAIModelInfo(
          id: 'mock-claude',
          name: 'Mock Claude',
          description: 'Simulated Claude responses',
          contextWindow: 200000,
          supportsVision: true,
          supportsTools: true,
          inputPricePerMillion: 3.0,
          outputPricePerMillion: 15.0,
        ),
      ];

  @override
  Stream<RaptrAIChunk> chat({
    required List<RaptrAIMessage> messages,
    required String model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig config = RaptrAIChatConfig.defaults,
  }) async* {
    _isCancelled = false;

    // Simulate initial delay
    await Future.delayed(const Duration(milliseconds: 300));
    if (_isCancelled) return;

    // Check if tools are available and should be called
    if (tools != null && tools.isNotEmpty) {
      final lastMessage = messages.lastWhere((m) => m.role == RaptrAIRole.user);
      final content = lastMessage.content.toLowerCase();

      // Check for weather tool trigger
      if (content.contains('weather')) {
        yield const RaptrAIChunk(
          content: "Let me check the weather for you.\n\n",
        );
        await Future.delayed(const Duration(milliseconds: 200));

        yield RaptrAIChunk(
          toolCalls: [
            const RaptrAIToolCallDelta(
              index: 0,
              id: 'call_weather_1',
              name: 'get_weather',
              argumentsDelta: '{"location": "San Francisco", "unit": "celsius"}',
            ),
          ],
          finishReason: RaptrAIFinishReason.toolCalls,
        );
        return;
      }

      // Check for calculator tool trigger
      if (content.contains('calculate') || content.contains('math')) {
        yield const RaptrAIChunk(
          content: "Let me calculate that for you.\n\n",
        );
        await Future.delayed(const Duration(milliseconds: 200));

        yield RaptrAIChunk(
          toolCalls: [
            const RaptrAIToolCallDelta(
              index: 0,
              id: 'call_calc_1',
              name: 'calculator',
              argumentsDelta: '{"expression": "2 + 2 * 3"}',
            ),
          ],
          finishReason: RaptrAIFinishReason.toolCalls,
        );
        return;
      }

      // Check for search tool trigger
      if (content.contains('search') || content.contains('find')) {
        yield const RaptrAIChunk(
          content: "Let me search for that information.\n\n",
        );
        await Future.delayed(const Duration(milliseconds: 200));

        yield RaptrAIChunk(
          toolCalls: [
            const RaptrAIToolCallDelta(
              index: 0,
              id: 'call_search_1',
              name: 'web_search',
              argumentsDelta: '{"query": "Flutter best practices 2025"}',
            ),
          ],
          finishReason: RaptrAIFinishReason.toolCalls,
        );
        return;
      }
    }

    // Select a random response
    final random = Random();
    final response = _responses[random.nextInt(_responses.length)];

    // Stream the response character by character
    final promptTokens = messages.fold<int>(0, (sum, m) => sum + m.content.length ~/ 4);

    for (int i = 0; i < response.length; i++) {
      if (_isCancelled) return;

      yield RaptrAIChunk(content: response[i]);
      await Future.delayed(responseDelay);
    }

    // Final chunk with usage
    yield RaptrAIChunk(
      finishReason: RaptrAIFinishReason.stop,
      usage: RaptrAIUsage(
        promptTokens: promptTokens,
        completionTokens: response.length ~/ 4,
        totalTokens: promptTokens + response.length ~/ 4,
      ),
    );
  }

  @override
  void cancel() {
    _isCancelled = true;
  }

  @override
  Future<int> countTokens(List<RaptrAIMessage> messages, {String? model}) async {
    return messages.fold<int>(0, (sum, m) => sum + m.content.length ~/ 4);
  }

  @override
  Future<bool> validate() async => true;
}

// =============================================================================
// MOCK STORAGE - In-memory storage implementation
// =============================================================================

class MockStorage extends RaptrAIStorage with RaptrAIStorageNotifier {
  final Map<String, RaptrAIConversation> _conversations = {};
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Add some sample conversations
    final now = DateTime.now();
    _conversations['conv_sample_1'] = RaptrAIConversation(
      id: 'conv_sample_1',
      title: 'Welcome Chat',
      messages: [
        RaptrAIConversationMessage.user('Hello! What can you do?'),
        RaptrAIConversationMessage.assistant(
          'Hi! I\'m RaptrAI assistant. I can help you with coding, answer questions, and much more!',
        ),
      ],
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    _conversations['conv_sample_2'] = RaptrAIConversation(
      id: 'conv_sample_2',
      title: 'Flutter Tips',
      messages: [
        RaptrAIConversationMessage.user('Give me some Flutter performance tips'),
        RaptrAIConversationMessage.assistant(
          'Here are some Flutter performance tips:\n\n1. Use const constructors\n2. Implement ListView.builder for long lists\n3. Cache expensive computations\n4. Use RepaintBoundary wisely',
        ),
      ],
      createdAt: now.subtract(const Duration(hours: 5)),
      updatedAt: now.subtract(const Duration(hours: 5)),
    );

    _isInitialized = true;
  }

  @override
  Future<void> close() async {
    closeEventController();
  }

  @override
  Future<void> saveConversation(RaptrAIConversation conversation) async {
    final isNew = !_conversations.containsKey(conversation.id);
    _conversations[conversation.id] = conversation;

    emitEvent(RaptrAIStorageEvent(
      type: isNew ? RaptrAIStorageEventType.created : RaptrAIStorageEventType.updated,
      conversationId: conversation.id,
      conversation: conversation,
    ));
  }

  @override
  Future<RaptrAIConversation?> loadConversation(String id) async {
    return _conversations[id];
  }

  @override
  Future<RaptrAIConversationList> listConversations({
    int limit = 20,
    String? cursor,
    String? userId,
  }) async {
    final sorted = _conversations.values.toList()
      ..sort((a, b) => (b.updatedAt ?? DateTime.now()).compareTo(a.updatedAt ?? DateTime.now()));

    return RaptrAIConversationList(
      conversations: sorted.take(limit).toList(),
      hasMore: sorted.length > limit,
      totalCount: sorted.length,
    );
  }

  @override
  Future<void> deleteConversation(String id) async {
    _conversations.remove(id);
    emitEvent(RaptrAIStorageEvent(
      type: RaptrAIStorageEventType.deleted,
      conversationId: id,
    ));
  }

  @override
  Future<void> deleteAllConversations({String? userId}) async {
    _conversations.clear();
  }

  @override
  Stream<RaptrAIConversation> watchConversation(String id) {
    return events
        .where((e) => e.conversationId == id && e.conversation != null)
        .map((e) => e.conversation!);
  }

  @override
  Stream<RaptrAIConversationList> watchConversations({int limit = 20, String? userId}) {
    return events.asyncMap((_) => listConversations(limit: limit, userId: userId));
  }

  @override
  Future<List<RaptrAIConversation>> searchConversations(String query, {int limit = 20, String? userId}) async {
    final lowerQuery = query.toLowerCase();
    return _conversations.values
        .where((c) =>
            (c.title?.toLowerCase().contains(lowerQuery) ?? false) ||
            c.messages.any((m) => m.content.toLowerCase().contains(lowerQuery)))
        .take(limit)
        .toList();
  }

  @override
  Future<bool> conversationExists(String id) async {
    return _conversations.containsKey(id);
  }

  @override
  Future<int> getConversationCount({String? userId}) async {
    return _conversations.length;
  }

  @override
  Future<String> exportAllConversations({String? userId}) async {
    return _conversations.values.map((c) => c.toJson()).toString();
  }

  @override
  Future<void> importConversations(String json, {bool overwrite = false}) async {
    // Not implemented for mock
  }
}

// =============================================================================
// MOCK TOOLS - Sample tool implementations
// =============================================================================

RaptrAIToolRegistry createMockToolRegistry() {
  final registry = RaptrAIToolRegistry();

  // Weather tool
  registry.register(
    RaptrAIToolBuilder('get_weather')
        .description('Get current weather for a location')
        .addStringParam('location', description: 'City name', required: true)
        .addEnumParam('unit', ['celsius', 'fahrenheit'], defaultValue: 'celsius')
        .handler((args) async {
          await Future.delayed(const Duration(seconds: 1));
          final location = args['location'] as String;
          final unit = args['unit'] as String? ?? 'celsius';
          final random = Random();
          final temp = unit == 'celsius' ? 15 + random.nextInt(20) : 60 + random.nextInt(35);
          final conditions = ['sunny', 'cloudy', 'rainy', 'partly cloudy'];
          return {
            'location': location,
            'temperature': temp,
            'unit': unit,
            'condition': conditions[random.nextInt(conditions.length)],
            'humidity': 40 + random.nextInt(40),
            'wind_speed': 5 + random.nextInt(20),
          };
        })
        .build(),
  );

  // Calculator tool
  registry.register(
    RaptrAIToolBuilder('calculator')
        .description('Perform mathematical calculations')
        .addStringParam('expression', description: 'Math expression to evaluate', required: true)
        .handler((args) async {
          await Future.delayed(const Duration(milliseconds: 500));
          final expression = args['expression'] as String;
          // Simple evaluation (in production, use a proper math parser)
          try {
            // This is a mock - just return a plausible result
            final result = 8; // 2 + 2 * 3 = 8
            return {
              'expression': expression,
              'result': result,
              'formatted': '$expression = $result',
            };
          } catch (e) {
            return {
              'expression': expression,
              'error': 'Could not evaluate expression',
            };
          }
        })
        .build(),
  );

  // Web search tool
  registry.register(
    RaptrAIToolBuilder('web_search')
        .description('Search the web for information')
        .addStringParam('query', description: 'Search query', required: true)
        .addIntegerParam('max_results', description: 'Maximum results', defaultValue: 5)
        .handler((args) async {
          await Future.delayed(const Duration(seconds: 1));
          final query = args['query'] as String;
          return {
            'query': query,
            'results': [
              {
                'title': 'Flutter Documentation',
                'url': 'https://flutter.dev/docs',
                'snippet': 'Official Flutter documentation and guides.',
              },
              {
                'title': 'Dart Language Tour',
                'url': 'https://dart.dev/guides/language/language-tour',
                'snippet': 'A tour of all the major Dart language features.',
              },
              {
                'title': 'Flutter Best Practices 2025',
                'url': 'https://example.com/flutter-best-practices',
                'snippet': 'Top Flutter development practices and patterns.',
              },
            ],
            'total_results': 3,
          };
        })
        .build(),
  );

  return registry;
}

// =============================================================================
// MAIN APP
// =============================================================================

class RaptrAIExampleApp extends StatefulWidget {
  const RaptrAIExampleApp({super.key});

  @override
  State<RaptrAIExampleApp> createState() => _RaptrAIExampleAppState();
}

class _RaptrAIExampleAppState extends State<RaptrAIExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RaptrAI Demo',
      debugShowCheckedModeBanner: false,
      theme: RaptrAITheme.light(),
      darkTheme: RaptrAITheme.dark(),
      themeMode: _themeMode,
      home: MainScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final MockAIProvider _mockProvider;
  late final MockStorage _mockStorage;
  late final RaptrAIToolRegistry _toolRegistry;
  late final RaptrAIUsageTracker _usageTracker;

  @override
  void initState() {
    super.initState();
    _mockProvider = MockAIProvider();
    _mockStorage = MockStorage();
    _toolRegistry = createMockToolRegistry();
    _usageTracker = RaptrAIUsageTracker(
      limits: const RaptrAIUsageLimits(
        maxTokensPerDay: 100000,
        maxRequestsPerMinute: 60,
        maxCostPerDay: 10.0,
      ),
      onUsageUpdate: (usage) {
        debugPrint('[Usage] Tokens: ${usage.totalTokens}, Cost: \$${usage.estimatedCost.toStringAsFixed(4)}');
      },
      onLimitExceeded: (limitType) {
        debugPrint('[Usage] Limit exceeded: $limitType');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      FullChatDemo(
        provider: _mockProvider,
        storage: _mockStorage,
        toolRegistry: _toolRegistry,
        usageTracker: _usageTracker,
      ),
      const AssistantUIDemo(),
      const ChatDemoScreen(),
      ComponentsScreen(usageTracker: _usageTracker),
      ToolsDemo(toolRegistry: _toolRegistry),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('RaptrAI Demo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Full Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.assistant_outlined),
            selectedIcon: Icon(Icons.assistant),
            label: 'Assistant',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat UI',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets),
            label: 'Components',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FULL CHAT DEMO - Complete integrated experience
// =============================================================================

class FullChatDemo extends StatefulWidget {
  const FullChatDemo({
    required this.provider,
    required this.storage,
    required this.toolRegistry,
    required this.usageTracker,
    super.key,
  });

  final RaptrAIProvider provider;
  final RaptrAIStorage storage;
  final RaptrAIToolRegistry toolRegistry;
  final RaptrAIUsageTracker usageTracker;

  @override
  State<FullChatDemo> createState() => _FullChatDemoState();
}

class _FullChatDemoState extends State<FullChatDemo> {
  String? _selectedConversationId;
  List<RaptrAIConversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    await widget.storage.initialize();
    final list = await widget.storage.listConversations();
    if (mounted) {
      setState(() {
        _conversations = list.conversations;
        _isLoading = false;
      });
    }
  }

  void _handleNewThread() {
    setState(() => _selectedConversationId = null);
  }

  void _handleSelectThread(RaptrAIThreadData thread) {
    setState(() => _selectedConversationId = thread.id);
  }

  Future<void> _handleDeleteThread(RaptrAIThreadData thread) async {
    await widget.storage.deleteConversation(thread.id);
    await _loadConversations();
    if (_selectedConversationId == thread.id) {
      setState(() => _selectedConversationId = null);
    }
  }

  void _handleConversationChanged(RaptrAIConversation conversation) {
    _loadConversations();
    if (_selectedConversationId == null) {
      setState(() => _selectedConversationId = conversation.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth >= 768;

    return Row(
      children: [
        // Sidebar
        if (showSidebar)
          SizedBox(
            width: 280,
            child: RaptrAIThreadList(
              threads: _conversations.map((c) => RaptrAIThreadData(
                id: c.id,
                title: c.title ?? 'New conversation',
                preview: c.messages.isNotEmpty ? c.messages.last.content : null,
                isActive: c.id == _selectedConversationId,
              )).toList(),
              selectedThreadId: _selectedConversationId,
              onNewThread: _handleNewThread,
              onSelectThread: _handleSelectThread,
              onDeleteThread: _handleDeleteThread,
              header: _buildUsageHeader(),
            ),
          ),

        if (showSidebar) const VerticalDivider(width: 1),

        // Main chat area
        Expanded(
          child: RaptrAIChat(
            key: ValueKey(_selectedConversationId),
            provider: widget.provider,
            model: 'mock-gpt-4',
            systemPrompt: 'You are RaptrAI, a helpful AI assistant powered by the RaptrAI Flutter framework. Be helpful, concise, and friendly.',
            storage: widget.storage,
            tools: widget.toolRegistry.definitions,
            toolRegistry: widget.toolRegistry,
            usageTracker: widget.usageTracker,
            conversationId: _selectedConversationId,
            welcomeGreeting: 'Welcome to RaptrAI!',
            welcomeSubtitle: 'The complete AI framework for Flutter',
            suggestions: const [
              RaptrAISuggestion(
                title: "What's the weather",
                subtitle: 'in San Francisco?',
                icon: Icons.cloud_outlined,
              ),
              RaptrAISuggestion(
                title: 'Calculate something',
                subtitle: 'with the math tool',
                icon: Icons.calculate_outlined,
              ),
              RaptrAISuggestion(
                title: 'Search the web',
                subtitle: 'for Flutter tips',
                icon: Icons.search,
              ),
              RaptrAISuggestion(
                title: 'Tell me about',
                subtitle: 'RaptrAI features',
                icon: Icons.info_outline,
              ),
            ],
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${error.message}'),
                  backgroundColor: RaptrAIColors.error,
                ),
              );
            },
            onConversationChanged: _handleConversationChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageHeader() {
    return ListenableBuilder(
      listenable: widget.usageTracker,
      builder: (context, _) {
        final usage = widget.usageTracker.currentUsage;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? RaptrAIColors.darkSurface
                : RaptrAIColors.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? RaptrAIColors.darkBorder
                    : RaptrAIColors.lightBorder,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Usage Today',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tokens: ${usage.totalTokens}'),
                  Text('\$${usage.estimatedCost.toStringAsFixed(4)}'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (usage.totalTokens / 100000).clamp(0.0, 1.0),
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? RaptrAIColors.darkBorder
                    : RaptrAIColors.lightBorder,
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// ASSISTANT UI DEMO - Thread-based chat experience
// =============================================================================

class AssistantUIDemo extends StatefulWidget {
  const AssistantUIDemo({super.key});

  @override
  State<AssistantUIDemo> createState() => _AssistantUIDemoState();
}

class _AssistantUIDemoState extends State<AssistantUIDemo> {
  final List<_Message> _messages = [];
  bool _isGenerating = false;
  String _streamingContent = '';
  String? _selectedThreadId;

  final List<RaptrAIThreadData> _threads = [
    const RaptrAIThreadData(
      id: '1',
      title: 'Getting Started',
      preview: 'How can I help you today?',
    ),
    const RaptrAIThreadData(
      id: '2',
      title: 'Flutter Questions',
      preview: 'Tell me about state management...',
    ),
    const RaptrAIThreadData(
      id: '3',
      title: 'Code Review',
      preview: 'Can you review this PR?',
    ),
  ];

  RaptrAIModel _selectedModel = const RaptrAIModel(
    id: 'gpt-4',
    name: 'GPT-4',
    description: 'Most capable model',
    icon: Icons.auto_awesome,
  );

  final List<RaptrAIModel> _models = const [
    RaptrAIModel(
      id: 'gpt-4',
      name: 'GPT-4',
      description: 'Most capable model',
      icon: Icons.auto_awesome,
    ),
    RaptrAIModel(
      id: 'gpt-3.5',
      name: 'GPT-3.5 Turbo',
      description: 'Fast and efficient',
      icon: Icons.bolt,
    ),
    RaptrAIModel(
      id: 'claude',
      name: 'Claude 3',
      description: 'Anthropic model',
      icon: Icons.psychology,
    ),
  ];

  Future<void> _sendMessage(String text, List<RaptrAIAttachment> attachments) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(content: text, role: RaptrAIMessageRole.user));
      _isGenerating = true;
      _streamingContent = '';
    });

    // Simulate streaming response
    const response = 'Thanks for your message! This is a demo response from RaptrAI. '
        'The components you see here feature a modern design system '
        'with Inter font and zinc color palette for optimal readability.\n\n'
        '**Key Features:**\n'
        '- Beautiful, composable widgets\n'
        '- Multi-provider AI support\n'
        '- Tool/function calling\n'
        '- Conversation branching';

    for (int i = 0; i < response.length; i++) {
      if (!_isGenerating) break;
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) {
        setState(() {
          _streamingContent = response.substring(0, i + 1);
        });
      }
    }

    if (mounted && _isGenerating) {
      setState(() {
        _isGenerating = false;
        _messages.add(_Message(content: response, role: RaptrAIMessageRole.assistant));
        _streamingContent = '';
      });
    }
  }

  void _handleSuggestionTap(RaptrAISuggestion suggestion) {
    final text = suggestion.subtitle != null
        ? '${suggestion.title} ${suggestion.subtitle}'
        : suggestion.title;
    _sendMessage(text, []);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth >= 768;

    return Row(
      children: [
        // Thread List Sidebar
        if (showSidebar)
          RaptrAIThreadList(
            threads: _threads,
            selectedThreadId: _selectedThreadId,
            onNewThread: () {
              setState(() {
                _selectedThreadId = null;
                _messages.clear();
              });
            },
            onSelectThread: (thread) {
              setState(() => _selectedThreadId = thread.id);
            },
            onDeleteThread: (thread) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted: ${thread.title}')),
              );
            },
            header: RaptrAIModelSelector(
              models: _models,
              selectedModel: _selectedModel,
              onModelSelected: (model) {
                setState(() => _selectedModel = model);
              },
            ),
          ),
        // Main Thread Area
        Expanded(
          child: RaptrAIThread(
            welcome: RaptrAIThreadWelcome(
              greeting: 'Hello there!',
              subtitle: 'How can I help you today?',
              suggestions: const [
                RaptrAISuggestion(
                  title: "What's the weather",
                  subtitle: 'in San Francisco?',
                  icon: Icons.cloud_outlined,
                ),
                RaptrAISuggestion(
                  title: 'Explain React hooks',
                  subtitle: 'like useState and useEffect',
                  icon: Icons.code,
                ),
                RaptrAISuggestion(
                  title: 'Write a poem',
                  subtitle: 'about the ocean',
                  icon: Icons.edit_note,
                ),
                RaptrAISuggestion(
                  title: 'Help me debug',
                  subtitle: 'my Flutter app',
                  icon: Icons.bug_report_outlined,
                ),
              ],
              onSuggestionTap: _handleSuggestionTap,
            ),
            messages: [
              ..._messages.map((m) {
                if (m.role == RaptrAIMessageRole.user) {
                  return RaptrAIUserMessage(content: m.content);
                }
                return RaptrAIAssistantMessage(
                  content: m.content,
                  isStreaming: false,
                  onRegenerate: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Regenerating...')),
                    );
                  },
                );
              }),
              if (_isGenerating && _streamingContent.isNotEmpty)
                RaptrAIAssistantMessage(
                  content: _streamingContent,
                  isStreaming: true,
                ),
            ],
            composer: RaptrAIComposer(
              placeholder: 'Send a message...',
              onSend: _sendMessage,
              isGenerating: _isGenerating,
              onStop: () {
                setState(() => _isGenerating = false);
              },
              onAddAttachment: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add attachment tapped')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Message {
  final String content;
  final RaptrAIMessageRole role;

  _Message({required this.content, required this.role});
}

// =============================================================================
// CHAT DEMO SCREEN - Simple chat bubbles
// =============================================================================

class ChatDemoScreen extends StatefulWidget {
  const ChatDemoScreen({super.key});

  @override
  State<ChatDemoScreen> createState() => _ChatDemoScreenState();
}

class _ChatDemoScreenState extends State<ChatDemoScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      content: "Hello! I'm RaptrAI assistant. How can I help you today?",
      isUser: false,
    ),
  ];
  bool _isTyping = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(content: text, isUser: true));
      _isTyping = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            content: 'Thanks for your message! This is a demo response from '
                'RaptrAI. The components you see here are all from the raptrai '
                'Flutter package - a complete UI framework for AI interfaces.',
            isUser: false,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Suggestions at top if few messages
        if (_messages.length <= 2) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: RaptrAIPromptSuggestions(
              suggestions: const [
                'Tell me about RaptrAI',
                'Show me components',
                'How does theming work?',
              ],
              onSuggestionTap: _sendMessage,
            ),
          ),
        ],
        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: RaptrAITypingIndicator(),
                );
              }
              final message = _messages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: message.isUser
                    ? RaptrAIChatBubble.user(content: message.content)
                    : RaptrAIChatBubble.assistant(content: message.content),
              );
            },
          ),
        ),
        // Input
        Padding(
          padding: const EdgeInsets.all(16),
          child: RaptrAIPromptInput(
            hintText: 'Type a message...',
            onSubmit: _sendMessage,
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String content;
  final bool isUser;

  _ChatMessage({required this.content, required this.isUser});
}

// =============================================================================
// COMPONENTS SCREEN - UI component showcase
// =============================================================================

class ComponentsScreen extends StatelessWidget {
  const ComponentsScreen({required this.usageTracker, super.key});

  final RaptrAIUsageTracker usageTracker;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Usage Stats Section
        const _SectionHeader(title: 'Usage Statistics'),
        _UsageStatsCard(usageTracker: usageTracker),
        const SizedBox(height: 24),

        // Tool UI Section
        const _SectionHeader(title: 'Tool UI Components'),
        const RaptrAIToolCallWidget(
          toolCall: RaptrAIToolCallData(
            id: '1',
            name: 'get_weather',
            arguments: {'location': 'San Francisco', 'unit': 'celsius'},
            status: RaptrAIToolCallStatus.completed,
            result: 'Temperature: 18°C, Partly cloudy',
          ),
          initiallyExpanded: true,
        ),
        const SizedBox(height: 12),
        const RaptrAIToolCallWidget(
          toolCall: RaptrAIToolCallData(
            id: '2',
            name: 'web_search',
            arguments: {'query': 'Flutter best practices 2025'},
            status: RaptrAIToolCallStatus.running,
          ),
        ),
        const SizedBox(height: 12),
        const RaptrAIToolCallWidget(
          toolCall: RaptrAIToolCallData(
            id: '3',
            name: 'calculator',
            arguments: {'expression': '(2 + 3) * 4'},
            status: RaptrAIToolCallStatus.failed,
            error: 'Division by zero error',
          ),
        ),
        const SizedBox(height: 24),

        // Buttons Section
        const _SectionHeader(title: 'Buttons'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            RaptrAIButton(label: 'Primary', onPressed: () {}),
            RaptrAIButton.secondary(label: 'Secondary', onPressed: () {}),
            RaptrAIButton.outlined(label: 'Outlined', onPressed: () {}),
            RaptrAIButton.ghost(label: 'Ghost', onPressed: () {}),
            RaptrAIButton.danger(label: 'Danger', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            RaptrAIButton(
              label: 'With Icon',
              icon: Icons.star,
              onPressed: () {},
            ),
            RaptrAIButton(
              label: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
            RaptrAIButton(
              label: 'Disabled',
              disabled: true,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Badges Section
        const _SectionHeader(title: 'Badges'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const RaptrAIBadge(label: 'Default'),
            RaptrAIBadge.success(label: 'Success'),
            RaptrAIBadge.warning(label: 'Warning'),
            RaptrAIBadge.error(label: 'Error'),
            RaptrAIBadge.info(label: 'Info'),
            RaptrAIBadge.accent(label: 'Accent'),
          ],
        ),
        const SizedBox(height: 24),

        // Alerts Section
        const _SectionHeader(title: 'Alerts'),
        RaptrAIAlert.info(
          title: 'Information',
          message: 'This is an informational alert with helpful details.',
        ),
        const SizedBox(height: 8),
        RaptrAIAlert.success(
          title: 'Success',
          message: 'Operation completed successfully!',
        ),
        const SizedBox(height: 8),
        RaptrAIAlert.warning(
          title: 'Warning',
          message: 'Please review before proceeding.',
        ),
        const SizedBox(height: 8),
        RaptrAIAlert.error(
          title: 'Error',
          message: 'Something went wrong. Please try again.',
        ),
        const SizedBox(height: 24),

        // Cards Section
        const _SectionHeader(title: 'Cards'),
        RaptrAICard(
          style: RaptrAICardStyle.bordered,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Bordered Card'),
          ),
        ),
        const SizedBox(height: 8),
        RaptrAICard(
          style: RaptrAICardStyle.elevated,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Elevated Card'),
          ),
        ),
        const SizedBox(height: 8),
        RaptrAICard(
          style: RaptrAICardStyle.filled,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Filled Card'),
          ),
        ),
        const SizedBox(height: 24),

        // Branch Picker
        const _SectionHeader(title: 'Branch Picker'),
        Row(
          children: [
            RaptrAIBranchPicker(
              currentIndex: 2,
              totalBranches: 5,
              onPrevious: () {},
              onNext: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Code Block Section
        const _SectionHeader(title: 'Code Block'),
        const RaptrAICodeBlock(
          code: '''// RaptrAI Example
import 'package:raptrai/raptrai.dart';

void main() {
  final provider = MockAIProvider();

  RaptrAIChat(
    provider: provider,
    systemPrompt: 'You are a helpful assistant.',
    tools: toolRegistry.definitions,
  );
}''',
          language: 'dart',
        ),
        const SizedBox(height: 24),

        // Typing Indicators Section
        const _SectionHeader(title: 'Typing Indicators'),
        const Row(
          children: [
            RaptrAITypingIndicator(),
            SizedBox(width: 32),
            RaptrAIPulsingIndicator(),
          ],
        ),
        const SizedBox(height: 24),

        // Streaming Text Section
        const _SectionHeader(title: 'Streaming Text'),
        const RaptrAIStreamingText(
          text: 'This text has a blinking cursor effect...',
          showCursor: true,
        ),
        const SizedBox(height: 24),

        // Copy Button Section
        const _SectionHeader(title: 'Copy Button'),
        Row(
          children: [
            RaptrAICopyButton(
              textToCopy: 'Hello, World!',
              onCopied: () {},
            ),
            const SizedBox(width: 8),
            const Text('Click to copy "Hello, World!"'),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _UsageStatsCard extends StatelessWidget {
  const _UsageStatsCard({required this.usageTracker});

  final RaptrAIUsageTracker usageTracker;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: usageTracker,
      builder: (context, _) {
        final usage = usageTracker.currentUsage;
        final limits = usageTracker.getLimitStatus();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return RaptrAICard(
          style: RaptrAICardStyle.bordered,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: RaptrAIColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'API Usage Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _UsageRow(
                  label: 'Total Tokens',
                  value: '${usage.totalTokens}',
                  icon: Icons.token,
                ),
                _UsageRow(
                  label: 'Prompt Tokens',
                  value: '${usage.promptTokens}',
                  icon: Icons.input,
                ),
                _UsageRow(
                  label: 'Completion Tokens',
                  value: '${usage.completionTokens}',
                  icon: Icons.output,
                ),
                _UsageRow(
                  label: 'Requests',
                  value: '${usage.requests}',
                  icon: Icons.send,
                ),
                _UsageRow(
                  label: 'Estimated Cost',
                  value: '\$${usage.estimatedCost.toStringAsFixed(4)}',
                  icon: Icons.attach_money,
                ),
                if (limits.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    'Limits',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  ...limits.map((status) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_getLimitName(status.limitType)),
                                Text(
                                  '${status.current} / ${status.limit}',
                                  style: TextStyle(
                                    color: status.isExceeded
                                        ? RaptrAIColors.error
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: status.percentUsed.clamp(0.0, 1.0),
                              backgroundColor: isDark
                                  ? RaptrAIColors.darkBorder
                                  : RaptrAIColors.lightBorder,
                              valueColor: AlwaysStoppedAnimation(
                                status.percentUsed > 0.9
                                    ? RaptrAIColors.error
                                    : status.percentUsed > 0.7
                                        ? RaptrAIColors.warning
                                        : RaptrAIColors.success,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RaptrAIButton.outlined(
                        label: 'Reset Stats',
                        icon: Icons.refresh,
                        onPressed: () => usageTracker.reset(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLimitName(RaptrAILimitType type) {
    switch (type) {
      case RaptrAILimitType.dailyTokens:
        return 'Daily Tokens';
      case RaptrAILimitType.requestsPerMinute:
        return 'Requests/Min';
      case RaptrAILimitType.dailyCost:
        return 'Daily Cost';
      case RaptrAILimitType.requestTokens:
        return 'Request Tokens';
    }
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TOOLS DEMO SCREEN
// =============================================================================

class ToolsDemo extends StatefulWidget {
  const ToolsDemo({required this.toolRegistry, super.key});

  final RaptrAIToolRegistry toolRegistry;

  @override
  State<ToolsDemo> createState() => _ToolsDemoState();
}

class _ToolsDemoState extends State<ToolsDemo> {
  final List<_ToolExecution> _executions = [];
  bool _isExecuting = false;

  Future<void> _executeTool(String toolName, Map<String, dynamic> args) async {
    setState(() => _isExecuting = true);

    final toolCall = RaptrAIToolCall(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      name: toolName,
      arguments: args,
    );

    setState(() {
      _executions.insert(0, _ToolExecution(
        toolCall: toolCall,
        status: RaptrAIToolCallStatus.running,
      ));
    });

    final result = await widget.toolRegistry.execute(toolCall);

    setState(() {
      _executions[0] = _ToolExecution(
        toolCall: toolCall,
        status: result.success ? RaptrAIToolCallStatus.completed : RaptrAIToolCallStatus.failed,
        result: result.success ? result.data.toString() : null,
        error: result.error,
      );
      _isExecuting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader(title: 'Available Tools'),
        ...widget.toolRegistry.tools.map((tool) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(_getToolIcon(tool.name)),
                title: Text(tool.name),
                subtitle: Text(tool.description),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: _isExecuting
                      ? null
                      : () => _showToolDialog(context, tool),
                ),
              ),
            )),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Quick Execute'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            RaptrAIButton(
              label: 'Get Weather',
              icon: Icons.cloud,
              disabled: _isExecuting,
              onPressed: () => _executeTool('get_weather', {
                'location': 'San Francisco',
                'unit': 'celsius',
              }),
            ),
            RaptrAIButton(
              label: 'Calculate',
              icon: Icons.calculate,
              disabled: _isExecuting,
              onPressed: () => _executeTool('calculator', {
                'expression': '2 + 2 * 3',
              }),
            ),
            RaptrAIButton(
              label: 'Web Search',
              icon: Icons.search,
              disabled: _isExecuting,
              onPressed: () => _executeTool('web_search', {
                'query': 'Flutter 2025',
              }),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'Execution History'),
        if (_executions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No executions yet. Try running a tool!'),
            ),
          )
        else
          ..._executions.map((exec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RaptrAIToolCallWidget(
                  toolCall: RaptrAIToolCallData(
                    id: exec.toolCall.id,
                    name: exec.toolCall.name,
                    arguments: exec.toolCall.arguments,
                    status: exec.status,
                    result: exec.result,
                    error: exec.error,
                  ),
                  initiallyExpanded: true,
                ),
              )),
      ],
    );
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case 'get_weather':
        return Icons.cloud;
      case 'calculator':
        return Icons.calculate;
      case 'web_search':
        return Icons.search;
      default:
        return Icons.build;
    }
  }

  void _showToolDialog(BuildContext context, RaptrAIRegisteredTool tool) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Execute ${tool.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tool.description),
            const SizedBox(height: 16),
            Text(
              'Parameters:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(tool.definition.parameters.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Execute with default args
              _executeTool(tool.name, _getDefaultArgs(tool.name));
            },
            child: const Text('Execute'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDefaultArgs(String toolName) {
    switch (toolName) {
      case 'get_weather':
        return {'location': 'New York', 'unit': 'fahrenheit'};
      case 'calculator':
        return {'expression': '10 * 5 + 2'};
      case 'web_search':
        return {'query': 'Dart programming language'};
      default:
        return {};
    }
  }
}

class _ToolExecution {
  final RaptrAIToolCall toolCall;
  final RaptrAIToolCallStatus status;
  final String? result;
  final String? error;

  _ToolExecution({
    required this.toolCall,
    required this.status,
    this.result,
    this.error,
  });
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
