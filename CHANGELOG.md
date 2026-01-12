# Changelog

All notable changes to this project will be documented in this file.

## [0.1.1] - 2025-01-12

### Improved

- **Chat Input Bar**: Modern floating pill-style input with shadow and rounded corners
- **Message Bubbles**: Cleaner user/assistant message styling with better typography
- **Layout**: Improved spacing and padding throughout the chat interface
- **Send Button**: Animated send button with smooth state transitions
- **Stop Button**: Clean square icon for stopping generation

### Fixed

- Chat input now properly floats at bottom with safe area handling
- Message list padding adjusted for better readability
- Actions visibility improved (always visible with opacity animation)

## [0.1.0] - 2024-12-27

### Added

- Initial release of RaptrAI - The Complete AI Framework for Flutter
- A [raptrx.com](https://raptrx.com) product

#### AI Provider Integration
- `RaptrAIProvider` - Abstract interface for AI providers
- `RaptrAIOpenAI` - OpenAI GPT-4, GPT-3.5 integration with streaming
- `RaptrAIAnthropic` - Anthropic Claude 3 (Opus, Sonnet, Haiku) integration
- `RaptrAIGoogle` - Google Gemini Pro/Ultra integration
- Unified message types: `RaptrAIMessage`, `RaptrAIChunk`, `RaptrAIResponse`
- Support for attachments, tool calls, and multimodal content

#### Conversation Management
- `RaptrAIConversation` - Full conversation state with message branching
- `RaptrAIConversationController` - High-level controller for AI interactions
- Message branching for edit/regenerate functionality
- Context window management for token limits

#### Tool/Function Calling
- `RaptrAIToolRegistry` - Register and manage tools
- `RaptrAIToolExecutor` - Automatic tool execution with approval flow
- JSON schema generation from tool definitions
- Built-in UI for tool call status and results

#### Persistence Layer
- `RaptrAIStorage` - Abstract storage interface
- `RaptrAIHiveStorage` - Local encrypted storage with Hive
- `RaptrAIMemoryStorage` - In-memory storage for testing
- Offline-first with cloud sync support

#### Business Features
- `RaptrAIUsageTracker` - Token and cost tracking
- `RaptrAIAnalytics` - Event tracking system
- Rate limiting with configurable limits
- Model pricing for cost estimation

#### High-Level Widgets
- `RaptrAIChat` - Complete AI chat with all features integrated
- `RaptrAIChatWithSidebar` - Full chat experience with thread list

#### Thread & Assistant Components
- `RaptrAIThread` - Main chat container with messages and composer
- `RaptrAIThreadWelcome` - Welcome screen with greeting and suggestions
- `RaptrAIThreadMessages` - Scrollable message list with auto-scroll
- `RaptrAIThreadList` - Conversation sidebar
- `RaptrAIComposer` - Full input area with attachments
- `RaptrAIAssistantMessage` / `RaptrAIUserMessage` - Message components
- `RaptrAIToolCallWidget` - Tool call display with progress and results
- `RaptrAIAssistantModal` - Floating chat modal
- `RaptrAIBranchPicker` - Navigate message branches

#### Chat Components
- `RaptrAIChatBubble` - Message bubbles with customizable styling
- `RaptrAIChatInput` - Full-featured input with attachments
- `RaptrAITypingIndicator` - Animated typing dots
- `RaptrAIStreamingText` - Text with blinking cursor
- `RaptrAITypewriterText` - Character-by-character reveal

#### Prompt Components
- `RaptrAIPromptContainer` - Container with card, floating, fullscreen, minimal styles
- `RaptrAIPromptInput` - Text input with multiple style variants
- `RaptrAIPromptMessage` - User/assistant messages with actions
- `RaptrAIPromptSuggestions` - Quick action chips/cards

#### Common Components
- `RaptrAIButton` - Primary, secondary, outlined, ghost, danger variants
- `RaptrAIBadge` - Status indicators with multiple variants
- `RaptrAICard` - Bordered, elevated, filled, ghost styles
- `RaptrAICopyButton` - Copy to clipboard with visual feedback
- `RaptrAIAlert` - Info, success, warning, error alerts

#### Layout Components
- `RaptrAISidebar` - Navigation sidebar with items
- `RaptrAIHistoryPanel` - Conversation history list
- `RaptrAIPromptContainerLayout` - Responsive layout
- `RaptrAIChatLayout` - Full chat screen layout

#### Theme System
- `RaptrAITheme` - Light and dark theme support
- `RaptrAIColors` - Modern color system (Zinc scale)
- `RaptrAITypography` - Inter font with consistent text styles
- Fully customizable accent colors
