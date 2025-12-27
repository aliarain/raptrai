/// Conversation controller for managing AI chat interactions.
///
/// Provides high-level API for sending messages, handling streaming,
/// branching, and conversation state management.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:raptrai/src/conversation/conversation.dart';
import 'package:raptrai/src/providers/provider_interface.dart';

/// Controller for managing a conversation with an AI provider.
///
/// Example usage:
/// ```dart
/// final controller = RaptrAIConversationController(
///   provider: RaptrAIOpenAI(apiKey: 'sk-...'),
///   model: 'gpt-4-turbo',
///   systemPrompt: 'You are a helpful assistant.',
/// );
///
/// // Listen to state changes
/// controller.addListener(() {
///   print('State: ${controller.state}');
///   print('Messages: ${controller.messages.length}');
/// });
///
/// // Send a message
/// await controller.send('Hello!');
///
/// // Edit a message (creates branch)
/// await controller.edit(messageId, 'Hello there!');
///
/// // Regenerate last assistant response
/// await controller.regenerate();
/// ```
class RaptrAIConversationController extends ChangeNotifier {
  RaptrAIConversationController({
    required RaptrAIProvider provider,
    String? model,
    String? systemPrompt,
    RaptrAIConversation? conversation,
    List<RaptrAIToolDefinition>? tools,
    RaptrAIChatConfig? config,
    this.onError,
    this.onUsageUpdate,
  })  : _provider = provider,
        _model = model ?? provider.defaultModel,
        _systemPrompt = systemPrompt,
        _tools = tools,
        _config = config ?? RaptrAIChatConfig.defaults,
        _conversation = conversation ??
            RaptrAIConversation.create(
              systemPrompt: systemPrompt,
              model: model ?? provider.defaultModel,
              providerId: provider.id,
            );

  final RaptrAIProvider _provider;
  final String _model;
  final String? _systemPrompt;
  final List<RaptrAIToolDefinition>? _tools;
  final RaptrAIChatConfig _config;

  RaptrAIConversation _conversation;
  RaptrAIConversationState _state = RaptrAIConversationState.idle;
  String _streamingContent = '';
  List<RaptrAIToolCallDelta> _streamingToolCalls = [];
  RaptrAIException? _error;
  RaptrAIUsage? _lastUsage;
  StreamSubscription<RaptrAIChunk>? _streamSubscription;

  /// Callback for errors.
  final void Function(RaptrAIException error)? onError;

  /// Callback for usage updates.
  final void Function(RaptrAIUsage usage)? onUsageUpdate;

  /// Current conversation.
  RaptrAIConversation get conversation => _conversation;

  /// Messages in the conversation.
  List<RaptrAIConversationMessage> get messages => _conversation.messages;

  /// Current state.
  RaptrAIConversationState get state => _state;

  /// Content being streamed.
  String get streamingContent => _streamingContent;

  /// Tool calls being streamed.
  List<RaptrAIToolCallDelta> get streamingToolCalls => _streamingToolCalls;

  /// Last error.
  RaptrAIException? get error => _error;

  /// Last usage statistics.
  RaptrAIUsage? get lastUsage => _lastUsage;

  /// Whether currently generating.
  bool get isGenerating =>
      _state == RaptrAIConversationState.generating ||
      _state == RaptrAIConversationState.streaming;

  /// Current snapshot of the conversation state.
  RaptrAIConversationSnapshot get snapshot => RaptrAIConversationSnapshot(
        conversation: _conversation,
        state: _state,
        streamingContent: _streamingContent,
        streamingToolCalls: _streamingToolCalls,
        error: _error,
        usage: _lastUsage,
      );

  /// Send a user message and get AI response.
  Future<void> send(
    String content, {
    List<RaptrAIAttachment>? attachments,
  }) async {
    if (content.trim().isEmpty && (attachments == null || attachments.isEmpty)) {
      return;
    }

    // Add user message
    final userMessage = RaptrAIConversationMessage.user(
      content,
      attachments: attachments,
    );
    _conversation = _conversation.addMessage(userMessage);
    _setGeneratingState();

    try {
      await _generateResponse();
    } catch (e) {
      _handleError(e);
    }
  }

