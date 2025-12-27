/// High-level chat widget that combines all RaptrAI features.
///
/// Provides a complete AI chat experience with minimal configuration.
library;

import 'package:flutter/material.dart';
import 'package:raptrai/raptrai.dart';

/// A complete AI chat widget with all features integrated.
///
/// This is the simplest way to add AI chat to your app - just provide
/// a provider and you're ready to go.
///
/// Example usage:
/// ```dart
/// // Minimal setup
/// RaptrAIChat(
///   provider: RaptrAIOpenAI(apiKey: 'sk-...'),
/// )
///
/// // Full configuration
/// RaptrAIChat(
///   provider: RaptrAIOpenAI(apiKey: 'sk-...'),
///   model: 'gpt-4-turbo',
///   systemPrompt: 'You are a helpful assistant.',
///   storage: RaptrAIHiveStorage(),
///   tools: toolRegistry,
///   usageTracker: usageTracker,
///   welcomeGreeting: 'Hello!',
///   welcomeSubtitle: 'How can I help?',
///   onError: (error) => showSnackBar(error.message),
/// )
/// ```
class RaptrAIChat extends StatefulWidget {
  const RaptrAIChat({
    super.key,
    required this.provider,
    this.model,
    this.systemPrompt,
    this.storage,
    this.tools,
    this.toolRegistry,
    this.usageTracker,
    this.config,
    this.conversationId,
    this.welcomeGreeting = 'Hello!',
    this.welcomeSubtitle = 'How can I help you today?',
    this.suggestions,
    this.placeholder = 'Send a message...',
    this.onError,
    this.onConversationChanged,
    this.onMessageSent,
    this.onResponseReceived,
    this.scrollController,
    this.composerController,
    this.autofocus = false,
    this.readOnly = false,
    this.showTimestamps = false,
  });

  /// AI provider for generating responses.
  final RaptrAIProvider provider;

  /// Model to use. If not specified, uses provider's default model.
  final String? model;

  /// System prompt for the conversation.
  final String? systemPrompt;

  /// Storage for persisting conversations.
  final RaptrAIStorage? storage;

  /// Tool definitions for function calling.
  final List<RaptrAIToolDefinition>? tools;

  /// Tool registry with handlers for executing tools.
  final RaptrAIToolRegistry? toolRegistry;

  /// Usage tracker for monitoring API usage.
  final RaptrAIUsageTracker? usageTracker;

  /// Chat configuration (temperature, max tokens, etc).
  final RaptrAIChatConfig? config;

  /// ID of conversation to load. If null, creates a new conversation.
  final String? conversationId;

  /// Welcome greeting text.
  final String welcomeGreeting;

  /// Welcome subtitle text.
  final String welcomeSubtitle;

  /// Suggestion prompts to show.
  final List<RaptrAISuggestion>? suggestions;

  /// Placeholder text for the input field.
  final String placeholder;

  /// Callback when an error occurs.
  final void Function(RaptrAIException error)? onError;

  /// Callback when the conversation changes.
  final void Function(RaptrAIConversation conversation)? onConversationChanged;

  /// Callback when a user message is sent.
  final void Function(String content)? onMessageSent;

  /// Callback when an AI response is received.
  final void Function(RaptrAIConversationMessage message)? onResponseReceived;

  /// Custom scroll controller for the message list.
  final ScrollController? scrollController;

  /// Custom controller for the composer.
  final TextEditingController? composerController;

  /// Whether to autofocus the input.
  final bool autofocus;

  /// Whether the chat is read-only.
  final bool readOnly;

  /// Whether to show message timestamps.
  final bool showTimestamps;

  @override
  State<RaptrAIChat> createState() => _RaptrAIChatState();
}

