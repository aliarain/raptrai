/// Core types for AI providers in RaptrAI.
///
/// These types are used across all AI provider implementations.
library;

import 'package:flutter/foundation.dart';

/// Role of a message sender.
enum RaptrAIRole {
  /// User message
  user,

  /// Assistant/AI message
  assistant,

  /// System prompt
  system,

  /// Tool/function result
  tool,
}

/// A message in a conversation.
@immutable
class RaptrAIMessage {
  const RaptrAIMessage({
    required this.role,
    required this.content,
    this.id,
    this.name,
    this.toolCallId,
    this.toolCalls,
    this.attachments,
    this.metadata,
  });

  /// Create a user message.
  factory RaptrAIMessage.user(String content, {List<RaptrAIAttachment>? attachments}) {
    return RaptrAIMessage(
      role: RaptrAIRole.user,
      content: content,
      attachments: attachments,
    );
  }

  /// Create an assistant message.
  factory RaptrAIMessage.assistant(String content, {List<RaptrAIToolCall>? toolCalls}) {
    return RaptrAIMessage(
      role: RaptrAIRole.assistant,
      content: content,
      toolCalls: toolCalls,
    );
  }

  /// Create a system message.
  factory RaptrAIMessage.system(String content) {
    return RaptrAIMessage(
      role: RaptrAIRole.system,
      content: content,
    );
  }

  /// Create a tool result message.
  factory RaptrAIMessage.tool({
    required String toolCallId,
    required String content,
    String? name,
  }) {
    return RaptrAIMessage(
      role: RaptrAIRole.tool,
      content: content,
      toolCallId: toolCallId,
      name: name,
    );
  }

  /// Unique identifier for this message.
  final String? id;

  /// Role of the sender.
  final RaptrAIRole role;

  /// Text content of the message.
  final String content;

  /// Name of the sender (for tool messages).
  final String? name;

  /// Tool call ID this message is responding to (for tool messages).
  final String? toolCallId;

  /// Tool calls made by the assistant.
  final List<RaptrAIToolCall>? toolCalls;

  /// Attachments (images, files, etc).
  final List<RaptrAIAttachment>? attachments;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Create a copy with updated fields.
  RaptrAIMessage copyWith({
    String? id,
    RaptrAIRole? role,
    String? content,
    String? name,
    String? toolCallId,
    List<RaptrAIToolCall>? toolCalls,
    List<RaptrAIAttachment>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return RaptrAIMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      name: name ?? this.name,
      toolCallId: toolCallId ?? this.toolCallId,
      toolCalls: toolCalls ?? this.toolCalls,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'RaptrAIMessage(role: $role, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
}

/// An attachment to a message (image, file, etc).
@immutable
class RaptrAIAttachment {
  const RaptrAIAttachment({
    required this.type,
    this.id,
    this.url,
    this.base64Data,
    this.mimeType,
    this.name,
    this.size,
  });

  /// Unique identifier for the attachment.
  final String? id;

  /// File size in bytes.
  final int? size;

  /// Create an image attachment from URL.
  factory RaptrAIAttachment.imageUrl(String url) {
    return RaptrAIAttachment(
      type: RaptrAIAttachmentType.image,
      url: url,
    );
  }

  /// Create an image attachment from base64.
  factory RaptrAIAttachment.imageBase64(String base64Data, {String mimeType = 'image/png'}) {
    return RaptrAIAttachment(
      type: RaptrAIAttachmentType.image,
      base64Data: base64Data,
      mimeType: mimeType,
    );
  }

  /// Create from JSON.
  factory RaptrAIAttachment.fromJson(Map<String, dynamic> json) {
    return RaptrAIAttachment(
      type: RaptrAIAttachmentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RaptrAIAttachmentType.file,
      ),
      id: json['id'] as String?,
      url: json['url'] as String?,
      base64Data: json['base64Data'] as String?,
      mimeType: json['mimeType'] as String?,
      name: json['name'] as String?,
      size: json['size'] as int?,
    );
  }

  /// Type of attachment.
  final RaptrAIAttachmentType type;

  /// URL of the attachment.
  final String? url;

  /// Base64 encoded data.
  final String? base64Data;

  /// MIME type of the attachment.
  final String? mimeType;

  /// File name.
  final String? name;

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (base64Data != null) 'base64Data': base64Data,
      if (mimeType != null) 'mimeType': mimeType,
      if (name != null) 'name': name,
      if (size != null) 'size': size,
    };
  }
}

/// Types of attachments.
enum RaptrAIAttachmentType {
  image,
  file,
  document,
  audio,
  video,
}

/// A tool call made by the assistant.
@immutable
class RaptrAIToolCall {
  const RaptrAIToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  /// Create from JSON.
  factory RaptrAIToolCall.fromJson(Map<String, dynamic> json) {
    return RaptrAIToolCall(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: (json['arguments'] as Map<String, dynamic>?) ?? const {},
    );
  }

  /// Unique identifier for this tool call.
  final String id;

  /// Name of the tool/function.
  final String name;

  /// Arguments as JSON.
  final Map<String, dynamic> arguments;

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arguments': arguments,
    };
  }

  @override
  String toString() => 'RaptrAIToolCall(name: $name, args: $arguments)';
}

/// A tool definition for function calling.
@immutable
class RaptrAIToolDefinition {
  const RaptrAIToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  /// Name of the tool/function.
  final String name;

  /// Description of what the tool does.
  final String description;

  /// JSON schema for the parameters.
  final Map<String, dynamic> parameters;

  /// Convert to JSON for API calls.
  Map<String, dynamic> toJson() => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': parameters,
    },
  };
}

