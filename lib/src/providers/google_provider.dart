/// Google Gemini provider implementation for RaptrAI.
///
/// Supports Gemini Pro, Gemini Pro Vision, and Gemini Ultra models.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raptrai/src/providers/provider_interface.dart';

/// Google Gemini API provider.
///
/// Example usage:
/// ```dart
/// final gemini = RaptrAIGoogle(apiKey: 'AIza...');
///
/// await for (final chunk in gemini.chat(
///   messages: [RaptrAIMessage.user('Hello!')],
///   model: 'gemini-1.5-pro',
/// )) {
///   print(chunk.content);
/// }
/// ```
class RaptrAIGoogle extends RaptrAIProvider
    with RaptrAIToolSupport, RaptrAIVisionSupport {
  RaptrAIGoogle({
    required this.apiKey,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Google AI API key.
  final String apiKey;

  /// Base URL for API calls.
  final String baseUrl;

  final http.Client _httpClient;
  StreamSubscription<dynamic>? _currentSubscription;

  @override
  String get name => 'Google';

  @override
  String get id => 'google';

  @override
  String get defaultModel => 'gemini-1.5-pro';

  @override
  List<String> get visionModels => [
        'gemini-1.5-pro',
        'gemini-1.5-flash',
        'gemini-1.5-flash-8b',
        'gemini-1.0-pro-vision',
      ];

  @override
  List<RaptrAIModelInfo> get availableModels => const [
        RaptrAIModelInfo(
          id: 'gemini-1.5-pro',
          name: 'Gemini 1.5 Pro',
          description: 'Best performing model with long context',
          contextWindow: 2000000,
          maxOutputTokens: 8192,
          supportsVision: true,
          inputPricePerMillion: 1.25,
          outputPricePerMillion: 5,
        ),
        RaptrAIModelInfo(
          id: 'gemini-1.5-flash',
          name: 'Gemini 1.5 Flash',
          description: 'Fast and versatile multimodal model',
          contextWindow: 1000000,
          maxOutputTokens: 8192,
          supportsVision: true,
          inputPricePerMillion: 0.075,
          outputPricePerMillion: 0.3,
        ),
        RaptrAIModelInfo(
          id: 'gemini-1.5-flash-8b',
          name: 'Gemini 1.5 Flash-8B',
          description: 'Smallest and fastest Flash model',
          contextWindow: 1000000,
          maxOutputTokens: 8192,
          supportsVision: true,
          inputPricePerMillion: 0.0375,
          outputPricePerMillion: 0.15,
        ),
        RaptrAIModelInfo(
          id: 'gemini-1.0-pro',
          name: 'Gemini 1.0 Pro',
          description: 'Balanced performance for text tasks',
          contextWindow: 32760,
          maxOutputTokens: 8192,
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
      config: config,
      tools: tools,
    );

    final url = '$baseUrl/models/$model:streamGenerateContent?key=$apiKey';
    final request = http.Request('POST', Uri.parse(url));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode(body);

    try {
      final response = await _httpClient.send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw _handleError(response.statusCode, errorBody);
      }

      await for (final chunk in _parseStreamResponse(response.stream)) {
        yield chunk;
      }
    } catch (e) {
      if (e is RaptrAIException) rethrow;
      throw RaptrAIException(
        message: 'Google request failed: $e',
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
    try {
      final modelId = model ?? defaultModel;
      final url = '$baseUrl/models/$modelId:countTokens?key=$apiKey';

      final body = {
        'contents': messages
            .where((m) => m.role != RaptrAIRole.system)
            .map(_messageToContent)
            .toList(),
      };

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['totalTokens'] as int? ?? 0;
      }

      // Fallback to estimate
      var totalChars = 0;
      for (final message in messages) {
        totalChars += message.content.length;
      }
      return (totalChars / 4).ceil();
    } catch (_) {
      // Fallback to estimate
      var totalChars = 0;
      for (final message in messages) {
        totalChars += message.content.length;
      }
      return (totalChars / 4).ceil();
    }
  }

  @override
  Future<bool> validate() async {
    try {
      final url = '$baseUrl/models?key=$apiKey';
      final response = await _httpClient.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _buildRequestBody({
    required List<RaptrAIMessage> messages,
    required RaptrAIChatConfig config,
    List<RaptrAIToolDefinition>? tools,
  }) {
    // Extract system instruction
    String? systemInstruction;
    final conversationMessages = <RaptrAIMessage>[];

    for (final message in messages) {
      if (message.role == RaptrAIRole.system) {
        systemInstruction = message.content;
      } else {
        conversationMessages.add(message);
      }
    }

    final body = <String, dynamic>{
      'contents': conversationMessages.map(_messageToContent).toList(),
      'generationConfig': _buildGenerationConfig(config),
    };

    if (systemInstruction != null) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction},
        ],
      };
    }

    if (tools != null && tools.isNotEmpty) {
      body['tools'] = [
        {
          'functionDeclarations': tools.map(_toolToJson).toList(),
        },
      ];
    }

    return body;
  }

  Map<String, dynamic> _buildGenerationConfig(RaptrAIChatConfig config) {
    final generationConfig = <String, dynamic>{};

    if (config.temperature != null) {
      generationConfig['temperature'] = config.temperature;
    }
    if (config.maxTokens != null) {
      generationConfig['maxOutputTokens'] = config.maxTokens;
    }
    if (config.topP != null) {
      generationConfig['topP'] = config.topP;
    }
    if (config.stop != null) {
      generationConfig['stopSequences'] = config.stop;
    }

    return generationConfig;
  }

  Map<String, dynamic> _messageToContent(RaptrAIMessage message) {
    final role = switch (message.role) {
      RaptrAIRole.user => 'user',
      RaptrAIRole.assistant => 'model',
      RaptrAIRole.tool => 'function',
      RaptrAIRole.system => 'user', // Should be filtered out
    };

    final parts = <Map<String, dynamic>>[];

    // Handle tool results
    if (message.role == RaptrAIRole.tool) {
      return {
        'role': 'function',
        'parts': [
          {
            'functionResponse': {
              'name': message.name ?? 'unknown',
              'response': {
                'result': message.content,
              },
            },
          },
        ],
      };
    }

    // Handle attachments (images)
    if (message.attachments != null && message.attachments!.isNotEmpty) {
      for (final attachment in message.attachments!) {
        if (attachment.type == RaptrAIAttachmentType.image) {
          if (attachment.base64Data != null) {
            parts.add({
              'inlineData': {
                'mimeType': attachment.mimeType ?? 'image/png',
                'data': attachment.base64Data,
              },
            });
          }
        }
      }
    }

    // Add text content
    if (message.content.isNotEmpty) {
      parts.add({'text': message.content});
    }

    // Handle tool calls in assistant messages
    if (message.toolCalls != null && message.toolCalls!.isNotEmpty) {
      for (final toolCall in message.toolCalls!) {
        parts.add({
          'functionCall': {
            'name': toolCall.name,
            'args': toolCall.arguments,
          },
        });
      }
    }

    return {
      'role': role,
      'parts': parts,
    };
  }

  Map<String, dynamic> _toolToJson(RaptrAIToolDefinition tool) {
    return {
      'name': tool.name,
      'description': tool.description,
      'parameters': tool.parameters,
    };
  }

  Stream<RaptrAIChunk> _parseStreamResponse(Stream<List<int>> stream) async* {
    final buffer = StringBuffer();

    await for (final bytes in stream) {
      buffer.write(utf8.decode(bytes));

      // Google's streaming API returns JSON array elements
      // Try to parse complete JSON objects from the buffer
      final content = buffer.toString();

      // Look for complete JSON objects in the stream
      // The response is a JSON array being streamed
      var startIndex = 0;
      var bracketCount = 0;
      var inString = false;
      var objectStart = -1;

      for (var i = 0; i < content.length; i++) {
        final char = content[i];

        if (char == '"' && (i == 0 || content[i - 1] != r'\')) {
          inString = !inString;
        }

        if (!inString) {
          if (char == '{') {
            if (bracketCount == 0) {
              objectStart = i;
            }
            bracketCount++;
          } else if (char == '}') {
            bracketCount--;
            if (bracketCount == 0 && objectStart >= 0) {
              // Found a complete JSON object
              final jsonStr = content.substring(objectStart, i + 1);
              startIndex = i + 1;

              try {
                final json = jsonDecode(jsonStr) as Map<String, dynamic>;
                final chunk = _parseChunk(json);
                if (chunk != null) yield chunk;
              } catch (_) {
                // Skip malformed JSON
              }

              objectStart = -1;
            }
          }
        }
      }

      // Keep unparsed content in buffer
      buffer
        ..clear()
        ..write(content.substring(startIndex));
    }
  }

  RaptrAIChunk? _parseChunk(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      // Check for usage metadata
      final usageMetadata = json['usageMetadata'] as Map<String, dynamic>?;
      if (usageMetadata != null) {
        return RaptrAIChunk(
          usage: RaptrAIUsage(
            promptTokens: usageMetadata['promptTokenCount'] as int? ?? 0,
            completionTokens: usageMetadata['candidatesTokenCount'] as int? ?? 0,
            totalTokens: usageMetadata['totalTokenCount'] as int? ?? 0,
          ),
        );
      }
      return null;
    }

    final candidate = candidates[0] as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    final finishReason = candidate['finishReason'] as String?;

    String? textContent;
    List<RaptrAIToolCallDelta>? toolCalls;

    if (content != null) {
      final parts = content['parts'] as List<dynamic>?;
      if (parts != null) {
        for (var i = 0; i < parts.length; i++) {
          final part = parts[i] as Map<String, dynamic>;

          if (part.containsKey('text')) {
            textContent = (textContent ?? '') + (part['text'] as String? ?? '');
          }

          if (part.containsKey('functionCall')) {
            final functionCall = part['functionCall'] as Map<String, dynamic>;
            toolCalls ??= [];
            toolCalls.add(RaptrAIToolCallDelta(
              index: i,
              id: 'call_${DateTime.now().millisecondsSinceEpoch}_$i',
              name: functionCall['name'] as String?,
              argumentsDelta: jsonEncode(functionCall['args']),
            ));
          }
        }
      }
    }

    RaptrAIFinishReason? reason;
    if (finishReason != null) {
      reason = switch (finishReason) {
        'STOP' => RaptrAIFinishReason.stop,
        'MAX_TOKENS' => RaptrAIFinishReason.length,
        'SAFETY' => RaptrAIFinishReason.contentFilter,
        'RECITATION' => RaptrAIFinishReason.contentFilter,
        'OTHER' => RaptrAIFinishReason.other,
        _ => null,
      };
    }

    // Get usage if available
    RaptrAIUsage? usage;
    final usageMetadata = json['usageMetadata'] as Map<String, dynamic>?;
    if (usageMetadata != null) {
      usage = RaptrAIUsage(
        promptTokens: usageMetadata['promptTokenCount'] as int? ?? 0,
        completionTokens: usageMetadata['candidatesTokenCount'] as int? ?? 0,
        totalTokens: usageMetadata['totalTokenCount'] as int? ?? 0,
      );
    }

    return RaptrAIChunk(
      content: textContent,
      toolCalls: toolCalls,
      finishReason: reason,
      usage: usage,
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
    final code = error?['code'] as String? ?? error?['status'] as String?;

    if (statusCode == 429) {
      return RaptrAIRateLimitException(
        message: message,
        code: code,
        statusCode: statusCode,
        provider: name,
      );
    }

    if (statusCode == 401 || statusCode == 403) {
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