  /// Edit a message and regenerate from that point.
  Future<void> edit(String messageId, String newContent) async {
    final index = _conversation.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final message = _conversation.messages[index];
    if (message.role != RaptrAIRole.user) return;

    // Create a new branch with the edited content
    final newBranch = RaptrAIMessageBranch(
      id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
      role: RaptrAIRole.user,
      content: newContent,
      attachments: message.currentBranch.attachments,
      createdAt: DateTime.now(),
    );

    final updatedMessage = message.addBranch(newBranch);

    // Update messages up to and including the edited message
    final updatedMessages = [
      ..._conversation.messages.sublist(0, index),
      updatedMessage,
    ];

    _conversation = _conversation.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    _setGeneratingState();

    try {
      await _generateResponse();
    } catch (e) {
      _handleError(e);
    }
  }

  /// Regenerate the last assistant response.
  Future<void> regenerate([String? messageId]) async {
    // Find the message to regenerate
    int targetIndex;
    if (messageId != null) {
      targetIndex = _conversation.messages.indexWhere((m) => m.id == messageId);
      if (targetIndex == -1) return;
    } else {
      // Find the last assistant message
      targetIndex = _conversation.messages.lastIndexWhere(
        (m) => m.role == RaptrAIRole.assistant,
      );
      if (targetIndex == -1) return;
    }

    final message = _conversation.messages[targetIndex];
    if (message.role != RaptrAIRole.assistant) return;

    // Remove messages from the target onwards for regeneration
    final messagesBeforeTarget = _conversation.messages.sublist(0, targetIndex);
    _conversation = _conversation.copyWith(
      messages: messagesBeforeTarget,
      updatedAt: DateTime.now(),
    );

    _setGeneratingState();

    try {
      await _generateResponse(existingMessage: message);
    } catch (e) {
      _handleError(e);
    }
  }

  /// Switch to a different branch of a message.
  void switchBranch(String messageId, int branchIndex) {
    final index = _conversation.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final message = _conversation.messages[index];
    final updatedMessage = message.switchBranch(branchIndex);

    final updatedMessages = [..._conversation.messages];
    updatedMessages[index] = updatedMessage;

    _conversation = _conversation.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Stop current generation.
  void stop() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _provider.cancel();

    if (_streamingContent.isNotEmpty) {
      // Save the partial response as a message
      _addAssistantMessage(_streamingContent);
    }

    _state = RaptrAIConversationState.idle;
    _streamingContent = '';
    _streamingToolCalls = [];
    notifyListeners();
  }

  /// Clear the conversation.
  void clear() {
    stop();
    _conversation = RaptrAIConversation.create(
      systemPrompt: _systemPrompt,
      model: _model,
      providerId: _provider.id,
    );
    _error = null;
    _lastUsage = null;
    notifyListeners();
  }

  /// Load an existing conversation.
  void loadConversation(RaptrAIConversation conversation) {
    stop();
    _conversation = conversation;
    _error = null;
    notifyListeners();
  }

  void _setGeneratingState() {
    _state = RaptrAIConversationState.generating;
    _streamingContent = '';
    _streamingToolCalls = [];
    _error = null;
    notifyListeners();
  }

