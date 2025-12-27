/// Analytics and event tracking for RaptrAI.
///
/// Provides hooks for tracking user interactions and AI usage events.
library;

import 'package:flutter/foundation.dart';

/// Analytics event types for AI chat interactions.
enum RaptrAIEventType {
  /// User started a new conversation.
  conversationStarted,

  /// User sent a message.
  messageSent,

  /// AI response received.
  responseReceived,

  /// AI response streaming started.
  streamingStarted,

  /// AI response streaming completed.
  streamingCompleted,

  /// Tool/function call requested by AI.
  toolCallRequested,

  /// Tool/function execution completed.
  toolCallCompleted,

  /// Tool/function execution failed.
  toolCallFailed,

  /// User regenerated a response.
  regenerateRequested,

  /// User edited a message.
  messageEdited,

  /// User copied a message.
  messageCopied,

  /// User switched message branch.
  branchSwitched,

  /// Conversation cleared.
  conversationCleared,

  /// Conversation deleted.
  conversationDeleted,

  /// Error occurred.
  errorOccurred,

  /// Rate limit hit.
  rateLimitHit,

  /// Attachment added.
  attachmentAdded,

  /// Voice input started.
  voiceInputStarted,

  /// Voice input completed.
  voiceInputCompleted,

  /// Text-to-speech started.
  textToSpeechStarted,

  /// Model changed.
  modelChanged,

  /// Provider changed.
  providerChanged,

  /// User stopped generation.
  generationStopped,
}

/// An analytics event.
@immutable
class RaptrAIEvent {
  const RaptrAIEvent({
    required this.type,
    required this.timestamp,
    this.conversationId,
    this.messageId,
    this.properties = const {},
  });

  /// Create an event with current timestamp.
  factory RaptrAIEvent.now({
    required RaptrAIEventType type,
    String? conversationId,
    String? messageId,
    Map<String, dynamic> properties = const {},
  }) {
    return RaptrAIEvent(
      type: type,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      messageId: messageId,
      properties: properties,
    );
  }

  /// Event type.
  final RaptrAIEventType type;

  /// When the event occurred.
  final DateTime timestamp;

  /// Conversation ID (if applicable).
  final String? conversationId;

  /// Message ID (if applicable).
  final String? messageId;

  /// Additional event properties.
  final Map<String, dynamic> properties;

  /// Event name for analytics platforms.
  String get name => type.name;

  /// Convert to JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'event': name,
      'timestamp': timestamp.toIso8601String(),
      if (conversationId != null) 'conversation_id': conversationId,
      if (messageId != null) 'message_id': messageId,
      ...properties,
    };
  }
}

/// Callback type for analytics events.
typedef RaptrAIEventCallback = void Function(RaptrAIEvent event);

/// Analytics manager for tracking events.
///
/// Example usage:
/// ```dart
/// // Configure analytics
/// RaptrAIAnalytics.configure(
///   onEvent: (event) {
///     // Send to your analytics platform
///     mixpanel.track(event.name, properties: event.toJson());
///     // Or Amplitude, PostHog, Firebase Analytics, etc.
///   },
/// );
///
/// // Events are automatically tracked when using RaptrAIChat
/// // Or manually track events:
/// RaptrAIAnalytics.track(RaptrAIEventType.conversationStarted);
/// ```
class RaptrAIAnalytics {
  RaptrAIAnalytics._();

  static RaptrAIEventCallback? _eventCallback;
  static bool _isEnabled = true;
  static final List<RaptrAIEvent> _eventHistory = [];
  static int _maxHistorySize = 100;

  /// Configure the analytics callback.
  static void configure({
    required RaptrAIEventCallback onEvent,
    bool enabled = true,
    int maxHistorySize = 100,
  }) {
    _eventCallback = onEvent;
    _isEnabled = enabled;
    _maxHistorySize = maxHistorySize;
  }

  /// Enable or disable analytics.
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Whether analytics is enabled.
  static bool get isEnabled => _isEnabled;

  /// Track an event.
  static void track(
    RaptrAIEventType type, {
    String? conversationId,
    String? messageId,
    Map<String, dynamic>? properties,
  }) {
    if (!_isEnabled) return;

    final event = RaptrAIEvent.now(
      type: type,
      conversationId: conversationId,
      messageId: messageId,
      properties: properties ?? const {},
    );

    // Store in history
    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }

    // Send to callback
    _eventCallback?.call(event);
  }

  /// Track a custom event (not a predefined type).
  static void trackCustom(
    String eventName, {
    String? conversationId,
    String? messageId,
    Map<String, dynamic>? properties,
  }) {
    if (!_isEnabled) return;

    final event = RaptrAIEvent(
      type: RaptrAIEventType.messageSent, // Placeholder type
      timestamp: DateTime.now(),
      conversationId: conversationId,
      messageId: messageId,
      properties: {
        'custom_event': eventName,
        ...?properties,
      },
    );

    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }

    _eventCallback?.call(event);
  }

  /// Get recent event history.
  static List<RaptrAIEvent> getEventHistory({int? limit}) {
    if (limit == null) return List.unmodifiable(_eventHistory);
    final start = (_eventHistory.length - limit).clamp(0, _eventHistory.length);
    return List.unmodifiable(_eventHistory.sublist(start));
  }

  /// Clear event history.
  static void clearHistory() {
    _eventHistory.clear();
  }

  /// Reset analytics configuration.
  static void reset() {
    _eventCallback = null;
    _isEnabled = true;
    _eventHistory.clear();
    _maxHistorySize = 100;
  }

  // Convenience methods for common events

  /// Track conversation started.
  static void trackConversationStarted({
    required String conversationId,
    String? model,
    String? provider,
  }) {
    track(
      RaptrAIEventType.conversationStarted,
      conversationId: conversationId,
      properties: {
        if (model != null) 'model': model,
        if (provider != null) 'provider': provider,
      },
    );
  }

  /// Track message sent.
  static void trackMessageSent({
    required String conversationId,
    required String messageId,
    int? characterCount,
    int? attachmentCount,
  }) {
    track(
      RaptrAIEventType.messageSent,
      conversationId: conversationId,
      messageId: messageId,
      properties: {
        if (characterCount != null) 'character_count': characterCount,
        if (attachmentCount != null) 'attachment_count': attachmentCount,
      },
    );
  }

  /// Track response received.
  static void trackResponseReceived({
    required String conversationId,
    required String messageId,
    int? promptTokens,
    int? completionTokens,
    int? durationMs,
    String? model,
  }) {
    track(
      RaptrAIEventType.responseReceived,
      conversationId: conversationId,
      messageId: messageId,
      properties: {
        if (promptTokens != null) 'prompt_tokens': promptTokens,
        if (completionTokens != null) 'completion_tokens': completionTokens,
        if (durationMs != null) 'duration_ms': durationMs,
        if (model != null) 'model': model,
      },
    );
  }

  /// Track tool call.
  static void trackToolCall({
    required String conversationId,
    required String toolName,
    required bool success,
    int? durationMs,
    String? error,
  }) {
    track(
      success ? RaptrAIEventType.toolCallCompleted : RaptrAIEventType.toolCallFailed,
      conversationId: conversationId,
      properties: {
        'tool_name': toolName,
        'success': success,
        if (durationMs != null) 'duration_ms': durationMs,
        if (error != null) 'error': error,
      },
    );
  }

  /// Track error.
  static void trackError({
    String? conversationId,
    required String errorType,
    String? errorMessage,
    String? provider,
  }) {
    track(
      RaptrAIEventType.errorOccurred,
      conversationId: conversationId,
      properties: {
        'error_type': errorType,
        if (errorMessage != null) 'error_message': errorMessage,
        if (provider != null) 'provider': provider,
      },
    );
  }
}

/// Mixin to add analytics tracking to a class.
mixin RaptrAIAnalyticsMixin {
  /// Track an analytics event.
  void trackEvent(
    RaptrAIEventType type, {
    String? conversationId,
    String? messageId,
    Map<String, dynamic>? properties,
  }) {
    RaptrAIAnalytics.track(
      type,
      conversationId: conversationId,
      messageId: messageId,
      properties: properties,
    );
  }
}

/// Analytics observer for debugging.
///
/// Prints all events to the debug console.
class RaptrAIDebugAnalyticsObserver {
  RaptrAIDebugAnalyticsObserver({this.prefix = '[RaptrAI Analytics]'});

  final String prefix;

  void handleEvent(RaptrAIEvent event) {
    debugPrint('$prefix ${event.name} - ${event.toJson()}');
  }

  /// Install as the analytics callback.
  void install() {
    RaptrAIAnalytics.configure(onEvent: handleEvent);
  }
}

/// Batch analytics for sending events in batches.
class RaptrAIBatchAnalytics {
  RaptrAIBatchAnalytics({
    required this.onBatch,
    this.batchSize = 10,
    this.flushInterval = const Duration(seconds: 30),
  });

  /// Callback when a batch is ready.
  final void Function(List<RaptrAIEvent> events) onBatch;

  /// Number of events per batch.
  final int batchSize;

  /// Maximum time between flushes.
  final Duration flushInterval;

  final List<RaptrAIEvent> _pendingEvents = [];
  DateTime? _lastFlush;

  /// Add an event to the batch.
  void addEvent(RaptrAIEvent event) {
    _pendingEvents.add(event);

    // Check if we should flush
    if (_pendingEvents.length >= batchSize) {
      flush();
    } else if (_lastFlush != null &&
        DateTime.now().difference(_lastFlush!) >= flushInterval) {
      flush();
    }
  }

  /// Flush pending events.
  void flush() {
    if (_pendingEvents.isEmpty) return;

    onBatch(List.from(_pendingEvents));
    _pendingEvents.clear();
    _lastFlush = DateTime.now();
  }

  /// Install as the analytics callback.
  void install() {
    RaptrAIAnalytics.configure(onEvent: addEvent);
  }

  /// Dispose and flush remaining events.
  void dispose() {
    flush();
  }
}
