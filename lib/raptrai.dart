/// Flutter RaptrAI - Complete AI Framework for Flutter.
///
/// A comprehensive Flutter framework for building AI-powered applications.
/// Includes UI components, AI provider integrations, and conversation management.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:raptrai/raptrai.dart';
///
/// // Use the theme
/// MaterialApp(
///   theme: RaptrAITheme.light(),
///   darkTheme: RaptrAITheme.dark(),
///   // ...
/// )
///
/// // Quick setup with any AI provider
/// final openai = RaptrAIOpenAI(apiKey: 'sk-...');
/// final anthropic = RaptrAIAnthropic(apiKey: 'sk-ant-...');
/// final gemini = RaptrAIGoogle(apiKey: 'AIza...');
///
/// // Stream responses
/// await for (final chunk in openai.chat(
///   messages: [RaptrAIMessage.user('Hello!')],
///   model: 'gpt-4-turbo',
/// )) {
///   print(chunk.content);
/// }
///
/// // Use RaptrAI components
/// RaptrAIThread(
///   welcome: RaptrAIThreadWelcome(
///     greeting: 'Hello there!',
///     subtitle: 'How can I help you today?',
///     suggestions: [...],
///   ),
///   messages: messages,
///   composer: RaptrAIComposer(
///     onSend: (text, attachments) => sendMessage(text),
///   ),
/// )
/// ```
library raptrai;

// AI Providers (types and implementations)
export 'src/providers/anthropic_provider.dart';
export 'src/providers/google_provider.dart';
export 'src/providers/openai_provider.dart';
export 'src/providers/provider_interface.dart';

// Conversation Management
export 'src/conversation/conversation.dart';
export 'src/conversation/conversation_controller.dart';

// Tool/Function Calling
export 'src/tools/tool_registry.dart';
export 'src/tools/tool_executor.dart';

// Persistence Layer
export 'src/persistence/storage_interface.dart';
export 'src/persistence/hive_storage.dart';

// Business Features
export 'src/business/usage_tracker.dart';
export 'src/business/analytics.dart';

// High-Level Widgets
export 'widgets/raptrai_chat.dart';

// Thread & Assistant Components
// Hide conflicting names that are also defined in provider_interface.dart
export 'src/assistant/assistant_modal.dart';
export 'src/assistant/composer.dart';
export 'src/assistant/message.dart' hide RaptrAIMessage;
export 'src/assistant/thread.dart';
export 'src/assistant/thread_list.dart';
export 'src/assistant/tool_ui.dart';

// Chat Components
export 'src/chat/chat_bubble.dart';
export 'src/chat/chat_input.dart';
export 'src/chat/streaming_text.dart';
export 'src/chat/typing_indicator.dart';

// Common Components
export 'src/common/copy_button.dart';
export 'src/common/raptrai_alert.dart';
export 'src/common/raptrai_badge.dart';
export 'src/common/raptrai_button.dart';
export 'src/common/raptrai_card.dart';

// Layout Components
export 'src/layout/history_panel.dart';
export 'src/layout/prompt_container_layout.dart';
export 'src/layout/sidebar.dart';

// Prompt Components
export 'src/prompt/prompt_container.dart';
export 'src/prompt/prompt_input.dart';
export 'src/prompt/prompt_message.dart';
export 'src/prompt/prompt_suggestions.dart';

// Theme
export 'src/theme/raptrai_colors.dart';
export 'src/theme/raptrai_theme.dart';

// Default UX Widgets
export 'src/defaults/error_state.dart';
export 'src/defaults/usage_limit.dart';
export 'src/defaults/retry_banner.dart';
export 'src/defaults/tool_approval.dart';

// Utilities
export 'src/utils/attachment_picker.dart';
