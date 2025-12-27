/// OpenAI provider implementation for RaptrAI.
///
/// Supports GPT-4, GPT-4 Turbo, GPT-3.5 Turbo, and other OpenAI models.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raptrai/src/providers/provider_interface.dart';

/// OpenAI API provider.
///
/// Example usage:
/// ```dart
/// final openai = RaptrAIOpenAI(apiKey: 'sk-...');
///
/// await for (final chunk in openai.chat(
///   messages: [RaptrAIMessage.user('Hello!')],
///   model: 'gpt-4-turbo',
/// )) {
///   print(chunk.content);
/// }
/// ```
class RaptrAIOpenAI extends RaptrAIProvider with RaptrAIToolSupport, RaptrAIVisionSupport {
  RaptrAIOpenAI({
    required this.apiKey,
    this.organization,
    this.baseUrl = 'https://api.openai.com/v1',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// OpenAI API key.
  final String apiKey;

  /// Optional organization ID.
  final String? organization;

  /// Base URL for API calls.
  final String baseUrl;

  final http.Client _httpClient;
  StreamSubscription<dynamic>? _currentSubscription;

  @override
  String get name => 'OpenAI';

  @override
  String get id => 'openai';

  @override
  String get defaultModel => 'gpt-4-turbo';

  @override
  List<String> get visionModels => [
    'gpt-4-turbo',
    'gpt-4-turbo-preview',
    'gpt-4-vision-preview',
    'gpt-4o',
    'gpt-4o-mini',
  ];

  @override
  List<RaptrAIModelInfo> get availableModels => const [
    RaptrAIModelInfo(
      id: 'gpt-4o',
      name: 'GPT-4o',
      description: 'Most capable model, multimodal',
      contextWindow: 128000,
      maxOutputTokens: 4096,
      supportsVision: true,
      inputPricePerMillion: 5,
      outputPricePerMillion: 15,
    ),
    RaptrAIModelInfo(
      id: 'gpt-4o-mini',
      name: 'GPT-4o Mini',
      description: 'Fast and affordable',
      contextWindow: 128000,
      maxOutputTokens: 16384,
      supportsVision: true,
      inputPricePerMillion: 0.15,
      outputPricePerMillion: 0.6,
    ),
    RaptrAIModelInfo(
      id: 'gpt-4-turbo',
      name: 'GPT-4 Turbo',
      description: 'Latest GPT-4 model with vision',
      contextWindow: 128000,
      maxOutputTokens: 4096,
      supportsVision: true,
      inputPricePerMillion: 10,
      outputPricePerMillion: 30,
    ),
    RaptrAIModelInfo(
      id: 'gpt-4',
      name: 'GPT-4',
      description: 'Original GPT-4 model',
      contextWindow: 8192,
      maxOutputTokens: 4096,
      inputPricePerMillion: 30,
      outputPricePerMillion: 60,
    ),
    RaptrAIModelInfo(
      id: 'gpt-3.5-turbo',
      name: 'GPT-3.5 Turbo',
      description: 'Fast and cost-effective',
      contextWindow: 16385,
      maxOutputTokens: 4096,
      inputPricePerMillion: 0.5,
      outputPricePerMillion: 1.5,
    ),
  ];

  @override
  Stream<RaptrAIChunk> chat({
    required List<RaptrAIMessage> messages,
    required String model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig config = RaptrAIChatConfig.defaults,
  }) async* {
    final body = _buildRequestBody(
      messages: messages,
      model: model,
      config: config,
      stream: true,
      tools: tools,
    );

    final request = http.Request('POST', Uri.parse('$baseUrl/chat/completions'));
    request.headers.addAll(_buildHeaders());
    request.body = jsonEncode(body);

    try {
      final response = await _httpClient.send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw _handleError(response.statusCode, errorBody);
      }

      await for (final chunk in _parseSSEStream(response.stream)) {
        yield chunk;
      }
    } catch (e) {
      if (e is RaptrAIException) rethrow;
      throw RaptrAIException(
        message: 'OpenAI request failed: $e',
        provider: name,
        originalError: e,
      );
    }
  }

  @override
  void cancel() {
    _currentSubscription?.cancel();
    _currentSubscription = null;
  }

  @override
  Future<int> countTokens(List<RaptrAIMessage> messages, {String? model}) async {
    // Approximate token count using character count / 4
    // For accurate counts, use tiktoken or the API
    var totalChars = 0;
    for (final message in messages) {
      totalChars += message.content.length;
      if (message.name != null) totalChars += message.name!.length;
    }
    return (totalChars / 4).ceil();
  }

  @override
  Future<bool> validate() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/models'),
        headers: _buildHeaders(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    if (organization != null) {
      headers['OpenAI-Organization'] = organization!;
    }
    return headers;
  }

  Map<String, dynamic> _buildRequestBody({
    required List<RaptrAIMessage> messages,
    required String model,
    required RaptrAIChatConfig config,
    required bool stream,
    List<RaptrAIToolDefinition>? tools,
  }) {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages.map(_messageToJson).toList(),
      'stream': stream,
    };

    if (tools != null && tools.isNotEmpty) {
      body['tools'] = tools.map((t) => t.toJson()).toList();
    }

    if (config.temperature != null) body['temperature'] = config.temperature;
    if (config.maxTokens != null) body['max_tokens'] = config.maxTokens;
    if (config.topP != null) body['top_p'] = config.topP;
    if (config.frequencyPenalty != null) body['frequency_penalty'] = config.frequencyPenalty;
    if (config.presencePenalty != null) body['presence_penalty'] = config.presencePenalty;
    if (config.stop != null) body['stop'] = config.stop;
    if (config.user != null) body['user'] = config.user;

    if (stream) {
      body['stream_options'] = {'include_usage': true};
    }

    return body;
  }

