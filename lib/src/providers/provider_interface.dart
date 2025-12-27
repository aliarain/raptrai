/// Abstract interface for AI providers in RaptrAI.
///
/// All AI providers (OpenAI, Anthropic, Google, etc.) implement this interface.
library;

import 'dart:async';
import 'dart:convert';

import 'package:raptrai/src/providers/provider_types.dart';

export 'package:raptrai/src/providers/provider_types.dart';

/// Abstract interface that all AI providers must implement.
///
/// Example usage:
/// ```dart
/// final provider = RaptrAIOpenAI(apiKey: 'sk-...');
///
/// // Streaming
/// await for (final chunk in provider.chat(
///   messages: [RaptrAIMessage.user('Hello!')],
///   model: 'gpt-4-turbo',
/// )) {
///   print(chunk.content);
/// }
///
/// // Non-streaming
/// final response = await provider.chatComplete(
///   messages: [RaptrAIMessage.user('Hello!')],
///   model: 'gpt-4-turbo',
/// );
/// print(response.message.content);
/// ```
abstract class RaptrAIProvider {
  /// Provider name for display (e.g., 'OpenAI', 'Anthropic').
  String get name;

  /// Provider identifier (e.g., 'openai', 'anthropic').
  String get id;

  /// Available models from this provider.
  List<RaptrAIModelInfo> get availableModels;

  /// Default model to use if none specified.
  String get defaultModel;

  /// Send messages and get streaming response.
  ///
  /// Returns a stream of [RaptrAIChunk] that can be processed as they arrive.
  /// The final chunk will have [RaptrAIChunk.isComplete] set to true.
  ///
  /// Example:
  /// ```dart
  /// final buffer = StringBuffer();
  /// await for (final chunk in provider.chat(messages: messages, model: model)) {
  ///   if (chunk.content != null) {
  ///     buffer.write(chunk.content);
  ///     onChunk(buffer.toString()); // Update UI
  ///   }
  /// }
  /// ```
  Stream<RaptrAIChunk> chat({
    required List<RaptrAIMessage> messages,
    required String model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig config,
  });

  /// Send messages and get complete response.
  ///
  /// This is a convenience method that collects all streaming chunks
  /// and returns a complete [RaptrAIResponse].
  Future<RaptrAIResponse> chatComplete({
    required List<RaptrAIMessage> messages,
    required String model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig config = RaptrAIChatConfig.defaults,
  }) async {
    final chunks = <RaptrAIChunk>[];
    await for (final chunk in chat(
      messages: messages,
      model: model,
      tools: tools,
      config: config,
    )) {
      chunks.add(chunk);
    }
    return _combineChunks(chunks);
  }

  /// Cancel any ongoing request.
  void cancel();

  /// Count tokens for the given messages.
  ///
  /// Returns approximate token count. Some providers may not support
  /// exact token counting, in which case an estimate is returned.
  Future<int> countTokens(List<RaptrAIMessage> messages, {String? model});

  /// Check if the provider is configured correctly.
  Future<bool> validate();

  /// Combine streaming chunks into a complete response.
  RaptrAIResponse _combineChunks(List<RaptrAIChunk> chunks) {
    final contentBuffer = StringBuffer();
    final toolCallMap = <int, _ToolCallBuilder>{};
    RaptrAIFinishReason? finishReason;
    RaptrAIUsage? usage;

    for (final chunk in chunks) {
      if (chunk.content != null) {
        contentBuffer.write(chunk.content);
      }

      if (chunk.toolCalls != null) {
        for (final delta in chunk.toolCalls!) {
          toolCallMap.putIfAbsent(delta.index, () => _ToolCallBuilder());
          toolCallMap[delta.index]!.apply(delta);
        }
      }

      if (chunk.finishReason != null) {
        finishReason = chunk.finishReason;
      }

      if (chunk.usage != null) {
        usage = chunk.usage;
      }
    }

    final toolCalls = <RaptrAIToolCall>[];
    for (final builder in toolCallMap.values) {
      if (builder.isComplete) {
        toolCalls.add(builder.build());
      }
    }

    return RaptrAIResponse(
      message: RaptrAIMessage.assistant(
        contentBuffer.toString(),
        toolCalls: toolCalls.isNotEmpty ? toolCalls : null,
      ),
      finishReason: finishReason ?? RaptrAIFinishReason.stop,
      usage: usage,
    );
  }
}

