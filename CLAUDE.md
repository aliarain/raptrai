# RaptrAI - The Complete AI Framework for Flutter

A **raptrx.com** product. The ultimate Flutter framework for building production-ready AI-powered applications.

## Package Overview

RaptrAI is not just a UI kit - it's a complete AI framework that provides:
- **Multi-Provider AI Integration**: OpenAI, Anthropic Claude, Google Gemini
- **60+ UI Components**: modern-inspired, beautiful and composable
- **Conversation Management**: Full state management with branching
- **Tool/Function Calling**: Register and execute tools with auto-UI
- **Persistence Layer**: Offline-first with Hive, cloud sync ready
- **Business Features**: Usage tracking, analytics, rate limiting

## Quick Start

```dart
import 'package:raptrai/raptrai.dart';

// Minimal setup - 10 lines to production AI chat
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

## Project Structure

```
lib/
├── raptrai.dart                         # Main export file
├── widgets/
│   └── raptrai_chat.dart                # High-level chat widgets
└── src/
    ├── providers/                       # AI Provider Layer
    │   ├── provider_interface.dart      # Abstract provider interface
    │   ├── provider_types.dart          # Message, Response, Chunk types
    │   ├── openai_provider.dart         # OpenAI GPT integration
    │   ├── anthropic_provider.dart      # Anthropic Claude integration
    │   └── google_provider.dart         # Google Gemini integration
    │
    ├── conversation/                    # Conversation Management
    │   ├── conversation.dart            # Conversation state & messages
    │   └── conversation_controller.dart # High-level controller
    │
    ├── tools/                           # Tool/Function Calling
    │   ├── tool_registry.dart           # Register and manage tools
    │   └── tool_executor.dart           # Execute tools with UI
    │
    ├── persistence/                     # Storage Layer
    │   ├── storage_interface.dart       # Abstract storage interface
    │   └── hive_storage.dart            # Local Hive storage
    │
    ├── business/                        # Business Features
    │   ├── usage_tracker.dart           # Token & cost tracking
    │   └── analytics.dart               # Event analytics
    │
    ├── assistant/                       # Thread & Assistant Components
    │   ├── thread.dart                  # Thread, ThreadWelcome, ThreadMessages
    │   ├── thread_list.dart             # ThreadList, ThreadListItem
    │   ├── composer.dart                # Composer with attachments
    │   ├── message.dart                 # UserMessage, AssistantMessage
    │   ├── tool_ui.dart                 # ToolCall display widgets
    │   └── assistant_modal.dart         # Floating chat modal
    │
    ├── chat/                            # Chat Components
    │   ├── chat_bubble.dart             # Message bubbles
    │   ├── chat_input.dart              # Chat input field
    │   ├── typing_indicator.dart        # Animated typing dots
    │   └── streaming_text.dart          # Streaming text effects
    │
    ├── prompt/                          # Prompt Components
    │   ├── prompt_container.dart        # Container variants
    │   ├── prompt_input.dart            # Text input
    │   ├── prompt_message.dart          # Message display
    │   └── prompt_suggestions.dart      # Quick action chips
    │
    ├── common/                          # Common Components
    │   ├── raptrai_button.dart          # Button variants
    │   ├── raptrai_badge.dart           # Status badges
    │   ├── raptrai_card.dart            # Card containers
    │   ├── raptrai_alert.dart           # Alert messages
    │   └── copy_button.dart             # Copy functionality
    │
    ├── layout/                          # Layout Components
    │   ├── sidebar.dart                 # Navigation sidebar
    │   ├── history_panel.dart           # Conversation history
    │   └── prompt_container_layout.dart # Responsive layouts
    │
    └── theme/                           # Theme System
        ├── raptrai_colors.dart          # Color palette (zinc scale)
        └── raptrai_theme.dart           # Theme configuration
```

---

## AI Provider Layer

### Provider Interface

All providers implement `RaptrAIProvider`:

```dart
abstract class RaptrAIProvider {
  String get name;
  String get defaultModel;
  List<String> get availableModels;

  Stream<RaptrAIChunk> chat({
    required List<RaptrAIMessage> messages,
    String? model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig? config,
  });