/// A chunk of streaming response.
@immutable
class RaptrAIChunk {
  const RaptrAIChunk({
    this.content,
    this.toolCalls,
    this.finishReason,
    this.usage,
  });

  /// Text content in this chunk.
  final String? content;

  /// Tool calls in this chunk (may be partial).
  final List<RaptrAIToolCallDelta>? toolCalls;

  /// Reason the stream finished (if final chunk).
  final RaptrAIFinishReason? finishReason;

  /// Token usage (usually in final chunk).
  final RaptrAIUsage? usage;

  /// Whether this is the final chunk.
  bool get isComplete => finishReason != null;
}

/// Partial tool call during streaming.
@immutable
class RaptrAIToolCallDelta {
  const RaptrAIToolCallDelta({
    required this.index,
    this.id,
    this.name,
    this.argumentsDelta,
  });

  /// Index of this tool call.
  final int index;

  /// Tool call ID (in first chunk).
  final String? id;

  /// Tool name (in first chunk).
  final String? name;

  /// Partial arguments JSON string.
  final String? argumentsDelta;
}

/// Reason the generation finished.
enum RaptrAIFinishReason {
  /// Normal completion.
  stop,

  /// Hit max tokens limit.
  length,

  /// Tool call requested.
  toolCalls,

  /// Content filtered.
  contentFilter,

  /// Other/unknown reason.
  other,
}

/// Complete response from the AI.
@immutable
class RaptrAIResponse {
  const RaptrAIResponse({
    required this.message,
    required this.finishReason,
    this.usage,
    this.model,
  });

  /// The response message.
  final RaptrAIMessage message;

  /// Reason generation finished.
  final RaptrAIFinishReason finishReason;

  /// Token usage statistics.
  final RaptrAIUsage? usage;

  /// Model that generated the response.
  final String? model;
}

/// Token usage statistics.
@immutable
class RaptrAIUsage {
  const RaptrAIUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  /// Tokens in the prompt.
  final int promptTokens;

  /// Tokens in the completion.
  final int completionTokens;

  /// Total tokens used.
  final int totalTokens;

  @override
  String toString() => 'RaptrAIUsage(prompt: $promptTokens, completion: $completionTokens, total: $totalTokens)';
}

/// Configuration for chat requests.
@immutable
class RaptrAIChatConfig {
  const RaptrAIChatConfig({
    this.temperature,
    this.maxTokens,
    this.topP,
    this.frequencyPenalty,
    this.presencePenalty,
    this.stop,
    this.user,
  });

  /// Default configuration.
  static const RaptrAIChatConfig defaults = RaptrAIChatConfig();

  /// Temperature (0.0 to 2.0).
  final double? temperature;

  /// Maximum tokens to generate.
  final int? maxTokens;

  /// Top P sampling.
  final double? topP;

  /// Frequency penalty.
  final double? frequencyPenalty;

  /// Presence penalty.
  final double? presencePenalty;

  /// Stop sequences.
  final List<String>? stop;

  /// User identifier for abuse tracking.
  final String? user;

  /// Create a copy with updated fields.
  RaptrAIChatConfig copyWith({
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    List<String>? stop,
    String? user,
  }) {
    return RaptrAIChatConfig(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      stop: stop ?? this.stop,
      user: user ?? this.user,
    );
  }
}

/// Model information.
@immutable
class RaptrAIModelInfo {
  const RaptrAIModelInfo({
    required this.id,
    required this.name,
    this.description,
    this.contextWindow,
    this.maxOutputTokens,
    this.supportsVision = false,
    this.supportsTools = true,
    this.inputPricePerMillion,
    this.outputPricePerMillion,
  });

  /// Model identifier (e.g., 'gpt-4-turbo').
  final String id;

  /// Display name.
  final String name;

  /// Description.
  final String? description;

  /// Maximum context window size.
  final int? contextWindow;

  /// Maximum output tokens.
  final int? maxOutputTokens;

  /// Whether the model supports image inputs.
  final bool supportsVision;

  /// Whether the model supports tool/function calling.
  final bool supportsTools;

  /// Price per million input tokens in USD.
  final double? inputPricePerMillion;

  /// Price per million output tokens in USD.
  final double? outputPricePerMillion;

  @override
  String toString() => 'RaptrAIModelInfo(id: $id, name: $name)';
}

/// Exception thrown by AI providers.
class RaptrAIException implements Exception {
  const RaptrAIException({
    required this.message,
    this.code,
    this.statusCode,
    this.provider,
    this.originalError,
  });

  /// Error message.
  final String message;

  /// Error code (provider-specific).
  final String? code;

  /// HTTP status code.
  final int? statusCode;

  /// Provider name.
  final String? provider;

  /// Original error/exception.
  final Object? originalError;

  @override
  String toString() {
    final buffer = StringBuffer('RaptrAIException: $message');
    if (code != null) buffer.write(' (code: $code)');
    if (provider != null) buffer.write(' [provider: $provider]');
    return buffer.toString();
  }
}

/// Rate limit exception.
class RaptrAIRateLimitException extends RaptrAIException {
  const RaptrAIRateLimitException({
    required super.message,
    this.retryAfter,
    super.code,
    super.statusCode,
    super.provider,
    super.originalError,
  });

  /// Seconds to wait before retrying.
  final Duration? retryAfter;
}

/// Authentication exception.
class RaptrAIAuthException extends RaptrAIException {
  const RaptrAIAuthException({
    required super.message,
    super.code,
    super.statusCode,
    super.provider,
    super.originalError,
  });
}
