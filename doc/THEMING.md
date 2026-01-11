# Theming & Customization

Override colors, components, and message rendering.

## Quick Start

```dart
MaterialApp(
  theme: RaptrAITheme.light(),
  darkTheme: RaptrAITheme.dark(),
  themeMode: ThemeMode.system,
)
```

## Custom Accent Color

```dart
// Change the primary accent color
MaterialApp(
  theme: RaptrAITheme.light(primaryColor: Colors.purple),
  darkTheme: RaptrAITheme.dark(primaryColor: Colors.purple),
)
```

## Color Palette

RaptrAI uses a zinc-based color palette:

```dart
// Background colors
RaptrAIColors.darkBackground    // #09090B (zinc-950)
RaptrAIColors.lightBackground   // #FAFAFA (zinc-50)

RaptrAIColors.darkSurface       // #18181B (zinc-900)
RaptrAIColors.lightSurface      // #FFFFFF

// Text colors
RaptrAIColors.darkText          // #FAFAFA (zinc-50)
RaptrAIColors.lightText         // #18181B (zinc-900)

RaptrAIColors.darkTextSecondary // #A1A1AA (zinc-400)
RaptrAIColors.lightTextSecondary// #52525B (zinc-600)

RaptrAIColors.darkTextMuted     // #71717A (zinc-500)
RaptrAIColors.lightTextMuted    // #71717A (zinc-500)

// Border colors
RaptrAIColors.darkBorder        // #3F3F46 (zinc-700)
RaptrAIColors.lightBorder       // #E4E4E7 (zinc-200)

// Accent color
RaptrAIColors.accent            // #3B82F6 (blue-500)

// Semantic colors
RaptrAIColors.success           // #22C55E (green-500)
RaptrAIColors.warning           // #F59E0B (amber-500)
RaptrAIColors.error             // #EF4444 (red-500)
RaptrAIColors.info              // #3B82F6 (blue-500)

// Slate scale (for code blocks, etc.)
RaptrAIColors.slate100 - RaptrAIColors.slate900
```

## Using Colors in Widgets

```dart
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    color: isDark
        ? RaptrAIColors.darkBackground
        : RaptrAIColors.lightBackground,
    child: Text(
      'Hello',
      style: TextStyle(
        color: isDark
            ? RaptrAIColors.darkText
            : RaptrAIColors.lightText,
      ),
    ),
  );
}
```

## Custom Message Rendering

Override how messages are displayed:

```dart
RaptrAIChat(
  provider: openai,
  messageBuilder: (context, message, isStreaming) {
    if (message.role == RaptrAIRole.user) {
      return MyCustomUserBubble(content: message.content);
    } else {
      return MyCustomAssistantBubble(
        content: message.content,
        isStreaming: isStreaming,
      );
    }
  },
)
```

## Custom Welcome Screen

```dart
RaptrAIChat(
  provider: openai,
  welcomeBuilder: (context, onSuggestionTap) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logo.png', height: 64),
          SizedBox(height: 16),
          Text('Welcome to My AI', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: Text('Help me code'),
                onPressed: () => onSuggestionTap('Help me write code'),
              ),
              ActionChip(
                label: Text('Explain something'),
                onPressed: () => onSuggestionTap('Explain how...'),
              ),
            ],
          ),
        ],
      ),
    );
  },
)
```

## Custom Composer

```dart
RaptrAIChat(
  provider: openai,
  composerBuilder: (context, controller, onSend, isGenerating) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: isGenerating ? null : () => onSend(controller.text, []),
            icon: Icon(isGenerating ? Icons.stop : Icons.send),
          ),
        ],
      ),
    );
  },
)
```

## Custom Tool Call Display

```dart
RaptrAIChat(
  provider: openai,
  toolCallBuilder: (context, toolCall, status, result) {
    return Card(
      child: ListTile(
        leading: Icon(
          status == RaptrAIToolCallStatus.running
              ? Icons.hourglass_empty
              : status == RaptrAIToolCallStatus.completed
                  ? Icons.check_circle
                  : Icons.error,
        ),
        title: Text(toolCall.name),
        subtitle: Text(status.name),
        trailing: result != null
            ? Text(result.data.toString())
            : null,
      ),
    );
  },
)
```

## Component-Level Theming

Individual components accept style parameters:

```dart
// Button variants
RaptrAIButton(
  label: 'Click me',
  style: RaptrAIButtonStyle.primary, // secondary, outlined, ghost, danger
  size: RaptrAIButtonSize.medium,    // small, large
)

// Card variants
RaptrAICard(
  style: RaptrAICardStyle.bordered,  // elevated, filled, ghost
  child: content,
)

// Badge variants
RaptrAIBadge(
  label: 'New',
  variant: RaptrAIBadgeVariant.success, // info, warning, error, neutral
)

// Copy button styles
RaptrAICopyButton(
  textToCopy: code,
  style: RaptrAICopyButtonStyle.icon, // text, outlined, filled
)
```

## Dark Mode Detection

```dart
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // or use MediaQuery
  final systemDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
}
```

## Full Theme Override

For complete control, create your own theme:

```dart
final myTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF1A1A2E),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF00D9FF),
    secondary: Color(0xFFFF6B6B),
    surface: Color(0xFF16213E),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
  ),
  // ... more customization
);

MaterialApp(
  theme: myTheme,
  home: RaptrAIChat(provider: openai),
)
```

## Code Block Styling

```dart
RaptrAICodeBlock(
  code: 'print("Hello")',
  language: 'dart',
  showLineNumbers: true,
  backgroundColor: Colors.grey[900],
  codeStyle: TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 14,
    color: Colors.white,
  ),
)
```

## Responsive Design

RaptrAI components are responsive by default. For manual control:

```dart
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final isDesktop = width > 1024;
  final isTablet = width > 768;

  if (isDesktop) {
    return Row(
      children: [
        SizedBox(width: 300, child: ThreadList()),
        Expanded(child: RaptrAIChat(...)),
      ],
    );
  } else {
    return RaptrAIChat(...);
  }
}
```