  Future<RaptrAIResponse> chatComplete({...});
  void cancel();
}
```

### OpenAI Provider

```dart
final openai = RaptrAIOpenAI(
  apiKey: 'sk-...',
  organization: 'org-...', // optional
);

// Available models
// - gpt-4-turbo (default)
// - gpt-4
// - gpt-3.5-turbo

// Stream responses
await for (final chunk in openai.chat(
  messages: [RaptrAIMessage.user('Hello!')],
  model: 'gpt-4-turbo',
)) {
  print(chunk.content);
}
```

### Anthropic Provider

```dart
final anthropic = RaptrAIAnthropic(
  apiKey: 'sk-ant-...',
);

// Available models
// - claude-3-opus-20240229
// - claude-3-sonnet-20240229 (default)
// - claude-3-haiku-20240307
```

### Google Provider

```dart
final google = RaptrAIGoogle(
  apiKey: 'AIza...',
);

// Available models
// - gemini-pro (default)
// - gemini-pro-vision
```

### Message Types

```dart
// User message
RaptrAIMessage.user('Hello!');

// User message with attachments
RaptrAIMessage.user(
  'What is this?',
  attachments: [
    RaptrAIAttachment.image(bytes: imageBytes, mimeType: 'image/png'),
  ],
);

// System message
RaptrAIMessage.system('You are a helpful assistant.');

// Assistant message
RaptrAIMessage.assistant('Hello! How can I help?');

// Assistant with tool calls
RaptrAIMessage.assistant(
  'Let me check the weather.',
  toolCalls: [
    RaptrAIToolCall(
      id: 'call_123',
      name: 'get_weather',
      arguments: {'location': 'San Francisco'},
    ),
  ],
);

// Tool result
RaptrAIMessage.tool(
  toolCallId: 'call_123',
  content: '{"temperature": 72, "condition": "sunny"}',
);
```

---

## Conversation Management

### Conversation State

```dart
// Create a conversation
final conversation = RaptrAIConversation(
  id: 'conv_123',
  title: 'My Chat',
  systemPrompt: 'You are a helpful assistant.',
);

// Add messages
conversation.addMessage(RaptrAIConversationMessage(
  id: 'msg_1',
  role: RaptrAIRole.user,
  branches: [RaptrAIMessageBranch(content: 'Hello!')],
));
```

### Conversation Controller

```dart
final controller = RaptrAIConversationController(
  provider: openai,
  model: 'gpt-4-turbo',
  systemPrompt: 'You are a helpful assistant.',
  tools: toolDefinitions,
  onError: (error) => print('Error: $error'),
  onUsageUpdate: (usage) => print('Tokens: ${usage.totalTokens}'),
);

// Listen to changes
controller.addListener(() {
  print('Messages: ${controller.messages.length}');
  print('Is generating: ${controller.isGenerating}');
  print('Streaming content: ${controller.streamingContent}');
});

// Send message
await controller.send('Hello!');

// Edit message (creates branch)
await controller.edit(messageId, 'Updated content');

// Regenerate response
await controller.regenerate(messageId);

// Navigate branches
controller.switchBranch(messageId, branchIndex);

// Stop generation
controller.stop();

// Clear conversation
controller.clear();
```

---

## Tool/Function Calling

### Tool Registry

```dart
final registry = RaptrAIToolRegistry();