class _RaptrAIChatState extends State<RaptrAIChat> {
  late RaptrAIConversationController _controller;
  late ScrollController _scrollController;
  late TextEditingController _composerController;
  RaptrAIToolExecutor? _toolExecutor;
  String? _selectedModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _composerController = widget.composerController ?? TextEditingController();
    _selectedModel = widget.model ?? widget.provider.defaultModel;
    _initializeController();
  }

  Future<void> _initializeController() async {
    // Initialize storage if provided
    if (widget.storage != null) {
      await widget.storage!.initialize();
    }

    // Load existing conversation or create new one
    RaptrAIConversation? conversation;
    if (widget.conversationId != null && widget.storage != null) {
      conversation = await widget.storage!.loadConversation(widget.conversationId!);
    }

    // Create the conversation controller
    _controller = RaptrAIConversationController(
      provider: widget.provider,
      model: _selectedModel,
      systemPrompt: widget.systemPrompt,
      conversation: conversation,
      tools: widget.tools,
      config: widget.config,
      onError: _handleError,
      onUsageUpdate: _handleUsageUpdate,
    );

    // Create tool executor if registry provided
    if (widget.toolRegistry != null) {
      _toolExecutor = RaptrAIToolExecutor(
        registry: widget.toolRegistry!,
        controller: _controller,
        onToolComplete: (toolCall, result) {
          RaptrAIAnalytics.trackToolCall(
            conversationId: _controller.conversation.id,
            toolName: toolCall.name,
            success: result.success,
          );
        },
        onToolError: (toolCall, error) {
          RaptrAIAnalytics.trackToolCall(
            conversationId: _controller.conversation.id,
            toolName: toolCall.name,
            success: false,
            error: error.toString(),
          );
        },
      );
    }

    // Listen to conversation changes
    _controller.addListener(_onControllerChanged);

    // Track conversation start
    RaptrAIAnalytics.trackConversationStarted(
      conversationId: _controller.conversation.id,
      model: _selectedModel,
      provider: widget.provider.name,
    );

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});

    // Save conversation to storage
    if (widget.storage != null) {
      widget.storage!.saveConversation(_controller.conversation);
    }

    // Notify parent
    widget.onConversationChanged?.call(_controller.conversation);
  }

  void _handleError(RaptrAIException error) {
    widget.onError?.call(error);
    RaptrAIAnalytics.trackError(
      conversationId: _controller.conversation.id,
      errorType: error.code ?? 'unknown',
      errorMessage: error.message,
      provider: error.provider,
    );
  }

  void _handleUsageUpdate(RaptrAIUsage usage) {
    widget.usageTracker?.trackUsage(usage, model: _selectedModel);
  }

  Future<void> _handleSend(String content, List<RaptrAIAttachment> attachments) async {
    if (content.trim().isEmpty && attachments.isEmpty) {
      return;
    }

    // Check rate limits
    if (widget.usageTracker != null && !widget.usageTracker!.canMakeRequest()) {
      RaptrAIAnalytics.track(
        RaptrAIEventType.rateLimitHit,
        conversationId: _controller.conversation.id,
      );
      widget.onError?.call(const RaptrAIException(
        message: 'Rate limit exceeded. Please wait before sending another message.',
        code: 'rate_limit',
      ));
      return;
    }

    // Track message sent
    widget.onMessageSent?.call(content);
    RaptrAIAnalytics.trackMessageSent(
      conversationId: _controller.conversation.id,
      messageId: 'pending',
      characterCount: content.length,
      attachmentCount: attachments.length,
    );

    // Clear input
    _composerController.clear();

    // Send the message
    await _controller.send(content, attachments: attachments);

    // Process tool calls if needed
    if (_toolExecutor != null && _controller.messages.isNotEmpty) {
      final lastMessage = _controller.messages.last;
      final toolCalls = lastMessage.currentBranch.toolCalls;
      if (toolCalls != null && toolCalls.isNotEmpty) {
        await _toolExecutor!.processToolCalls(toolCalls);
      }
    }

    // Track response
    if (_controller.messages.isNotEmpty) {
      final lastMessage = _controller.messages.last;
      if (lastMessage.role == RaptrAIRole.assistant) {
        widget.onResponseReceived?.call(lastMessage);
      }
    }

    // Scroll to bottom
    _scrollToBottom();
  }

  Future<void> _handleRegenerate(String messageId) async {
    RaptrAIAnalytics.track(
      RaptrAIEventType.regenerateRequested,
      conversationId: _controller.conversation.id,
      messageId: messageId,
    );
    await _controller.regenerate(messageId);
    _scrollToBottom();
  }

  void _handleStop() {
    RaptrAIAnalytics.track(
      RaptrAIEventType.generationStopped,
      conversationId: _controller.conversation.id,
    );
    _controller.stop();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    if (widget.composerController == null) {
      _composerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Messages or welcome screen
        Expanded(
          child: _controller.messages.isEmpty
              ? _buildWelcomeScreen()
              : _buildMessageList(),
        ),

        // Composer
        if (!widget.readOnly) _buildComposer(),
      ],
    );
  }

  Widget _buildWelcomeScreen() {
    return RaptrAIThreadWelcome(
      greeting: widget.welcomeGreeting,
      subtitle: widget.welcomeSubtitle,
      suggestions: widget.suggestions ?? const [],
      onSuggestionTap: (suggestion) {
        _composerController.text = suggestion.title;
        if (suggestion.subtitle != null) {
          _composerController.text += ' ${suggestion.subtitle}';
        }
      },
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _controller.messages.length + (_controller.isGenerating ? 1 : 0),
      itemBuilder: (context, index) {
        // Show streaming message at the end
        if (index == _controller.messages.length && _controller.isGenerating) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RaptrAIAssistantMessage(
              content: _controller.streamingContent,
              isStreaming: true,
            ),
          );
        }

        final message = _controller.messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMessage(message),
        );
      },
    );
  }

  Widget _buildMessage(RaptrAIConversationMessage message) {
    final branch = message.currentBranch;

    if (message.role == RaptrAIRole.user) {
      return RaptrAIUserMessage(content: branch.content);
    } else {
      return RaptrAIAssistantMessage(
        content: branch.content,
        onRegenerate: widget.readOnly ? null : () => _handleRegenerate(message.id),
        onCopy: () {
          RaptrAIAnalytics.track(
            RaptrAIEventType.messageCopied,
            conversationId: _controller.conversation.id,
            messageId: message.id,
          );
        },
      );
    }
  }

  Widget _buildComposer() {
    return RaptrAIComposer(
      controller: _composerController,
      placeholder: widget.placeholder,
      isGenerating: _controller.isGenerating,
      autofocus: widget.autofocus,
      onSend: (content, attachments) {
        _handleSend(content, attachments);
      },
      onStop: _handleStop,
    );
  }
}

