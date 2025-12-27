/// Conversation state and models for RaptrAI.
///
/// Provides conversation state management, branching support,
/// and message history tracking.
library;

import 'package:flutter/foundation.dart';
import 'package:raptrai/src/providers/provider_interface.dart';

/// Represents a complete conversation with an AI assistant.
@immutable
class RaptrAIConversation {
  const RaptrAIConversation({
    required this.id,
    this.title,
    this.messages = const [],
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.systemPrompt,
    this.model,
    this.providerId,
  });

  /// Creates an empty conversation with a generated ID.
  factory RaptrAIConversation.create({
    String? title,
    String? systemPrompt,
    String? model,
    String? providerId,
  }) {
    final now = DateTime.now();
    return RaptrAIConversation(
      id: 'conv_${now.millisecondsSinceEpoch}',
      title: title,
      systemPrompt: systemPrompt,
      model: model,
      providerId: providerId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Unique identifier for this conversation.
  final String id;

  /// Optional title for the conversation.
  final String? title;

  /// Messages in chronological order.
  final List<RaptrAIConversationMessage> messages;

  /// Custom metadata for the conversation.
  final Map<String, dynamic> metadata;

  /// When the conversation was created.
  final DateTime? createdAt;

  /// When the conversation was last updated.
  final DateTime? updatedAt;

  /// System prompt for this conversation.
  final String? systemPrompt;

  /// Default model for this conversation.
  final String? model;

  /// Provider ID for this conversation.
  final String? providerId;

  /// Creates a copy with updated fields.
  RaptrAIConversation copyWith({
    String? id,
    String? title,
    List<RaptrAIConversationMessage>? messages,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? systemPrompt,
    String? model,
    String? providerId,
  }) {
    return RaptrAIConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      model: model ?? this.model,
      providerId: providerId ?? this.providerId,
    );
  }

  /// Adds a message and returns an updated conversation.
  RaptrAIConversation addMessage(RaptrAIConversationMessage message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// Returns the messages as RaptrAIMessage list for API calls.
  List<RaptrAIMessage> toApiMessages() {
    final apiMessages = <RaptrAIMessage>[];

    // Add system prompt first if present
    if (systemPrompt != null && systemPrompt!.isNotEmpty) {
      apiMessages.add(RaptrAIMessage.system(systemPrompt!));
    }

    // Add conversation messages (only the current branch for each)
    for (final message in messages) {
      apiMessages.add(message.currentBranch.toApiMessage());
    }

    return apiMessages;
  }

  /// Converts to JSON for serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'systemPrompt': systemPrompt,
      'model': model,
      'providerId': providerId,
    };
  }

