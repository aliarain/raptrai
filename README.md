# RaptrAI

[![pub package](https://img.shields.io/pub/v/raptrai.svg)](https://pub.dev/packages/raptrai)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**The Complete AI Framework for Flutter** - Build production-ready AI-powered apps in days, not months.

RaptrAI provides everything you need: beautiful shadcn-inspired UI components, multi-provider AI integration (OpenAI, Anthropic, Google), conversation management, tool calling, persistence, and business features.

**A [raptrx.com](https://raptrx.com) product.**

## Why RaptrAI?

| Feature | Google GenUI | RaptrAI |
|---------|-------------|---------|
| **Provider Lock-in** | Google AI only | OpenAI, Anthropic, Google, Custom |
| **Platform** | Web-first | Flutter-native (iOS, Android, Web) |
| **UI Approach** | JSON schema | Pre-built components + customization |
| **Persistence** | DIY | Built-in (Hive, Supabase, Firebase) |
| **Tool Calling** | JSON schemas | Dart-native with auto-UI |
| **Business Features** | None | Usage tracking, analytics, rate limiting |
| **Offline Support** | None | Local-first with sync |

## Quick Start

```bash
flutter pub add raptrai
```

### 10 Lines to Production AI Chat

```dart
import 'package:raptrai/raptrai.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: RaptrAITheme.dark(),
      home: RaptrAIChat(
        provider: RaptrAIOpenAI(apiKey: 'sk-...'),
      ),
    );
  }
}
```

## Features

### Multi-Provider AI Integration

Connect to any AI provider with a unified API:

```dart
// OpenAI
final openai = RaptrAIOpenAI(apiKey: 'sk-...');

// Anthropic Claude
final anthropic = RaptrAIAnthropic(apiKey: 'sk-ant-...');

// Google Gemini
final gemini = RaptrAIGoogle(apiKey: 'AIza...');

// Stream responses
await for (final chunk in openai.chat(
  messages: [RaptrAIMessage.user('Hello!')],
  model: 'gpt-4-turbo',
)) {
  print(chunk.content);
}
```

### Beautiful UI Components

60+ pre-built, customizable components matching the shadcn/ui design system:

```dart
RaptrAIThread(
  welcome: RaptrAIThreadWelcome(
    greeting: 'Hello there!',
    subtitle: 'How can I help you today?',
    suggestions: [
      RaptrAISuggestion(
        title: "What's the weather",
        subtitle: "in San Francisco?",
      ),
    ],
  ),
  messages: messages,
  composer: RaptrAIComposer(
    onSend: (text, attachments) => sendMessage(text),
  ),
)
```

### Tool/Function Calling

Register tools with automatic JSON schema generation:

```dart
final registry = RaptrAIToolRegistry();

registry.register(
  name: 'get_weather',
  description: 'Get weather for a location',
  parameters: {
    'location': RaptrAIToolParameter(
      type: RaptrAIToolParameterType.string,
      description: 'City name',
      required: true,
    ),
  },
  handler: (args) async {
    final location = args['location'] as String;
    return {'temperature': 72, 'condition': 'sunny'};
  },
);
```

### Conversation Management

Full conversation state with branching and history:

```dart
final controller = RaptrAIConversationController(
  provider: openai,
  model: 'gpt-4-turbo',
  systemPrompt: 'You are a helpful assistant.',
);

// Send messages
await controller.send('Hello!');

// Edit and regenerate
await controller.edit(messageId, 'New content');
await controller.regenerate(messageId);

// Navigate branches
controller.switchBranch(messageId, branchIndex);
```

### Local-First Persistence

Offline-first storage with cloud sync support:

```dart
// Local storage with Hive
final storage = RaptrAIHiveStorage();
await storage.initialize();

// Save conversations automatically
RaptrAIChat(
  provider: openai,
  storage: storage,
)
```

### Business Features

Track usage, costs, and analytics:

```dart
final tracker = RaptrAIUsageTracker(
  limits: RaptrAIUsageLimits(
    maxTokensPerDay: 100000,
    maxRequestsPerMinute: 10,
  ),
);

// Auto-track usage
RaptrAIChat(
  provider: openai,
  usageTracker: tracker,
)

// Check usage
print('Tokens today: ${tracker.dailyTokens}');
print('Estimated cost: \$${tracker.estimatedCost}');
```

## Components

### High-Level Widgets

| Component | Description |
|-----------|-------------|
| `RaptrAIChat` | Complete AI chat with all features integrated |
| `RaptrAIChatWithSidebar` | Full chat experience with thread list |

### Thread Components

| Component | Description |
|-----------|-------------|
| `RaptrAIThread` | Main chat container with messages and composer |
| `RaptrAIThreadWelcome` | Welcome screen with greeting and suggestions |
| `RaptrAIThreadMessages` | Scrollable message list with auto-scroll |

### Composer Components

| Component | Description |
|-----------|-------------|
| `RaptrAIComposer` | Full input area with attachments |
| `RaptrAIComposerInput` | Text input field |
| `RaptrAIComposerSend` | Send button |

### Message Components

| Component | Description |
|-----------|-------------|
| `RaptrAIUserMessage` | User message bubble |
| `RaptrAIAssistantMessage` | Assistant message with avatar |
| `RaptrAIMessageActions` | Copy/edit/regenerate actions |

### Tool UI Components

| Component | Description |
|-----------|-------------|
| `RaptrAIToolCallWidget` | Function call display |
| `RaptrAIToolCallProgress` | Loading state for tool execution |
| `RaptrAIToolCallResult` | Tool result display |

### Chat Components

| Component | Description |
|-----------|-------------|
| `RaptrAIChatBubble` | User/assistant message bubbles |
| `RaptrAIChatInput` | Full-featured chat input |
| `RaptrAITypingIndicator` | Animated typing dots |
| `RaptrAIStreamingText` | Text with blinking cursor |

### Common Components

| Component | Description |
|-----------|-------------|
| `RaptrAIButton` | Styled buttons (primary, secondary, etc.) |
| `RaptrAIBadge` | Status badges and labels |
| `RaptrAICard` | Card containers |
| `RaptrAICopyButton` | Copy to clipboard with feedback |
| `RaptrAIAlert` | Alert messages |

### Layout Components

| Component | Description |
|-----------|-------------|
| `RaptrAIThreadList` | Conversation sidebar |
| `RaptrAISidebar` | Navigation sidebar |
| `RaptrAIAssistantModal` | Floating chat modal |
| `RaptrAIHistoryPanel` | Conversation history |

## Theming

### Built-in Themes

```dart
MaterialApp(
  theme: RaptrAITheme.light(),
  darkTheme: RaptrAITheme.dark(),
)
```

### Custom Colors

```dart
RaptrAITheme.dark(
  primaryColor: Colors.blue,
  backgroundColor: Color(0xFF09090B),
)
```

### Accessing Colors

```dart
Container(
  color: RaptrAIColors.accent,
  child: Text('Hello', style: TextStyle(color: RaptrAIColors.darkText)),
)
```

## Full Example

```dart
RaptrAIChat(
  // Provider configuration
  provider: RaptrAIOpenAI(apiKey: 'sk-...'),
  model: 'gpt-4-turbo',
  systemPrompt: 'You are a helpful assistant.',

  // Storage
  storage: RaptrAIHiveStorage(),

  // Tools
  toolRegistry: toolRegistry,

  // Business features
  usageTracker: usageTracker,

  // UI customization
  welcomeGreeting: 'Hello!',
  welcomeSubtitle: 'How can I help you today?',
  welcomeSuggestions: [
    RaptrAISuggestion(title: 'Write code', subtitle: 'Help me build something'),
  ],

  // Callbacks
  onMessageSent: (content) => print('Sent: $content'),
  onResponseReceived: (response) => print('Received: $response'),
  onError: (error) => print('Error: $error'),
)
```

## Requirements

- Flutter >= 3.10.0
- Dart >= 3.0.0

## Documentation

Full documentation: [raptrai.raptrx.com](https://raptrai.raptrx.com)

- [Getting Started](https://raptrai.raptrx.com/quickstart)
- [AI Providers](https://raptrai.raptrx.com/providers)
- [UI Components](https://raptrai.raptrx.com/components)
- [Tool Calling](https://raptrai.raptrx.com/tools)
- [Persistence](https://raptrai.raptrx.com/persistence)
- [API Reference](https://raptrai.raptrx.com/api-reference)

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

- Inspired by [shadcn/ui](https://ui.shadcn.com) and [assistant-ui](https://www.assistant-ui.com)
- A [raptrx.com](https://raptrx.com) product