/// Creates a complete chat experience with sidebar.
///
/// Includes a thread list sidebar and main chat area.
///
/// Example usage:
/// ```dart
/// RaptrAIChatWithSidebar(
///   provider: RaptrAIOpenAI(apiKey: 'sk-...'),
///   storage: RaptrAIHiveStorage(),
/// )
/// ```
class RaptrAIChatWithSidebar extends StatefulWidget {
  const RaptrAIChatWithSidebar({
    super.key,
    required this.provider,
    this.storage,
    this.model,
    this.systemPrompt,
    this.tools,
    this.toolRegistry,
    this.usageTracker,
    this.sidebarWidth = 280,
    this.onError,
  });

  /// AI provider.
  final RaptrAIProvider provider;

  /// Storage for conversations.
  final RaptrAIStorage? storage;

  /// Model to use.
  final String? model;

  /// System prompt.
  final String? systemPrompt;

  /// Tool definitions.
  final List<RaptrAIToolDefinition>? tools;

  /// Tool registry.
  final RaptrAIToolRegistry? toolRegistry;

  /// Usage tracker.
  final RaptrAIUsageTracker? usageTracker;

  /// Width of the sidebar.
  final double sidebarWidth;

  /// Error callback.
  final void Function(RaptrAIException error)? onError;

  @override
  State<RaptrAIChatWithSidebar> createState() => _RaptrAIChatWithSidebarState();
}

class _RaptrAIChatWithSidebarState extends State<RaptrAIChatWithSidebar> {
  String? _selectedConversationId;
  List<RaptrAIConversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (widget.storage == null) {
      setState(() => _isLoading = false);
      return;
    }

    await widget.storage!.initialize();
    final list = await widget.storage!.listConversations();

    if (mounted) {
      setState(() {
        _conversations = list.conversations;
        _isLoading = false;
      });
    }
  }

  void _handleNewThread() {
    setState(() {
      _selectedConversationId = null;
    });
    RaptrAIAnalytics.track(RaptrAIEventType.conversationStarted);
  }

  void _handleSelectThread(RaptrAIThreadData thread) {
    setState(() {
      _selectedConversationId = thread.id;
    });
  }

  Future<void> _handleDeleteThread(RaptrAIThreadData thread) async {
    if (widget.storage != null) {
      await widget.storage!.deleteConversation(thread.id);
      await _loadConversations();
      if (_selectedConversationId == thread.id) {
        setState(() => _selectedConversationId = null);
      }
    }
    RaptrAIAnalytics.track(
      RaptrAIEventType.conversationDeleted,
      conversationId: thread.id,
    );
  }

  void _handleConversationChanged(RaptrAIConversation conversation) {
    // Refresh the conversation list
    _loadConversations();
    // Select the new/updated conversation
    if (_selectedConversationId == null) {
      setState(() => _selectedConversationId = conversation.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: widget.sidebarWidth,
          child: RaptrAIThreadList(
            threads: _conversations.map((c) {
              return RaptrAIThreadData(
                id: c.id,
                title: c.title ?? 'New conversation',
                preview: c.messages.isNotEmpty
                    ? c.messages.last.currentBranch.content
                    : null,
                isActive: c.id == _selectedConversationId,
              );
            }).toList(),
            selectedThreadId: _selectedConversationId,
            onNewThread: _handleNewThread,
            onSelectThread: _handleSelectThread,
            onDeleteThread: _handleDeleteThread,
          ),
        ),

        // Divider
        const VerticalDivider(width: 1),

        // Main chat area
        Expanded(
          child: RaptrAIChat(
            key: ValueKey(_selectedConversationId),
            provider: widget.provider,
            model: widget.model,
            systemPrompt: widget.systemPrompt,
            storage: widget.storage,
            tools: widget.tools,
            toolRegistry: widget.toolRegistry,
            usageTracker: widget.usageTracker,
            conversationId: _selectedConversationId,
            onError: widget.onError,
            onConversationChanged: _handleConversationChanged,
          ),
        ),
      ],
    );
  }
}