  Future<void> _generateResponse({
    RaptrAIConversationMessage? existingMessage,
  }) async {
    final apiMessages = _conversation.toApiMessages();

    final stream = _provider.chat(
      messages: apiMessages,
      model: _model,
      tools: _tools,
      config: _config,
    );

    _state = RaptrAIConversationState.streaming;
    notifyListeners();

    final completer = Completer<void>();
    final toolCallBuffers = <int, _ToolCallBuffer>{};

    _streamSubscription = stream.listen(
      (chunk) {
        // Handle text content
        if (chunk.content != null) {
          _streamingContent += chunk.content!;
          notifyListeners();
        }

        // Handle tool calls
        if (chunk.toolCalls != null) {
          for (final toolDelta in chunk.toolCalls!) {
            toolCallBuffers.putIfAbsent(
              toolDelta.index,
              _ToolCallBuffer.new,
            );
            final buffer = toolCallBuffers[toolDelta.index]!;

            if (toolDelta.id != null) buffer.id = toolDelta.id;
            if (toolDelta.name != null) buffer.name = toolDelta.name;
            if (toolDelta.argumentsDelta != null) {
              buffer.arguments += toolDelta.argumentsDelta!;
            }
          }

          _streamingToolCalls = toolCallBuffers.entries
              .map(
                (e) => RaptrAIToolCallDelta(
                  index: e.key,
                  id: e.value.id,
                  name: e.value.name,
                  argumentsDelta: e.value.arguments,
                ),
              )
              .toList();
          notifyListeners();
        }

        // Handle usage
        if (chunk.usage != null) {
          _lastUsage = chunk.usage;
          onUsageUpdate?.call(chunk.usage!);
        }

        // Handle completion
        if (chunk.isComplete) {
          _addAssistantResponse(
            existingMessage: existingMessage,
            toolCallBuffers: toolCallBuffers,
          );
        }
      },
      onError: (Object error) {
        _handleError(error);
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        _state = RaptrAIConversationState.idle;
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  void _addAssistantResponse({
    RaptrAIConversationMessage? existingMessage,
    Map<int, _ToolCallBuffer> toolCallBuffers = const {},
  }) {
    // Build tool calls from buffers
    List<RaptrAIToolCall>? toolCalls;
    if (toolCallBuffers.isNotEmpty) {
      toolCalls = toolCallBuffers.entries
          .map((e) => e.value.toToolCall())
          .whereType<RaptrAIToolCall>()
          .toList();
      if (toolCalls.isEmpty) toolCalls = null;
    }

    if (existingMessage != null) {
      // Add as a new branch to existing message
      final newBranch = RaptrAIMessageBranch(
        id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
        role: RaptrAIRole.assistant,
        content: _streamingContent,
        toolCalls: toolCalls,
        createdAt: DateTime.now(),
      );
      final updatedMessage = existingMessage.addBranch(newBranch);
      _conversation = _conversation.addMessage(updatedMessage);
    } else {
      // Add as new message
      _addAssistantMessage(_streamingContent, toolCalls: toolCalls);
    }

    _streamingContent = '';
    _streamingToolCalls = [];
  }

  void _addAssistantMessage(String content, {List<RaptrAIToolCall>? toolCalls}) {
    final assistantMessage = RaptrAIConversationMessage.assistant(
      content,
      toolCalls: toolCalls,
    );
    _conversation = _conversation.addMessage(assistantMessage);
  }

  void _handleError(Object error) {
    final exception = error is RaptrAIException
        ? error
        : RaptrAIException(
            message: error.toString(),
            provider: _provider.name,
            originalError: error,
          );

    _error = exception;
    _state = RaptrAIConversationState.error;
    onError?.call(exception);
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Buffer for accumulating streamed tool call data.
class _ToolCallBuffer {
  String? id;
  String? name;
  String arguments = '';

  RaptrAIToolCall? toToolCall() {
    if (id == null || name == null) return null;
    try {
      // Parse arguments JSON
      final argsJson = arguments.isNotEmpty ? arguments : '{}';
      final dynamic decoded = jsonDecode(argsJson);
      final args = (decoded as Map<String, dynamic>?) ?? const <String, dynamic>{};
      return RaptrAIToolCall(
        id: id!,
        name: name!,
        arguments: args,
      );
    } catch (_) {
      return RaptrAIToolCall(
        id: id!,
        name: name!,
        arguments: const {},
      );
    }
  }
}