/// Helper class to build tool calls from streaming deltas.
class _ToolCallBuilder {
  String? id;
  String? name;
  final _argumentsBuffer = StringBuffer();

  void apply(RaptrAIToolCallDelta delta) {
    if (delta.id != null) id = delta.id;
    if (delta.name != null) name = delta.name;
    if (delta.argumentsDelta != null) {
      _argumentsBuffer.write(delta.argumentsDelta);
    }
  }

  bool get isComplete => id != null && name != null;

  RaptrAIToolCall build() {
    var arguments = <String, dynamic>{};
    final argsString = _argumentsBuffer.toString();
    if (argsString.isNotEmpty) {
      try {
        final decoded = jsonDecode(argsString);
        if (decoded is Map) {
          arguments = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // If parsing fails, store raw string
        arguments = {'_raw': argsString};
      }
    }
    return RaptrAIToolCall(
      id: id!,
      name: name!,
      arguments: arguments,
    );
  }
}

/// Mixin for providers that support tool/function calling.
mixin RaptrAIToolSupport on RaptrAIProvider {
  /// Execute a tool call and return the result as a message.
  ///
  /// This is a helper for handling tool calls in a conversation loop.
  Future<RaptrAIMessage> executeToolCall(
    RaptrAIToolCall toolCall,
    Future<String> Function(String name, Map<String, dynamic> arguments) executor,
  ) async {
    try {
      final result = await executor(toolCall.name, toolCall.arguments);
      return RaptrAIMessage.tool(
        toolCallId: toolCall.id,
        name: toolCall.name,
        content: result,
      );
    } catch (e) {
      return RaptrAIMessage.tool(
        toolCallId: toolCall.id,
        name: toolCall.name,
        content: 'Error executing tool: $e',
      );
    }
  }
}

/// Mixin for providers that support vision/image inputs.
mixin RaptrAIVisionSupport on RaptrAIProvider {
  /// List of models that support vision.
  List<String> get visionModels;

  /// Check if a model supports vision.
  bool supportsVision(String model) => visionModels.contains(model);
}

/// A provider that combines multiple providers.
///
/// Useful for falling back between providers or load balancing.
class RaptrAIMultiProvider extends RaptrAIProvider {
  RaptrAIMultiProvider({
    required this.providers,
    this.defaultProviderId,
  }) : assert(providers.isNotEmpty, 'At least one provider is required');

  /// Available providers.
  final List<RaptrAIProvider> providers;

  /// Default provider to use.
  final String? defaultProviderId;

  /// Get provider by ID.
  RaptrAIProvider? getProvider(String id) {
    for (final provider in providers) {
      if (provider.id == id) return provider;
    }
    return null;
  }

  /// Get the default provider.
  RaptrAIProvider get _defaultProvider {
    if (defaultProviderId != null) {
      final provider = getProvider(defaultProviderId!);
      if (provider != null) return provider;
    }
    return providers.first;
  }

  @override
  String get name => 'Multi Provider';

  @override
  String get id => 'multi';

  @override
  List<RaptrAIModelInfo> get availableModels {
    return providers.expand((p) => p.availableModels).toList();
  }

  @override
  String get defaultModel => _defaultProvider.defaultModel;

  @override
  Stream<RaptrAIChunk> chat({
    required List<RaptrAIMessage> messages,
    required String model,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig config = RaptrAIChatConfig.defaults,
  }) {
    // Find provider that has this model
    final provider = _findProviderForModel(model);
    return provider.chat(
      messages: messages,
      model: model,
      tools: tools,
      config: config,
    );
  }

  @override
  void cancel() {
    for (final provider in providers) {
      provider.cancel();
    }
  }

  @override
  Future<int> countTokens(List<RaptrAIMessage> messages, {String? model}) {
    final provider = model != null ? _findProviderForModel(model) : _defaultProvider;
    return provider.countTokens(messages, model: model);
  }

  @override
  Future<bool> validate() async {
    for (final provider in providers) {
      if (await provider.validate()) return true;
    }
    return false;
  }

  RaptrAIProvider _findProviderForModel(String model) {
    for (final provider in providers) {
      if (provider.availableModels.any((m) => m.id == model)) {
        return provider;
      }
    }
    // Fall back to default if model not found
    return _defaultProvider;
  }
}
