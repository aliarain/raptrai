/// Hive-based local storage for conversations.
///
/// Provides encrypted, offline-first storage using Hive.
library;

import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:raptrai/src/conversation/conversation.dart';
import 'package:raptrai/src/persistence/storage_interface.dart';

/// Hive-based implementation of [RaptrAIStorage].
///
/// Provides local, encrypted storage for conversations with
/// offline-first capabilities.
///
/// Example usage:
/// ```dart
/// final storage = RaptrAIHiveStorage(
///   config: RaptrAIStorageConfig(
///     boxName: 'my_conversations',
///     encryptionKey: mySecureKey, // 32 bytes for AES-256
///   ),
/// );
///
/// await storage.initialize();
///
/// // Save and load conversations
/// await storage.saveConversation(conversation);
/// final loaded = await storage.loadConversation(conversation.id);
/// ```
class RaptrAIHiveStorage extends RaptrAIStorage with RaptrAIStorageNotifier {
  RaptrAIHiveStorage({
    RaptrAIStorageConfig? config,
  }) : _config = config ?? const RaptrAIStorageConfig();

  final RaptrAIStorageConfig _config;
  Box<String>? _box;
  bool _isInitialized = false;

  /// Whether the storage has been initialized.
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Open the box with optional encryption
      if (_config.encryptionKey != null) {
        final encryptionCipher = HiveAesCipher(_config.encryptionKey!);
        _box = await Hive.openBox<String>(
          _config.boxName,
          encryptionCipher: encryptionCipher,
        );
      } else {
        _box = await Hive.openBox<String>(_config.boxName);
      }

