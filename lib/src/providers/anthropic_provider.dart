/// Anthropic provider implementation for RaptrAI.
///
/// Supports Claude 3 models (Opus, Sonnet, Haiku) and Claude 3.5.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raptrai/src/providers/provider_interface.dart';

/// Anthropic Claude API provider.
///
/// Example usage:
/// ```dart
/// final anthropic = RaptrAIAnthropic(apiKey: 'sk-ant-...');
///
/// await for (final chunk in anthropic.chat(
///   messages: [RaptrAIMessage.user('Hello!')],
///   model: 'claude-3-5-sonnet-20241022',
/// )) {
///   print(chunk.content);
/// }
/// ```
class RaptrAIAnthropic extends RaptrAIProvider
    with RaptrAIToolSupport, RaptrAIVisionSupport {
  RaptrAIAnthropic({
    required this.apiKey,
    this.baseUrl = 'https://api.anthropic.com/v1',
    this.apiVersion = '2023-06-01',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Anthropic API key.
  final String apiKey;

  /// Base URL for API calls.
  final String baseUrl;

  /// API version header.
  final String apiVersion;

  final http.Client _httpClient;
  StreamSubscription<dynamic>? _currentSubscription;

  @override
  String get name => 'Anthropic';

  @override
  String get id => 'anthropic';

  @override
  String get defaultModel => 'claude-3-5-sonnet-20241022';

  @override
  List<String> get visionModels => [
        'claude-3-5-sonnet-20241022',
        'claude-3-5-haiku-20241022',
        'claude-3-opus-20240229',
        'claude-3-sonnet-20240229',
        'claude-3-haiku-20240307',
      ];

  @override
  List<RaptrAIModelInfo> get availableModels => const [
        RaptrAIModelInfo(
          id: 'claude-3-5-sonnet-20241022',
          name: 'Claude 3.5 Sonnet',
          description: 'Best balance of speed and capability',
          contextWindow: 200000,
          maxOutputTokens: 8192,
          supportsVision: true,
          inputPricePerMillion: 3,
          outputPricePerMillion: 15,
        ),
        RaptrAIModelInfo(
          id: 'claude-3-5-haiku-20241022',
          name: 'Claude 3.5 Haiku',
          description: 'Fastest model, great for simple tasks',
          contextWindow: 200000,
          maxOutputTokens: 8192,
          supportsVision: true,
          inputPricePerMillion: 1,
          outputPricePerMillion: 5,
        ),
        RaptrAIModelInfo(
          id: 'claude-3-opus-20240229',
          name: 'Claude 3 Opus',
          description: 'Most capable model for complex tasks',
          contextWindow: 200000,
          maxOutputTokens: 4096,
          supportsVision: true,
          inputPricePerMillion: 15,
          outputPricePerMillion: 75,
        ),
        RaptrAIModelInfo(
          id: 'claude-3-sonnet-20240229',
          name: 'Claude 3 Sonnet',
          description: 'Balanced performance and speed',
          contextWindow: 200000,
          maxOutputTokens: 4096,
          supportsVision: true,
          inputPricePerMillion: 3,
          outputPricePerMillion: 15,
        ),
        RaptrAIModelInfo(
          id: 'claude-3-haiku-20240307',
          name: 'Claude 3 Haiku',
          description: 'Fast and efficient',
          contextWindow: 200000,
          maxOutputTokens: 4096,
          supportsVision: true,
          inputPricePerMillion: 0.25,
          outputPricePerMillion: 1.25,
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

    final request = http.Request('POST', Uri.parse('$baseUrl/messages'));
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
        message: 'Anthropic request failed: $e',
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
    // Approximate token count
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
      // Send a minimal request to validate API key
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/messages'),
        headers: _buildHeaders(),
        body: jsonEncode({
          'model': defaultModel,
          'max_tokens': 1,
          'messages': [
            {'role': 'user', 'content': 'hi'},
          ],
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': apiVersion,
    };
  }

  Map<String, dynamic> _buildRequestBody({
    required List<RaptrAIMessage> messages,
    required String model,
    required RaptrAIChatConfig config,
    required bool stream,
    List<RaptrAIToolDefinition>? tools,
  }) {
    // Extract system message if present
    String? systemPrompt;
    final conversationMessages = <RaptrAIMessage>[];

    for (final message in messages) {
      if (message.role == RaptrAIRole.system) {
        systemPrompt = message.content;
      } else {
        conversationMessages.add(message);
      }
    }

    final body = <String, dynamic>{
      'model': model,
      'messages': conversationMessages.map(_messageToJson).toList(),
      'stream': stream,
      'max_tokens': config.maxTokens ?? 4096,
    };

    if (systemPrompt != null) {
      body['system'] = systemPrompt;
    }

    if (tools != null && tools.isNotEmpty) {
      body['tools'] = tools.map(_toolToJson).toList();
    }

    if (config.temperature != null) body['temperature'] = config.temperature;
    if (config.topP != null) body['top_p'] = config.topP;
    if (config.stop != null) body['stop_sequences'] = config.stop;

    return body;
  }

  Map<String, dynamic> _messageToJson(RaptrAIMessage message) {
    final role = switch (message.role) {
      RaptrAIRole.user => 'user',
      RaptrAIRole.assistant => 'assistant',
      RaptrAIRole.tool => 'user',
      RaptrAIRole.system => 'user', // Should be filtered out
    };

    // Handle tool results
    if (message.role == RaptrAIRole.tool) {
      return {
        'role': 'user',
        'content': [
          {
            'type': 'tool_result',
            'tool_use_id': message.toolCallId,
            'content': message.content,
          },
        ],
      };
    }

    // Handle attachments (images)
    if (message.attachments != null && message.attachments!.isNotEmpty) {
      final content = <Map<String, dynamic>>[];

      for (final attachment in message.attachments!) {
        if (attachment.type == RaptrAIAttachmentType.image) {
          if (attachment.base64Data != null) {
            content.add({
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': attachment.mimeType ?? 'image/png',
                'data': attachment.base64Data,
              },
            });
          } else if (attachment.url != null) {
            // Anthropic requires base64, but we'll include URL for potential conversion
            content.add({
              'type': 'image',
              'source': {
                'type': 'url',
                'url': attachment.url,
              },
            });
          }
        }
      }

      content.add({'type': 'text', 'text': message.content});

      return {
        'role': role,
        'content': content,
      };
    }

    // Handle tool calls in assistant messages
    if (message.toolCalls != null && message.toolCalls!.isNotEmpty) {
      final content = <Map<String, dynamic>>[];

      if (message.content.isNotEmpty) {
        content.add({'type': 'text', 'text': message.content});
      }

      for (final toolCall in message.toolCalls!) {
        content.add({
          'type': 'tool_use',
          'id': toolCall.id,
          'name': toolCall.name,
          'input': toolCall.arguments,
        });
      }

      return {
        'role': role,
        'content': content,
      };
    }

    return {
      'role': role,
      'content': message.content,
    };
  }

  Map<String, dynamic> _toolToJson(RaptrAIToolDefinition tool) {
    return {
      'name': tool.name,
      'description': tool.description,
      'input_schema': tool.parameters,
    };
  }

  Stream<RaptrAIChunk> _parseSSEStream(Stream<List<int>> stream) async* {
    final buffer = StringBuffer();
    String? currentToolId;
    String? currentToolName;
    final toolArgumentsBuffer = StringBuffer();
    var toolIndex = 0;

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

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final chunk = _parseEvent(
              json,
              toolArgumentsBuffer: toolArgumentsBuffer,
              toolIndex: toolIndex,
              onToolStart: (id, name) {
                currentToolId = id;
                currentToolName = name;
                toolIndex++;
              },
              onToolEnd: () {
                currentToolId = null;
                currentToolName = null;
                toolArgumentsBuffer.clear();
              },
              currentToolId: currentToolId,
              currentToolName: currentToolName,
            );
            if (chunk != null) yield chunk;
          } catch (_) {
            // Skip malformed JSON
          }
        }
      }
    }
  }

  RaptrAIChunk? _parseEvent(
    Map<String, dynamic> json, {
    required StringBuffer toolArgumentsBuffer,
    required int toolIndex,
    required void Function(String id, String name) onToolStart,
    required void Function() onToolEnd,
    String? currentToolId,
    String? currentToolName,
  }) {
    final type = json['type'] as String?;

    switch (type) {
      case 'content_block_start':
        final contentBlock = json['content_block'] as Map<String, dynamic>?;
        if (contentBlock?['type'] == 'tool_use') {
          final id = contentBlock!['id'] as String;
          final name = contentBlock['name'] as String;
          onToolStart(id, name);
          return RaptrAIChunk(
            toolCalls: [
              RaptrAIToolCallDelta(
                index: toolIndex,
                id: id,
                name: name,
              ),
            ],
          );
        }
        return null;

      case 'content_block_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        if (delta == null) return null;

        final deltaType = delta['type'] as String?;

        if (deltaType == 'text_delta') {
          return RaptrAIChunk(content: delta['text'] as String?);
        }

        if (deltaType == 'input_json_delta') {
          final partialJson = delta['partial_json'] as String?;
          if (partialJson != null && currentToolId != null) {
            toolArgumentsBuffer.write(partialJson);
            return RaptrAIChunk(
              toolCalls: [
                RaptrAIToolCallDelta(
                  index: toolIndex,
                  argumentsDelta: partialJson,
                ),
              ],
            );
          }
        }
        return null;

      case 'content_block_stop':
        if (currentToolId != null) {
          onToolEnd();
        }
        return null;

      case 'message_delta':
        final delta = json['delta'] as Map<String, dynamic>?;
        final stopReason = delta?['stop_reason'] as String?;

        RaptrAIFinishReason? reason;
        if (stopReason != null) {
          reason = switch (stopReason) {
            'end_turn' => RaptrAIFinishReason.stop,
            'stop_sequence' => RaptrAIFinishReason.stop,
            'max_tokens' => RaptrAIFinishReason.length,
            'tool_use' => RaptrAIFinishReason.toolCalls,
            _ => RaptrAIFinishReason.other,
          };
        }

        final usage = json['usage'] as Map<String, dynamic>?;
        RaptrAIUsage? usageInfo;
        if (usage != null) {
          usageInfo = RaptrAIUsage(
            promptTokens: usage['input_tokens'] as int? ?? 0,
            completionTokens: usage['output_tokens'] as int? ?? 0,
            totalTokens: (usage['input_tokens'] as int? ?? 0) +
                (usage['output_tokens'] as int? ?? 0),
          );
        }

        if (reason != null || usageInfo != null) {
          return RaptrAIChunk(
            finishReason: reason,
            usage: usageInfo,
          );
        }
        return null;

      case 'message_stop':
        return null;

      default:
        return null;
    }
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
    final errorType = error?['type'] as String?;

    if (statusCode == 429) {
      return RaptrAIRateLimitException(
        message: message,
        code: errorType,
        statusCode: statusCode,
        provider: name,
      );
    }

    if (statusCode == 401) {
      return RaptrAIAuthException(
        message: message,
        code: errorType,
        statusCode: statusCode,
        provider: name,
      );
    }

    return RaptrAIException(
      message: message,
      code: errorType,
      statusCode: statusCode,
      provider: name,
    );
  }
}
