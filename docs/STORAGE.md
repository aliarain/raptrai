# Custom Storage

Persist conversations anywhere by implementing `RaptrAIStorage`.

## Quick Start

```dart
class MyCloudStorage extends RaptrAIStorage {
  MyCloudStorage({required this.userId});

  final String userId;

  @override
  Future<void> initialize() async {
    // Initialize your storage connection
  }

  @override
  Future<void> saveConversation(RaptrAIConversation conversation) async {
    await cloudDb.upsert('conversations', {
      'id': conversation.id,
      'user_id': userId,
      'data': conversation.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<RaptrAIConversation?> loadConversation(String id) async {
    final row = await cloudDb.get('conversations', id);
    if (row == null) return null;
    return RaptrAIConversation.fromJson(row['data']);
  }

  @override
  Future<RaptrAIConversationList> listConversations({
    int limit = 20,
    String? cursor,
  }) async {
    final rows = await cloudDb.query(
      'conversations',
      where: {'user_id': userId},
      orderBy: 'updated_at DESC',
      limit: limit,
      after: cursor,
    );

    return RaptrAIConversationList(
      conversations: rows.map((r) => RaptrAIConversation.fromJson(r['data'])).toList(),
      cursor: rows.isNotEmpty ? rows.last['id'] : null,
      hasMore: rows.length == limit,
    );
  }

  @override
  Future<void> deleteConversation(String id) async {
    await cloudDb.delete('conversations', id);
  }

  @override
  Future<void> close() async {
    await cloudDb.close();
  }
}
```

## Use Your Storage

```dart
RaptrAIChat(
  provider: openai,
  storage: MyCloudStorage(userId: currentUser.id),
)
```

## Required Methods

| Method | Purpose |
|--------|---------|
| `initialize()` | Setup storage connection |
| `saveConversation()` | Persist a conversation |
| `loadConversation()` | Load by ID |
| `listConversations()` | Paginated list |
| `deleteConversation()` | Remove conversation |
| `close()` | Cleanup resources |

## Optional Methods

```dart
// Real-time updates
@override
Stream<RaptrAIConversation> watchConversation(String id) {
  return cloudDb.watch('conversations', id)
    .map((row) => RaptrAIConversation.fromJson(row['data']));
}

// Search
@override
Future<List<RaptrAIConversation>> search(String query) async {
  final rows = await cloudDb.fullTextSearch('conversations', query);
  return rows.map((r) => RaptrAIConversation.fromJson(r['data'])).toList();
}
```

## Built-in Storage Options

### Memory (Testing)

```dart
// No persistence - great for testing
RaptrAIChat(storage: RaptrAIMemoryStorage())
```

### Hive (Local)

```dart
// Local encrypted storage
RaptrAIChat(
  storage: RaptrAIHiveStorage(
    config: RaptrAIHiveConfig(
      boxName: 'my_app_chats',
      encryptionKey: myEncryptionKey, // Optional
      userId: currentUser.id,         // Multi-user support
    ),
  ),
)
```

## Example: Supabase Storage

```dart
class SupabaseStorage extends RaptrAIStorage {
  SupabaseStorage({required this.supabase, required this.userId});

  final SupabaseClient supabase;
  final String userId;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> saveConversation(RaptrAIConversation conversation) async {
    await supabase.from('conversations').upsert({
      'id': conversation.id,
      'user_id': userId,
      'title': conversation.title,
      'data': conversation.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<RaptrAIConversation?> loadConversation(String id) async {
    final response = await supabase
        .from('conversations')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .single();

    return RaptrAIConversation.fromJson(response['data']);
  }

  @override
  Future<RaptrAIConversationList> listConversations({
    int limit = 20,
    String? cursor,
  }) async {
    var query = supabase
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(limit);

    if (cursor != null) {
      query = query.lt('updated_at', cursor);
    }

    final response = await query;

    return RaptrAIConversationList(
      conversations: response.map((r) => RaptrAIConversation.fromJson(r['data'])).toList(),
      cursor: response.isNotEmpty ? response.last['updated_at'] : null,
      hasMore: response.length == limit,
    );
  }

  @override
  Future<void> deleteConversation(String id) async {
    await supabase.from('conversations').delete().eq('id', id);
  }

  @override
  Stream<RaptrAIConversation> watchConversation(String id) {
    return supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) => RaptrAIConversation.fromJson(rows.first['data']));
  }

  @override
  Future<void> close() async {}
}
```

## Example: Firebase Storage

```dart
class FirebaseStorage extends RaptrAIStorage {
  FirebaseStorage({required this.userId});

  final String userId;
  late final CollectionReference _collection;

  @override
  Future<void> initialize() async {
    _collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('conversations');
  }

  @override
  Future<void> saveConversation(RaptrAIConversation conversation) async {
    await _collection.doc(conversation.id).set(conversation.toJson());
  }

  @override
  Future<RaptrAIConversation?> loadConversation(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return RaptrAIConversation.fromJson(doc.data()!);
  }

  // ... implement other methods
}
```

## Syncing Local + Cloud

Combine storages for offline-first with sync:

```dart
class SyncedStorage extends RaptrAIStorage {
  SyncedStorage({
    required this.local,
    required this.cloud,
  });

  final RaptrAIStorage local;
  final RaptrAIStorage cloud;

  @override
  Future<void> saveConversation(RaptrAIConversation conversation) async {
    // Save locally first (fast)
    await local.saveConversation(conversation);
    // Then sync to cloud (can be async/background)
    cloud.saveConversation(conversation).ignore();
  }

  @override
  Future<RaptrAIConversation?> loadConversation(String id) async {
    // Try local first
    final localConv = await local.loadConversation(id);
    if (localConv != null) return localConv;
    // Fall back to cloud
    return cloud.loadConversation(id);
  }
}
```