      _isInitialized = true;
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to initialize Hive storage',
        code: 'init_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<void> close() async {
    closeEventController();
    await _box?.close();
    _box = null;
    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized || _box == null) {
      throw const RaptrAIStorageException(
        message: 'Storage not initialized. Call initialize() first.',
        code: 'not_initialized',
      );
    }
  }

  String _getKey(String id) {
    if (_config.userId != null) {
      return '${_config.userId}_$id';
    }
    return id;
  }

  String _getConversationIdFromKey(String key) {
    if (_config.userId != null && key.startsWith('${_config.userId}_')) {
      return key.substring(_config.userId!.length + 1);
    }
    return key;
  }

  @override
  Future<void> saveConversation(RaptrAIConversation conversation) async {
    _ensureInitialized();

    try {
      final key = _getKey(conversation.id);
      final exists = _box!.containsKey(key);
      final json = jsonEncode(conversation.toJson());

      await _box!.put(key, json);

      emitEvent(RaptrAIStorageEvent(
        type: exists
            ? RaptrAIStorageEventType.updated
            : RaptrAIStorageEventType.created,
        conversationId: conversation.id,
        conversation: conversation,
      ));
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to save conversation',
        code: 'save_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<RaptrAIConversation?> loadConversation(String id) async {
    _ensureInitialized();

    try {
      final key = _getKey(id);
      final json = _box!.get(key);
      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return RaptrAIConversation.fromJson(data);
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to load conversation',
        code: 'load_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<RaptrAIConversationList> listConversations({
    int limit = 20,
    String? cursor,
    String? userId,
  }) async {
    _ensureInitialized();

    try {
      final effectiveUserId = userId ?? _config.userId;
      final allKeys = _box!.keys.cast<String>().where((key) {
        if (effectiveUserId == null) return true;
        return key.startsWith('${effectiveUserId}_');
      }).toList();

      // Load all conversations to sort by updatedAt
      final conversations = <RaptrAIConversation>[];
      for (final key in allKeys) {
        final json = _box!.get(key);
        if (json != null) {
          final data = jsonDecode(json) as Map<String, dynamic>;
          conversations.add(RaptrAIConversation.fromJson(data));
        }
      }

      // Sort by updatedAt descending (handle nullable dates)
      conversations.sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      // Apply cursor-based pagination
      int startIndex = 0;
      if (cursor != null) {
        startIndex = conversations.indexWhere((c) => c.id == cursor);
        if (startIndex == -1) {
          startIndex = 0;
        } else {
          startIndex += 1; // Start after the cursor
        }
      }

      final endIndex = (startIndex + limit).clamp(0, conversations.length);
      final page = conversations.sublist(startIndex, endIndex);

      final hasMore = endIndex < conversations.length;
      final nextCursor = hasMore ? page.last.id : null;

      return RaptrAIConversationList(
        conversations: page,
        nextCursor: nextCursor,
        hasMore: hasMore,
        totalCount: conversations.length,
      );
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to list conversations',
        code: 'list_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteConversation(String id) async {
    _ensureInitialized();

    try {
      final key = _getKey(id);
      await _box!.delete(key);

      emitEvent(RaptrAIStorageEvent(
        type: RaptrAIStorageEventType.deleted,
        conversationId: id,
      ));
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to delete conversation',
        code: 'delete_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteAllConversations({String? userId}) async {
    _ensureInitialized();

    try {
      final effectiveUserId = userId ?? _config.userId;
      final keysToDelete = _box!.keys.cast<String>().where((key) {
        if (effectiveUserId == null) return true;
        return key.startsWith('${effectiveUserId}_');
      }).toList();

      for (final key in keysToDelete) {
        await _box!.delete(key);
        emitEvent(RaptrAIStorageEvent(
          type: RaptrAIStorageEventType.deleted,
          conversationId: _getConversationIdFromKey(key),
        ));
      }
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to delete all conversations',
        code: 'delete_all_failed',
        originalError: e,
      );
    }
  }

  @override
  Stream<RaptrAIConversation> watchConversation(String id) {
    _ensureInitialized();

    return events
        .where((event) => event.conversationId == id)
        .where((event) => event.type != RaptrAIStorageEventType.deleted)
        .map((event) => event.conversation!)
        .distinct();
  }

  @override
  Stream<RaptrAIConversationList> watchConversations({
    int limit = 20,
    String? userId,
  }) {
    _ensureInitialized();

    // Emit initial list, then updates on any change
    return Stream.multi((controller) async {
      // Emit initial list
      final initial = await listConversations(limit: limit, userId: userId);
      controller.add(initial);

      // Listen for changes
      await for (final _ in events) {
        if (controller.isClosed) break;
        final updated = await listConversations(limit: limit, userId: userId);
        controller.add(updated);
      }
    });
  }

  @override
  Future<List<RaptrAIConversation>> searchConversations(
    String query, {
    int limit = 20,
    String? userId,
  }) async {
    _ensureInitialized();

    try {
      final effectiveUserId = userId ?? _config.userId;
      final normalizedQuery = query.toLowerCase();
      final results = <RaptrAIConversation>[];

      for (final key in _box!.keys.cast<String>()) {
        if (effectiveUserId != null && !key.startsWith('${effectiveUserId}_')) {
          continue;
        }

        final json = _box!.get(key);
        if (json == null) continue;

        final data = jsonDecode(json) as Map<String, dynamic>;
        final conversation = RaptrAIConversation.fromJson(data);

        // Search in title and message content
        final titleMatch =
            conversation.title?.toLowerCase().contains(normalizedQuery) ??
                false;
        final contentMatch = conversation.messages.any((msg) =>
            msg.currentBranch.content.toLowerCase().contains(normalizedQuery));

        if (titleMatch || contentMatch) {
          results.add(conversation);
        }

        if (results.length >= limit) break;
      }

      // Sort by relevance (title match first) then by updatedAt
      results.sort((a, b) {
        final aTitle =
            a.title?.toLowerCase().contains(normalizedQuery) ?? false;
        final bTitle =
            b.title?.toLowerCase().contains(normalizedQuery) ?? false;
        if (aTitle && !bTitle) return -1;
        if (!aTitle && bTitle) return 1;
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      return results;
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to search conversations',
        code: 'search_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> conversationExists(String id) async {
    _ensureInitialized();
    return _box!.containsKey(_getKey(id));
  }

  @override
  Future<int> getConversationCount({String? userId}) async {
    _ensureInitialized();

    final effectiveUserId = userId ?? _config.userId;
    if (effectiveUserId == null) {
      return _box!.length;
    }

    return _box!.keys
        .cast<String>()
        .where((key) => key.startsWith('${effectiveUserId}_'))
        .length;
  }

  @override
  Future<String> exportAllConversations({String? userId}) async {
    _ensureInitialized();

    try {
      final list = await listConversations(
        limit: 1000000, // Get all
        userId: userId,
      );

      final export = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'conversations': list.conversations.map((c) => c.toJson()).toList(),
      };

      return jsonEncode(export);
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to export conversations',
        code: 'export_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<void> importConversations(String json, {bool overwrite = false}) async {
    _ensureInitialized();

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final conversationsJson = data['conversations'] as List<dynamic>;

      for (final convJson in conversationsJson) {
        final conversation =
            RaptrAIConversation.fromJson(convJson as Map<String, dynamic>);
        final key = _getKey(conversation.id);

        if (!overwrite && _box!.containsKey(key)) {
          continue; // Skip existing conversations
        }

        await saveConversation(conversation);
      }
    } catch (e) {
      throw RaptrAIStorageException(
        message: 'Failed to import conversations',
        code: 'import_failed',
        originalError: e,
      );
    }
  }

  /// Compact the storage to reduce file size.
  ///
  /// Call this periodically to clean up deleted entries.
  Future<void> compact() async {
    _ensureInitialized();
    await _box!.compact();
  }

  /// Clear the entire storage.
  ///
  /// Warning: This deletes all data in the box.
  Future<void> clear() async {
    _ensureInitialized();
    await _box!.clear();
  }
}

/// In-memory storage implementation for testing.
///
/// Does not persist data - all data is lost when the app closes.
class RaptrAIMemoryStorage extends RaptrAIStorage with RaptrAIStorageNotifier {
  final Map<String, RaptrAIConversation> _conversations = {};
  bool _isInitialized = false;

  /// Whether the storage has been initialized.
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> close() async {
    closeEventController();
    _conversations.clear();
    _isInitialized = false;
  }

  @override
  Future<void> saveConversation(RaptrAIConversation conversation) async {
    final exists = _conversations.containsKey(conversation.id);
    _conversations[conversation.id] = conversation;

    emitEvent(RaptrAIStorageEvent(
      type: exists
          ? RaptrAIStorageEventType.updated
          : RaptrAIStorageEventType.created,
      conversationId: conversation.id,
      conversation: conversation,
    ));
  }

  @override
  Future<RaptrAIConversation?> loadConversation(String id) async {
    return _conversations[id];
  }

  @override
  Future<RaptrAIConversationList> listConversations({
    int limit = 20,
    String? cursor,
    String? userId,
  }) async {
    final all = _conversations.values.toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    int startIndex = 0;
    if (cursor != null) {
      startIndex = all.indexWhere((c) => c.id == cursor);
      if (startIndex == -1) startIndex = 0;
      else startIndex += 1;
    }

    final endIndex = (startIndex + limit).clamp(0, all.length);
    final page = all.sublist(startIndex, endIndex);
    final hasMore = endIndex < all.length;

    return RaptrAIConversationList(
      conversations: page,
      nextCursor: hasMore ? page.last.id : null,
      hasMore: hasMore,
      totalCount: all.length,
    );
  }

  @override
  Future<void> deleteConversation(String id) async {
    _conversations.remove(id);
    emitEvent(RaptrAIStorageEvent(
      type: RaptrAIStorageEventType.deleted,
      conversationId: id,
    ));
  }

  @override
  Future<void> deleteAllConversations({String? userId}) async {
    final ids = _conversations.keys.toList();
    _conversations.clear();
    for (final id in ids) {
      emitEvent(RaptrAIStorageEvent(
        type: RaptrAIStorageEventType.deleted,
        conversationId: id,
      ));
    }
  }

  @override
  Stream<RaptrAIConversation> watchConversation(String id) {
    return events
        .where((event) => event.conversationId == id)
        .where((event) => event.type != RaptrAIStorageEventType.deleted)
        .map((event) => event.conversation!);
  }

  @override
  Stream<RaptrAIConversationList> watchConversations({
    int limit = 20,
    String? userId,
  }) {
    return Stream.multi((controller) async {
      controller.add(await listConversations(limit: limit));
      await for (final _ in events) {
        if (controller.isClosed) break;
        controller.add(await listConversations(limit: limit));
      }
    });
  }

  @override
  Future<List<RaptrAIConversation>> searchConversations(
    String query, {
    int limit = 20,
    String? userId,
  }) async {
    final normalized = query.toLowerCase();
    return _conversations.values
        .where((c) =>
            (c.title?.toLowerCase().contains(normalized) ?? false) ||
            c.messages.any(
                (m) => m.currentBranch.content.toLowerCase().contains(normalized)))
        .take(limit)
        .toList();
  }

  @override
  Future<bool> conversationExists(String id) async {
    return _conversations.containsKey(id);
  }

  @override
  Future<int> getConversationCount({String? userId}) async {
    return _conversations.length;
  }

  @override
  Future<String> exportAllConversations({String? userId}) async {
    return jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'conversations': _conversations.values.map((c) => c.toJson()).toList(),
    });
  }

  @override
  Future<void> importConversations(String json, {bool overwrite = false}) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final list = data['conversations'] as List<dynamic>;
    for (final item in list) {
      final conv = RaptrAIConversation.fromJson(item as Map<String, dynamic>);
      if (overwrite || !_conversations.containsKey(conv.id)) {
        await saveConversation(conv);
      }
    }
  }
}