  Map<String, dynamic> _messageToJson(RaptrAIMessage message) {
    final json = <String, dynamic>{
      'role': message.role.name,
    };

    // Handle content with attachments
    if (message.attachments != null && message.attachments!.isNotEmpty) {
      final content = <Map<String, dynamic>>[
        {'type': 'text', 'text': message.content},
      ];
      for (final attachment in message.attachments!) {
        if (attachment.type == RaptrAIAttachmentType.image) {
          if (attachment.url != null) {
            content.add({
              'type': 'image_url',
              'image_url': {'url': attachment.url},
            });
          } else if (attachment.base64Data != null) {
            content.add({
              'type': 'image_url',
              'image_url': {
                'url': 'data:${attachment.mimeType ?? 'image/png'};base64,${attachment.base64Data}',
              },
            });
          }
        }
      }
      json['content'] = content;
    } else {
      json['content'] = message.content;
    }

    if (message.name != null) json['name'] = message.name;
    if (message.toolCallId != null) json['tool_call_id'] = message.toolCallId;

    if (message.toolCalls != null && message.toolCalls!.isNotEmpty) {
      json['tool_calls'] = message.toolCalls!
          .map(
            (tc) => {
              'id': tc.id,
              'type': 'function',
              'function': {
                'name': tc.name,
                'arguments': jsonEncode(tc.arguments),
              },
            },
          )
          .toList();
    }

    return json;
  }

  Stream<RaptrAIChunk> _parseSSEStream(Stream<List<int>> stream) async* {
    final buffer = StringBuffer();

    await for (final bytes in stream) {
      buffer.write(utf8.decode(bytes));

      while (true) {
        final content = buffer.toString();
        final eventEnd = content.indexOf('\n\n');
        if (eventEnd == -1) break;

        final event = content.substring(0, eventEnd);
        buffer
          ..clear()
          ..write(content.substring(eventEnd + 2));

        if (event.startsWith('data: ')) {
          final data = event.substring(6).trim();
          if (data == '[DONE]') {
            return;
          }

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final chunk = _parseChunk(json);
            if (chunk != null) yield chunk;
          } catch (_) {
            // Skip malformed JSON
          }
        }
      }
    }
  }

  RaptrAIChunk? _parseChunk(Map<String, dynamic> json) {
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      // Check for usage in final message
      final usage = json['usage'] as Map<String, dynamic>?;
      if (usage != null) {
        return RaptrAIChunk(
          usage: RaptrAIUsage(
            promptTokens: usage['prompt_tokens'] as int,
            completionTokens: usage['completion_tokens'] as int,
            totalTokens: usage['total_tokens'] as int,
          ),
        );
      }
      return null;
    }

    final choice = choices[0] as Map<String, dynamic>;
    final delta = choice['delta'] as Map<String, dynamic>?;
    final finishReason = choice['finish_reason'] as String?;

    String? content;
    List<RaptrAIToolCallDelta>? toolCalls;

    if (delta != null) {
      content = delta['content'] as String?;

      final rawToolCalls = delta['tool_calls'] as List<dynamic>?;
      if (rawToolCalls != null) {
        toolCalls = rawToolCalls.map((tc) {
          final tcMap = tc as Map<String, dynamic>;
          final function = tcMap['function'] as Map<String, dynamic>?;
          return RaptrAIToolCallDelta(
            index: tcMap['index'] as int,
            id: tcMap['id'] as String?,
            name: function?['name'] as String?,
            argumentsDelta: function?['arguments'] as String?,
          );
        }).toList();
      }
    }

    RaptrAIFinishReason? reason;
    if (finishReason != null) {
      reason = switch (finishReason) {
        'stop' => RaptrAIFinishReason.stop,
        'length' => RaptrAIFinishReason.length,
        'tool_calls' => RaptrAIFinishReason.toolCalls,
        'content_filter' => RaptrAIFinishReason.contentFilter,
        _ => RaptrAIFinishReason.other,
      };
    }

    return RaptrAIChunk(
      content: content,
      toolCalls: toolCalls,
      finishReason: reason,
    );
  }

  RaptrAIException _handleError(int statusCode, String body) {
    Map<String, dynamic>? errorJson;
    try {
      errorJson = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      // Not JSON
    }

    final error = errorJson?['error'] as Map<String, dynamic>?;
    final message = error?['message'] as String? ?? body;
    final code = error?['code'] as String?;

    if (statusCode == 429) {
      return RaptrAIRateLimitException(
        message: message,
        code: code,
        statusCode: statusCode,
        provider: name,
      );
    }

    if (statusCode == 401) {
      return RaptrAIAuthException(
        message: message,
        code: code,
        statusCode: statusCode,
        provider: name,
      );
    }

    return RaptrAIException(
      message: message,
      code: code,
      statusCode: statusCode,
      provider: name,
    );
  }
}
