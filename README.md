# RaptrAI

[![pub package](https://img.shields.io/pub/v/raptrai.svg)](https://pub.dev/packages/raptrai)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**The opinionated AI UI + runtime toolkit for Flutter.** Like shadcn/ui for AI apps.

## Install

```bash
flutter pub add raptrai
```

## 30 Seconds to AI Chat

```dart
import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: RaptrAITheme.dark(),
      home: Scaffold(
        body: RaptrAIChat(
          provider: RaptrAIOpenAI(apiKey: 'sk-...'),
        ),
      ),
    );
  }
}
```

**That's it.** Streaming, tool calling, conversation management, theming — all built in.

## Examples

Copy, change API key, run:

| Example | Description |
|---------|-------------|
| [basic_chat](example_apps/basic_chat) | Minimal AI chat in ~40 lines |
| [tool_calling](example_apps/tool_calling) | Weather + calculator function calling |
| [multi_thread](example_apps/multi_thread) | Conversation history with sidebar |

## Providers

```dart
// OpenAI
RaptrAIChat(provider: RaptrAIOpenAI(apiKey: 'sk-...'))

// Anthropic Claude
RaptrAIChat(provider: RaptrAIAnthropic(apiKey: 'sk-ant-...'))

// Google Gemini
RaptrAIChat(provider: RaptrAIGoogle(apiKey: 'AIza...'))
```

## Tool Calling

```dart
final tool = RaptrAIToolBuilder('get_weather')
    .description('Get weather for a location')
    .addStringParam('location', required: true)
    .handler((args) async => {'temp': 72, 'condition': 'sunny'})
    .build();

registry.register(tool);

RaptrAIChat(
  provider: openai,
  tools: registry.definitions,
  toolRegistry: registry,
)
```

## Persistence

```dart
// In-memory (testing)
RaptrAIChat(storage: RaptrAIMemoryStorage())

// Local persistence
RaptrAIChat(storage: RaptrAIHiveStorage())
```

## Extend

| Guide | What you'll learn |
|-------|-------------------|
| [PROVIDERS.md](doc/PROVIDERS.md) | Add a custom AI provider |
| [STORAGE.md](doc/STORAGE.md) | Implement custom persistence |
| [TOOLS.md](doc/TOOLS.md) | Create and customize tools |
| [THEMING.md](doc/THEMING.md) | Override message rendering |

## CLI (Templates)

Add pre-built screens to your project:

```bash
# List available templates
dart run raptrai list

# Add a template
dart run raptrai add basic-chat
dart run raptrai add tool-calling --path lib/features/ai
dart run raptrai add multi-thread
```

## API Reference

Full documentation: [raptrai.raptrx.com](https://raptrai.raptrx.com)

## Roadmap

- **More providers** — Community-driven integrations
- **More templates** — Real-world app patterns
- **Stability & DX** — Polish based on feedback

## License

MIT License - [raptrx.com](https://raptrx.com)
