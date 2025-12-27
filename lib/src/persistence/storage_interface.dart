/// Abstract storage interface for conversation persistence.
///
/// Provides a unified API for storing and retrieving conversations
/// across different storage backends (Hive, Supabase, Firebase, etc).
library;

import 'package:flutter/foundation.dart';
import 'package:raptrai/src/conversation/conversation.dart';

/// Abstract interface for conversation storage.
///
/// Implementations can use different backends:
/// - [RaptrAIHiveStorage] for local encrypted storage
/// - [RaptrAISupabaseStorage] for Supabase PostgreSQL (user provides)
/// - [RaptrAIFirebaseStorage] for Firebase Firestore (user provides)
///
/// Example usage:
/// ```dart
/// final storage = RaptrAIHiveStorage();
/// await storage.initialize();
///
/// // Save a conversation
/// await storage.saveConversation(conversation);
///
/// // Load conversations
/// final conversations = await storage.listConversations();
///
/// // Watch for changes
/// storage.watchConversation(id).listen((conv) {
///   print('Conversation updated: ${conv.title}');
/// });
/// ```
abstract class RaptrAIStorage {
  /// Initialize the storage backend.
  ///
  /// Must be called before using any other methods.
  Future<void> initialize();

  /// Close the storage and release resources.
  Future<void> close();

  /// Save a conversation.
  ///
  /// Creates a new conversation if it doesn't exist,
  /// or updates an existing one.
  Future<void> saveConversation(RaptrAIConversation conversation);

  /// Load a conversation by ID.
  ///
  /// Returns null if the conversation doesn't exist.
  Future<RaptrAIConversation?> loadConversation(String id);

  /// List all conversations.
  ///
  /// Supports pagination with [limit] and [cursor].
  /// Returns conversations sorted by [updatedAt] descending.
  Future<RaptrAIConversationList> listConversations({
    int limit = 20,
    String? cursor,
    String? userId,
  });

  /// Delete a conversation by ID.
  Future<void> deleteConversation(String id);

  /// Delete all conversations.
  Future<void> deleteAllConversations({String? userId});

  /// Watch a conversation for changes (realtime updates).
  ///
  /// Emits the conversation whenever it's updated.
  /// For local storage, this emits on save.
  /// For remote storage, this uses realtime subscriptions.
  Stream<RaptrAIConversation> watchConversation(String id);

  /// Watch the conversation list for changes.
  Stream<RaptrAIConversationList> watchConversations({
    int limit = 20,
    String? userId,
  });

  /// Search conversations by title or content.
  Future<List<RaptrAIConversation>> searchConversations(
    String query, {
    int limit = 20,
    String? userId,
  });

  /// Check if a conversation exists.
  Future<bool> conversationExists(String id);

  /// Get the total count of conversations.
  Future<int> getConversationCount({String? userId});

  /// Export all conversations as JSON.
  Future<String> exportAllConversations({String? userId});

  /// Import conversations from JSON.
  Future<void> importConversations(String json, {bool overwrite = false});
}

/// Result of listing conversations with pagination support.
@immutable
class RaptrAIConversationList {
  const RaptrAIConversationList({
    required this.conversations,
    this.nextCursor,
    this.hasMore = false,
    this.totalCount,
  });

  /// The list of conversations.
  final List<RaptrAIConversation> conversations;

  /// Cursor for fetching the next page.
  final String? nextCursor;

  /// Whether there are more conversations to fetch.
  final bool hasMore;

  /// Total count of conversations (if available).
  final int? totalCount;

  /// Whether the list is empty.
  bool get isEmpty => conversations.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => conversations.isNotEmpty;

  /// Number of conversations in this page.
  int get length => conversations.length;
}

/// Storage configuration options.
@immutable
class RaptrAIStorageConfig {
  const RaptrAIStorageConfig({
    this.encryptionKey,
    this.boxName = 'raptrai_conversations',
    this.userId,
    this.enableRealtime = true,
  });

  /// Encryption key for local storage (32 bytes for AES-256).
  ///
  /// If not provided, storage will not be encrypted.
  final List<int>? encryptionKey;

  /// Name of the Hive box for local storage.
  final String boxName;

  /// User ID for multi-user support.
  ///
  /// If provided, conversations are scoped to this user.
  final String? userId;

  /// Whether to enable realtime updates.
  final bool enableRealtime;
}

/// Storage event types for change notifications.
enum RaptrAIStorageEventType {
  /// A conversation was created.
  created,

  /// A conversation was updated.
  updated,

  /// A conversation was deleted.
  deleted,
}

/// Event emitted when storage changes.
@immutable
class RaptrAIStorageEvent {
  const RaptrAIStorageEvent({
    required this.type,
    required this.conversationId,
    this.conversation,
  });

  /// Type of the event.
  final RaptrAIStorageEventType type;

  /// ID of the affected conversation.
  final String conversationId;

  /// The conversation data (null for delete events).
  final RaptrAIConversation? conversation;
}

/// Mixin for storage implementations that support change notifications.
mixin RaptrAIStorageNotifier {
  final _eventController = _StorageEventController();

  /// Stream of storage events.
  Stream<RaptrAIStorageEvent> get events => _eventController.stream;

  /// Emit a storage event.
  @protected
  void emitEvent(RaptrAIStorageEvent event) {
    _eventController.add(event);
  }

  /// Close the event controller.
  @protected
  void closeEventController() {
    _eventController.close();
  }
}

/// Internal controller for storage events.
class _StorageEventController {
  final _listeners = <void Function(RaptrAIStorageEvent)>[];
  bool _isClosed = false;

  Stream<RaptrAIStorageEvent> get stream {
    return Stream.multi((controller) {
      void listener(RaptrAIStorageEvent event) {
        if (!controller.isClosed) {
          controller.add(event);
        }
      }

      _listeners.add(listener);
      controller.onCancel = () {
        _listeners.remove(listener);
      };
    });
  }

  void add(RaptrAIStorageEvent event) {
    if (_isClosed) return;
    for (final listener in List.of(_listeners)) {
      listener(event);
    }
  }

  void close() {
    _isClosed = true;
    _listeners.clear();
  }
}

/// Exception thrown by storage operations.
class RaptrAIStorageException implements Exception {
  const RaptrAIStorageException({
    required this.message,
    this.code,
    this.originalError,
  });

  /// Error message.
  final String message;

  /// Error code.
  final String? code;

  /// Original error.
  final Object? originalError;

  @override
  String toString() {
    final buffer = StringBuffer('RaptrAIStorageException: $message');
    if (code != null) buffer.write(' (code: $code)');
    return buffer.toString();
  }
}