  /// Creates from JSON.
  factory RaptrAIConversation.fromJson(Map<String, dynamic> json) {
    return RaptrAIConversation(
      id: json['id'] as String,
      title: json['title'] as String?,
      messages: (json['messages'] as List<dynamic>?)
              ?.map(
                (m) =>
                    RaptrAIConversationMessage.fromJson(m as Map<String, dynamic>),
              )
              .toList() ??
          [],
      metadata:
          (json['metadata'] as Map<String, dynamic>?) ?? const {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      systemPrompt: json['systemPrompt'] as String?,
      model: json['model'] as String?,
      providerId: json['providerId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaptrAIConversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A message in a conversation with branching support.
///
/// Each message can have multiple branches (versions) from edits/regeneration.
@immutable
class RaptrAIConversationMessage {
  const RaptrAIConversationMessage({
    required this.id,
    required this.branches,
    this.currentBranchIndex = 0,
  });

  /// Creates a new message with a single branch.
  factory RaptrAIConversationMessage.create({
    required RaptrAIMessageBranch branch,
  }) {
    return RaptrAIConversationMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      branches: [branch],
    );
  }

  /// Creates a user message.
  factory RaptrAIConversationMessage.user(
    String content, {
    List<RaptrAIAttachment>? attachments,
  }) {
    return RaptrAIConversationMessage.create(
      branch: RaptrAIMessageBranch(
        id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
        role: RaptrAIRole.user,
        content: content,
        attachments: attachments,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Creates an assistant message.
  factory RaptrAIConversationMessage.assistant(
    String content, {
    List<RaptrAIToolCall>? toolCalls,
  }) {
    return RaptrAIConversationMessage.create(
      branch: RaptrAIMessageBranch(
        id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
        role: RaptrAIRole.assistant,
        content: content,
        toolCalls: toolCalls,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Unique identifier for this message.
  final String id;

  /// All branches (versions) of this message.
  final List<RaptrAIMessageBranch> branches;

  /// Index of the currently active branch.
  final int currentBranchIndex;

  /// Gets the current branch.
  RaptrAIMessageBranch get currentBranch => branches[currentBranchIndex];

  /// Role of the message (from current branch).
  RaptrAIRole get role => currentBranch.role;

  /// Content of the message (from current branch).
  String get content => currentBranch.content;

  /// Total number of branches.
  int get branchCount => branches.length;

  /// Whether this message has multiple branches.
  bool get hasBranches => branches.length > 1;

  /// Creates a copy with updated fields.
  RaptrAIConversationMessage copyWith({
    String? id,
    List<RaptrAIMessageBranch>? branches,
    int? currentBranchIndex,
  }) {
    return RaptrAIConversationMessage(
      id: id ?? this.id,
      branches: branches ?? this.branches,
      currentBranchIndex: currentBranchIndex ?? this.currentBranchIndex,
    );
  }

  /// Adds a new branch and returns an updated message.
  RaptrAIConversationMessage addBranch(
    RaptrAIMessageBranch branch, {
    bool switchToBranch = true,
  }) {
    final newBranches = [...branches, branch];
    return copyWith(
      branches: newBranches,
      currentBranchIndex: switchToBranch ? newBranches.length - 1 : currentBranchIndex,
    );
  }

  /// Switches to a different branch.
  RaptrAIConversationMessage switchBranch(int index) {
    if (index < 0 || index >= branches.length) {
      return this;
    }
    return copyWith(currentBranchIndex: index);
  }

  /// Converts to JSON for serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branches': branches.map((b) => b.toJson()).toList(),
      'currentBranchIndex': currentBranchIndex,
    };
  }

  /// Creates from JSON.
  factory RaptrAIConversationMessage.fromJson(Map<String, dynamic> json) {
    return RaptrAIConversationMessage(
      id: json['id'] as String,
      branches: (json['branches'] as List<dynamic>)
          .map((b) => RaptrAIMessageBranch.fromJson(b as Map<String, dynamic>))
          .toList(),
      currentBranchIndex: json['currentBranchIndex'] as int? ?? 0,
    );
  }
}

/// A single branch (version) of a message.
@immutable
class RaptrAIMessageBranch {
  const RaptrAIMessageBranch({
    required this.id,
    required this.role,
    required this.content,
    this.attachments,
    this.toolCalls,
    this.toolCallId,
    this.name,
    this.createdAt,
    this.metadata = const {},
  });

  /// Unique identifier for this branch.
  final String id;

  /// Role of the message sender.
  final RaptrAIRole role;

  /// Text content of the message.
  final String content;

  /// Attachments (images, files).
  final List<RaptrAIAttachment>? attachments;

  /// Tool calls made by the assistant.
  final List<RaptrAIToolCall>? toolCalls;

  /// Tool call ID (for tool result messages).
  final String? toolCallId;

  /// Name (for tool results).
  final String? name;

  /// When this branch was created.
  final DateTime? createdAt;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  /// Converts to RaptrAIMessage for API calls.
  RaptrAIMessage toApiMessage() {
    return RaptrAIMessage(
      role: role,
      content: content,
      attachments: attachments,
      toolCalls: toolCalls,
      toolCallId: toolCallId,
      name: name,
    );
  }

  /// Converts to JSON for serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'toolCalls': toolCalls?.map((t) => t.toJson()).toList(),
      'toolCallId': toolCallId,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Creates from JSON.
  factory RaptrAIMessageBranch.fromJson(Map<String, dynamic> json) {
    return RaptrAIMessageBranch(
      id: json['id'] as String,
      role: RaptrAIRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => RaptrAIRole.user,
      ),
      content: json['content'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => RaptrAIAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      toolCalls: (json['toolCalls'] as List<dynamic>?)
          ?.map((t) => RaptrAIToolCall.fromJson(t as Map<String, dynamic>))
          .toList(),
      toolCallId: json['toolCallId'] as String?,
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      metadata:
          (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
}

/// State of a conversation for UI updates.
enum RaptrAIConversationState {
  /// Idle, ready for input.
  idle,

  /// Waiting for AI response.
  generating,

  /// AI is streaming response.
  streaming,

  /// An error occurred.
  error,
}

/// Snapshot of conversation state for notifying listeners.
@immutable
class RaptrAIConversationSnapshot {
  const RaptrAIConversationSnapshot({
    required this.conversation,
    required this.state,
    this.streamingContent,
    this.streamingToolCalls,
    this.error,
    this.usage,
  });

  /// The current conversation.
  final RaptrAIConversation conversation;

  /// Current state.
  final RaptrAIConversationState state;

  /// Content being streamed (during streaming state).
  final String? streamingContent;

  /// Tool calls being streamed.
  final List<RaptrAIToolCallDelta>? streamingToolCalls;

  /// Error if state is error.
  final RaptrAIException? error;

  /// Token usage from the last response.
  final RaptrAIUsage? usage;

  /// Creates a copy with updated fields.
  RaptrAIConversationSnapshot copyWith({
    RaptrAIConversation? conversation,
    RaptrAIConversationState? state,
    String? streamingContent,
    List<RaptrAIToolCallDelta>? streamingToolCalls,
    RaptrAIException? error,
    RaptrAIUsage? usage,
  }) {
    return RaptrAIConversationSnapshot(
      conversation: conversation ?? this.conversation,
      state: state ?? this.state,
      streamingContent: streamingContent ?? this.streamingContent,
      streamingToolCalls: streamingToolCalls ?? this.streamingToolCalls,
      error: error ?? this.error,
      usage: usage ?? this.usage,
    );
  }

  /// Whether the conversation is currently generating/streaming.
  bool get isGenerating =>
      state == RaptrAIConversationState.generating ||
      state == RaptrAIConversationState.streaming;
}