// Register a tool
registry.register(
  name: 'get_weather',
  description: 'Get current weather for a location',
  parameters: {
    'location': RaptrAIToolParameter(
      type: RaptrAIToolParameterType.string,
      description: 'City name',
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
    // Fetch weather...
    return RaptrAIToolResult.success({
      'temperature': 72,
      'condition': 'sunny',
    });
  },
);

// Get tool definitions for provider
final toolDefs = registry.getToolDefinitions();

// Execute a tool call
final result = await registry.execute(toolCall);
```

### Tool Executor

```dart
final executor = RaptrAIToolExecutor(
  registry: registry,
  controller: conversationController,
  requireApproval: false, // or true for user confirmation
  onToolStart: (toolCall) => print('Starting: ${toolCall.name}'),
  onToolComplete: (toolCall, result) => print('Done: ${result.data}'),
  onToolError: (toolCall, error) => print('Error: $error'),
);

// Process tool calls from assistant response
await executor.processToolCalls(toolCalls);
```

---

## Persistence Layer

### Storage Interface

```dart
abstract class RaptrAIStorage {
  Future<void> initialize();
  Future<void> close();
  Future<void> saveConversation(RaptrAIConversation conversation);
  Future<RaptrAIConversation?> loadConversation(String id);
  Future<RaptrAIConversationList> listConversations({int limit, String? cursor});
  Future<void> deleteConversation(String id);
  Stream<RaptrAIConversation> watchConversation(String id);
  Future<List<RaptrAIConversation>> search(String query);
}
```

### Hive Storage (Local)

```dart
final storage = RaptrAIHiveStorage(
  config: RaptrAIHiveConfig(
    boxName: 'raptrai_conversations',
    encryptionKey: encryptionKey, // optional 32-byte key
    userId: currentUserId, // optional for multi-user
  ),
);

await storage.initialize();

// Save conversation
await storage.saveConversation(conversation);

// Load conversation
final conv = await storage.loadConversation('conv_123');

// List conversations
final list = await storage.listConversations(limit: 20);
for (final conv in list.conversations) {
  print('${conv.title}: ${conv.messages.length} messages');
}

// Search
final results = await storage.search('weather');

// Watch changes
storage.watchConversation('conv_123').listen((conv) {
  print('Updated: ${conv.updatedAt}');
});
```

### Memory Storage (Testing)

```dart
final storage = RaptrAIMemoryStorage();
// Same interface, data not persisted
```

---

## Business Features

### Usage Tracker

```dart
final tracker = RaptrAIUsageTracker(
  limits: RaptrAIUsageLimits(
    maxTokensPerDay: 100000,
    maxTokensPerMonth: 1000000,
    maxRequestsPerMinute: 10,
    maxRequestsPerDay: 1000,
  ),
  pricing: RaptrAIModelPricing.defaults(), // or custom pricing
  onLimitReached: (type) => print('Limit reached: $type'),
);

// Track usage
tracker.trackUsage(
  RaptrAIUsage(
    promptTokens: 100,
    completionTokens: 50,
    totalTokens: 150,
  ),
  model: 'gpt-4-turbo',
);

// Check limits
if (tracker.canMakeRequest()) {
  // OK to send request
}

// Get statistics
print('Daily tokens: ${tracker.dailyTokens}');
print('Monthly tokens: ${tracker.monthlyTokens}');
print('Estimated cost: \$${tracker.estimatedCost.toStringAsFixed(4)}');
print('Requests today: ${tracker.dailyRequestCount}');

// Reset (e.g., at day/month boundary)
tracker.resetDaily();
tracker.resetMonthly();
```

### Analytics

```dart
// Configure analytics
RaptrAIAnalytics.configure(
  onEvent: (event) {
    // Send to Mixpanel, Amplitude, PostHog, etc.
    analytics.track(event.name, properties: event.toJson());
  },
  enabled: true,
  maxHistorySize: 100,
);

// Events are automatically tracked when using RaptrAIChat
// Or manually track:
RaptrAIAnalytics.track(RaptrAIEventType.conversationStarted);
RaptrAIAnalytics.trackMessageSent(
  conversationId: 'conv_123',
  messageId: 'msg_456',
  characterCount: 100,
);

// Event types:
// - conversationStarted, messageSent, responseReceived
// - streamingStarted, streamingCompleted
// - toolCallRequested, toolCallCompleted, toolCallFailed
// - regenerateRequested, messageEdited, messageCopied
// - branchSwitched, conversationCleared, conversationDeleted
// - errorOccurred, rateLimitHit
// - attachmentAdded, voiceInputStarted, voiceInputCompleted
// - modelChanged, providerChanged, generationStopped

// Debug observer
RaptrAIDebugAnalyticsObserver().install();

// Batch analytics
final batchAnalytics = RaptrAIBatchAnalytics(
  onBatch: (events) => sendToServer(events),
  batchSize: 10,
  flushInterval: Duration(seconds: 30),
);
batchAnalytics.install();
```

---

## High-Level Widgets

### RaptrAIChat

Complete AI chat with all features:

```dart
RaptrAIChat(
  // Required
  provider: RaptrAIOpenAI(apiKey: 'sk-...'),

  // Model & prompt
  model: 'gpt-4-turbo',
  systemPrompt: 'You are a helpful assistant.',

  // Storage (optional)
  storage: RaptrAIHiveStorage(),
  conversationId: 'conv_123', // Load existing

  // Tools (optional)
  tools: toolDefinitions,
  toolRegistry: registry,

  // Business features (optional)
  usageTracker: tracker,

  // UI customization
  welcomeGreeting: 'Hello!',
  welcomeSubtitle: 'How can I help you today?',
  suggestions: [
    RaptrAISuggestion(
      title: 'Write code',
      subtitle: 'Help me build something',
    ),
  ],
  placeholder: 'Send a message...',
  autofocus: false,
  readOnly: false,
  showTimestamps: false,

  // Callbacks
  onError: (error) => showSnackBar(error.message),
  onConversationChanged: (conv) => print('Updated'),
  onMessageSent: (content) => print('Sent: $content'),
  onResponseReceived: (message) => print('Response received'),
)
```

### RaptrAIChatWithSidebar

Chat with conversation list sidebar:

```dart
RaptrAIChatWithSidebar(
  provider: RaptrAIOpenAI(apiKey: 'sk-...'),
  storage: RaptrAIHiveStorage(),
  model: 'gpt-4-turbo',
  systemPrompt: 'You are a helpful assistant.',
  tools: toolDefinitions,
  toolRegistry: registry,
  usageTracker: tracker,
  sidebarWidth: 280,
  onError: (error) => showSnackBar(error.message),
)
```

---

## UI Components

### Thread Components

```dart
// Main thread container
RaptrAIThread(
  welcome: RaptrAIThreadWelcome(
    greeting: 'Hello there!',
    subtitle: 'How can I help you today?',
    suggestions: [
      RaptrAISuggestion(title: 'Write code', subtitle: 'in Dart'),
    ],
    onSuggestionTap: (suggestion) => handleSuggestion(suggestion),
  ),
  messages: messages,
  isLoading: isGenerating,
  streamingContent: currentStreamingText,
  scrollController: scrollController,
)

// Thread messages list
RaptrAIThreadMessages(
  messages: messages,
  onRegenerate: (messageId) => regenerate(messageId),
  onCopy: (content) => copyToClipboard(content),
  onBranchChange: (messageId, index) => switchBranch(messageId, index),
)

// Thread list (sidebar)
RaptrAIThreadList(
  threads: threads,
  selectedThreadId: currentId,
  onNewThread: () => createNew(),
  onSelectThread: (thread) => select(thread),
  onDeleteThread: (thread) => delete(thread),
)
```

### Composer Components

```dart
RaptrAIComposer(
  controller: textController,
  placeholder: 'Send a message...',
  isGenerating: isGenerating,
  autofocus: true,
  maxLines: 5,
  onSend: (content, attachments) => send(content, attachments),
  onStop: () => stopGeneration(),
  onAttachmentAdd: () => pickFile(),
  attachments: currentAttachments,
  onAttachmentRemove: (index) => removeAttachment(index),
)
```

### Message Components

```dart
// User message
RaptrAIUserMessage(content: 'Hello!')

// Assistant message
RaptrAIAssistantMessage(
  content: 'Hello! How can I help?',
  isStreaming: false,
  onRegenerate: () => regenerate(),
  onCopy: () => copy(),
)

// Tool call display
RaptrAIToolCallWidget(
  toolCall: toolCall,
  status: RaptrAIToolExecutionStatus.running,
  result: result,
  error: errorMessage,
)
```

### Chat Components

```dart
// Chat bubble
RaptrAIChatBubble(
  content: 'Message text',
  isUser: true,
  timestamp: DateTime.now(),
  showTimestamp: true,
)

// Chat input
RaptrAIChatInput(
  controller: controller,
  onSubmit: (text) => send(text),
  onAttachmentTap: () => pickFile(),
  placeholder: 'Type a message...',
)

// Typing indicator
RaptrAITypingIndicator()

// Streaming text
RaptrAIStreamingText(
  text: streamingContent,
  showCursor: true,
)

// Typewriter effect
RaptrAITypewriterText(
  text: fullText,
  duration: Duration(milliseconds: 50),
)
```

### Common Components

```dart
// Button variants
RaptrAIButton(
  label: 'Click me',
  onPressed: () => doSomething(),
  style: RaptrAIButtonStyle.primary, // secondary, outlined, ghost, danger
  size: RaptrAIButtonSize.medium, // small, large
  isLoading: false,
  icon: Icons.send,
)

// Badge
RaptrAIBadge(
  label: 'New',
  variant: RaptrAIBadgeVariant.success, // info, warning, error, neutral
)

// Card
RaptrAICard(
  style: RaptrAICardStyle.bordered, // elevated, filled, ghost
  padding: EdgeInsets.all(16),
  child: content,
)

// Alert
RaptrAIAlert(
  title: 'Warning',
  message: 'Something happened',
  variant: RaptrAIAlertVariant.warning, // info, success, error
  onDismiss: () => dismiss(),
)

// Copy button
RaptrAICopyButton(
  content: 'Text to copy',
  onCopied: () => showFeedback(),
)
```

### Layout Components

```dart
// Sidebar
RaptrAISidebar(
  items: [
    RaptrAISidebarItem(icon: Icons.chat, label: 'Chat', isSelected: true),
    RaptrAISidebarItem(icon: Icons.settings, label: 'Settings'),
  ],
  onItemTap: (index) => navigate(index),
)

// History panel
RaptrAIHistoryPanel(
  conversations: conversations,
  selectedId: currentId,
  onSelect: (id) => loadConversation(id),
  onDelete: (id) => deleteConversation(id),
)

// Floating modal
RaptrAIAssistantModal(
  isOpen: showModal,
  onClose: () => setState(() => showModal = false),
  child: RaptrAIChat(...),
)
```

---

## Theme System

### Colors (Zinc Scale)

```dart
// Background colors
RaptrAIColors.background       // zinc-950 dark / zinc-50 light
RaptrAIColors.surface          // zinc-900 dark / white light
RaptrAIColors.surfaceVariant   // zinc-800 dark / zinc-100 light
RaptrAIColors.border           // zinc-700 dark / zinc-200 light

// Text colors
RaptrAIColors.text             // zinc-50 dark / zinc-900 light
RaptrAIColors.textSecondary    // zinc-400 dark / zinc-600 light
RaptrAIColors.textMuted        // zinc-500 dark / zinc-500 light

// Accent color
RaptrAIColors.accent           // blue-500

// Semantic colors
RaptrAIColors.success          // green-500
RaptrAIColors.warning          // amber-500
RaptrAIColors.error            // red-500
RaptrAIColors.info             // blue-500

// Static access
RaptrAIColors.darkBackground
RaptrAIColors.lightBackground
RaptrAIColors.darkText
RaptrAIColors.lightText
```

### Theme Configuration

```dart
// Apply theme
MaterialApp(
  theme: RaptrAITheme.light(),
  darkTheme: RaptrAITheme.dark(),
)

// Custom accent color
RaptrAITheme.light(primaryColor: Colors.purple)
RaptrAITheme.dark(primaryColor: Colors.purple)

// Access theme colors in widgets
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark ? RaptrAIColors.darkBackground : RaptrAIColors.lightBackground;
```

---

## Testing

### Run Tests

```bash
cd /Users/aliarain/Documents/Projects/raptrai
flutter test
```

### Test the Example App

```bash
cd /Users/aliarain/Documents/Projects/raptrai/example
flutter run
```

### Manual Testing Checklist

#### Providers
- [ ] OpenAI streaming works
- [ ] Anthropic streaming works
- [ ] Google streaming works
- [ ] Cancel request works
- [ ] Error handling works

#### Conversation
- [ ] Send message works
- [ ] Streaming response displays
- [ ] Edit message creates branch
- [ ] Regenerate works
- [ ] Branch navigation works
- [ ] Clear conversation works

#### Tools
- [ ] Tool registration works
- [ ] Tool execution works
- [ ] Tool UI displays correctly
- [ ] Error handling works

#### Storage
- [ ] Save conversation works
- [ ] Load conversation works
- [ ] List conversations works
- [ ] Delete conversation works
- [ ] Search works

#### UI Components
- [ ] Theme switching works
- [ ] All button variants render
- [ ] All card variants render
- [ ] Typing indicator animates
- [ ] Streaming text works
- [ ] Copy button works
- [ ] Thread list works
- [ ] Composer attachments work

---

## Example App Structure

```
example/
├── lib/
│   └── main.dart              # Demo app with all features
├── pubspec.yaml
└── ...
```

### Running the Example

```bash
cd /Users/aliarain/Documents/Projects/raptrai/example

# Get dependencies
flutter pub get

# Run on device/simulator
flutter run

# Run on web
flutter run -d chrome
```

---

## Common Commands

```bash
# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Dry run publish
dart pub publish --dry-run

# Publish to pub.dev
dart pub publish
```

---

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Widgets | `RaptrAI{ComponentName}` | `RaptrAIButton`, `RaptrAIChat` |
| Providers | `RaptrAI{ProviderName}` | `RaptrAIOpenAI`, `RaptrAIAnthropic` |
| Controllers | `RaptrAI{Name}Controller` | `RaptrAIConversationController` |
| Storage | `RaptrAI{Type}Storage` | `RaptrAIHiveStorage` |
| Colors | `RaptrAIColors.{name}` | `RaptrAIColors.accent` |
| Theme | `RaptrAITheme.{variant}()` | `RaptrAITheme.dark()` |
| Enums | `RaptrAI{Type}{Variant}` | `RaptrAIButtonStyle.primary` |
| Exceptions | `RaptrAI{Type}Exception` | `RaptrAIException`, `RaptrAIStorageException` |

---

## Adding New Components

1. Create file in appropriate `src/` subdirectory
2. Use `RaptrAI` prefix for class names
3. Support both light and dark themes
4. Add export to `lib/raptrai.dart`
5. Add example to demo app
6. Update documentation

### Component Template

```dart
import 'package:flutter/material.dart';
import '../theme/raptrai_colors.dart';

/// Brief description of the component.
///
/// Example usage:
/// ```dart
/// RaptrAINewComponent(
///   param: value,
/// )
/// ```
class RaptrAINewComponent extends StatelessWidget {
  const RaptrAINewComponent({
    super.key,
    required this.param,
  });

  /// Description of param.
  final String param;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark
        ? RaptrAIColors.darkBackground
        : RaptrAIColors.lightBackground,
      child: Text(param),
    );
  }
}
```

---

## Publishing Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Run `flutter analyze` - no errors
- [ ] Run `flutter test` - all pass
- [ ] Run `dart pub publish --dry-run` - no errors
- [ ] Verify example app works
- [ ] Update documentation
- [ ] Create git tag
- [ ] Publish: `dart pub publish`

---

## Documentation

- **Docs Site**: [raptrai.raptrx.com](https://raptrai.raptrx.com)
- **Docs Repo**: [github.com/aliarain/raptrai-docs](https://github.com/aliarain/raptrai-docs)
- **Contributing to Docs**: See `DOCS.md`

---

## Design Principles

1. **Complete Framework**: Not just UI - full AI integration
2. **modern**: Clean, minimal, composable design
3. **Multi-Provider**: No vendor lock-in
4. **Offline-First**: Local storage with cloud sync
5. **Production-Ready**: Usage tracking, analytics, rate limiting
6. **Developer Experience**: Simple API, comprehensive docs
7. **Responsive**: Mobile, tablet, desktop support
8. **Accessible**: Follows Flutter accessibility guidelines
9. **Themeable**: Full light/dark mode support
10. **Flexible**: Easy customization via parameters

---

## Contact

- **Twitter**: [@realaliarain](https://x.com/realaliarain)
- **GitHub**: [aliarain/raptrai](https://github.com/aliarain/raptrai)
- **Website**: [raptrx.com](https://raptrx.com)
