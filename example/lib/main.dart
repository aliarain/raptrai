import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

void main() {
  runApp(const RaptrAIExampleApp());
}

class RaptrAIExampleApp extends StatefulWidget {
  const RaptrAIExampleApp({super.key});

  @override
  State<RaptrAIExampleApp> createState() => _RaptrAIExampleAppState();
}

class _RaptrAIExampleAppState extends State<RaptrAIExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark for assistant-ui style

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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

  late final List<Widget> _screens = [
    const AssistantUIDemo(),
    const ChatDemoScreen(),
    const ComponentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assistant_outlined),
            selectedIcon: Icon(Icons.assistant),
            label: 'Assistant UI',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets),
            label: 'Components',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Assistant-UI Style Demo
// ============================================================================

class AssistantUIDemo extends StatefulWidget {
  const AssistantUIDemo({super.key});

  @override
  State<AssistantUIDemo> createState() => _AssistantUIDemoState();
}

class _AssistantUIDemoState extends State<AssistantUIDemo> {
  final List<_Message> _messages = [];
  bool _isGenerating = false;
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

  void _sendMessage(String text, List<RaptrAIAttachment> attachments) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(content: text, role: RaptrAIMessageRole.user));
      _isGenerating = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add(_Message(
            content:
                'Thanks for your message! This is a demo response from RaptrAI. '
                'The components you see here match the assistant-ui design system '
                'with shadcn/ui styling, Inter font, and zinc color palette.',
            role: RaptrAIMessageRole.assistant,
          ));
        });
      }
    });
  }

  void _handleSuggestionTap(RaptrAISuggestion suggestion) {
    _sendMessage(suggestion.title + (suggestion.subtitle != null ? ' ${suggestion.subtitle}' : ''), []);
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New thread created')),
              );
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
            messages: _messages.map((m) {
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
            }).toList(),
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

// ============================================================================
// Chat Demo Screen (Original)
// ============================================================================

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
                'Flutter package - a shadcn-inspired UI framework for AI interfaces.',
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

// ============================================================================
// Components Screen
// ============================================================================

class ComponentsScreen extends StatelessWidget {
  const ComponentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
            name: 'search_web',
            arguments: {'query': 'Flutter best practices 2024'},
            status: RaptrAIToolCallStatus.running,
          ),
        ),
        const SizedBox(height: 24),

        // Buttons Section
        _SectionHeader(title: 'Buttons'),
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
        _SectionHeader(title: 'Badges'),
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
        _SectionHeader(title: 'Alerts'),
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

        // Branch Picker
        _SectionHeader(title: 'Branch Picker'),
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
        _SectionHeader(title: 'Code Block'),
        const RaptrAICodeBlock(
          code: '''RaptrAIThread(
  welcome: RaptrAIThreadWelcome(
    greeting: 'Hello there!',
    suggestions: [...],
  ),
  messages: messages,
  composer: RaptrAIComposer(
    onSend: (text, attachments) => send(text),
  ),
)''',
          language: 'dart',
        ),
        const SizedBox(height: 24),

        // Typing Indicators Section
        _SectionHeader(title: 'Typing Indicators'),
        const Row(
          children: [
            RaptrAITypingIndicator(),
            SizedBox(width: 32),
            RaptrAIPulsingIndicator(),
          ],
        ),
        const SizedBox(height: 24),

        // Streaming Text Section
        _SectionHeader(title: 'Streaming Text'),
        const RaptrAIStreamingText(
          text: 'This text has a blinking cursor effect...',
          showCursor: true,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ============================================================================
// Helper Widgets
// ============================================================================

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
