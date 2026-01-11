# Custom AI Providers

Add support for any AI provider by implementing `RaptrAIProvider`.

## Quick Start

```dart
class MyCustomProvider extends RaptrAIProvider {
  MyCustomProvider({required this.apiKey});

  final String apiKey;

  @override
  String get name => 'Custom';

  @override
  String get id => 'custom';

  @override
  String get defaultModel => 'custom-model-v1';

  @override
  List<String> get availableModels => ['custom-model-v1', 'custom-model-v2'];

  @override
  Stream<RaptrAIChunk> chat({
    required List<RaptrAIMessage> messages,
    String? model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig? config,
  }) async* {
    // Your streaming implementation
    yield RaptrAIChunk(content: 'Hello from custom provider!');
  }

  @override
  Future<RaptrAIResponse> chatComplete({
    required List<RaptrAIMessage> messages,
    String? model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig? config,
  }) async {
    // Your non-streaming implementation
    return RaptrAIResponse(
      id: 'resp-123',
      content: 'Hello from custom provider!',
      model: model ?? defaultModel,
    );
  }

  @override
  void cancel() {
    // Cancel any in-flight requests
  }
}
```

## Use Your Provider

```dart
RaptrAIChat(
  provider: MyCustomProvider(apiKey: 'your-key'),
)
```

## Required Methods

| Method | Purpose |
|--------|---------|
| `chat()` | Stream responses (SSE/chunked) |
| `chatComplete()` | Single response (non-streaming) |
| `cancel()` | Cancel in-flight requests |

## Required Getters

| Getter | Purpose |
|--------|---------|
| `name` | Display name ("OpenAI", "Claude") |
| `id` | Unique identifier ("openai", "anthropic") |
| `defaultModel` | Default model ID |
| `availableModels` | List of supported models |

## Optional Methods

```dart
// Token counting
@override
Future<int> countTokens(List<RaptrAIMessage> messages, {String? model}) async {
  // Return estimated token count
  return messages.fold(0, (sum, m) => sum + m.content.length ~/ 4);
}

// API key validation
@override
Future<bool> validate() async {
  // Test API connectivity
  return true;
}
```

## Handling Tool Calls

```dart
@override
Stream<RaptrAIChunk> chat({...}) async* {
  // Parse tool calls from your API response
  if (response.hasToolCalls) {
    yield RaptrAIChunk(
      content: '',
      toolCalls: [
        RaptrAIToolCall(
          id: 'call-123',
          name: 'get_weather',
          arguments: {'location': 'San Francisco'},
        ),
      ],
    );
  }
}
```

## Error Handling

Throw `RaptrAIException` for API errors:

```dart
throw RaptrAIException(
  message: 'Rate limit exceeded',
  code: 'rate_limit',
  provider: id,
  statusCode: 429,
);
```

## Multi-Provider Setup

Combine providers with `RaptrAIMultiProvider`:

```dart
final multiProvider = RaptrAIMultiProvider(
  providers: {
    'openai': RaptrAIOpenAI(apiKey: openAIKey),
    'anthropic': RaptrAIAnthropic(apiKey: anthropicKey),
    'custom': MyCustomProvider(apiKey: customKey),
  },
  defaultProvider: 'openai',
);

// Switch at runtime
multiProvider.switchTo('anthropic');
```

## Example: Ollama Provider

```dart
class OllamaProvider extends RaptrAIProvider {
  OllamaProvider({this.baseUrl = 'http://localhost:11434'});

  final String baseUrl;

  @override
  String get name => 'Ollama';

  @override
  String get id => 'ollama';

  @override
  String get defaultModel => 'llama2';

  @override
  List<String> get availableModels => ['llama2', 'codellama', 'mistral'];

  @override
  Stream<RaptrAIChunk> chat({...}) async* {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      body: jsonEncode({
        'model': model ?? defaultModel,
        'messages': messages.map((m) => m.toJson()).toList(),
        'stream': true,
      }),
    );

    await for (final line in response.stream.transform(utf8.decoder).transform(LineSplitter())) {
      final json = jsonDecode(line);
      yield RaptrAIChunk(content: json['message']['content']);
    }
  }
}
```
