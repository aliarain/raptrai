# Tool/Function Calling

Register tools that AI can call during conversations.

## Quick Start

```dart
// 1. Create a registry
final registry = RaptrAIToolRegistry();

// 2. Build and register a tool
final weatherTool = RaptrAIToolBuilder('get_weather')
    .description('Get current weather for a location')
    .addStringParam('location', description: 'City name', required: true)
    .addEnumParam('unit', ['celsius', 'fahrenheit'], defaultValue: 'celsius')
    .handler((args) async {
      final location = args['location'] as String;
      final unit = args['unit'] as String? ?? 'celsius';
      // Your implementation
      return {'temperature': 22, 'condition': 'sunny', 'unit': unit};
    })
    .build();

registry.register(weatherTool);

// 3. Use in RaptrAIChat
RaptrAIChat(
  provider: openai,
  tools: registry.definitions,
  toolRegistry: registry,
)
```

## Builder API

The builder provides type-safe parameter definitions:

```dart
RaptrAIToolBuilder('tool_name')
    .description('What this tool does')

    // String parameter
    .addStringParam('name', description: 'User name', required: true)

    // Number parameter
    .addNumberParam('amount', minimum: 0, maximum: 100)

    // Integer parameter
    .addIntegerParam('count', required: true)

    // Boolean parameter
    .addBooleanParam('enabled', defaultValue: true)

    // Enum parameter
    .addEnumParam('color', ['red', 'green', 'blue'])

    // Array parameter
    .addArrayParam('tags', itemType: 'string')

    // Object parameter
    .addObjectParam('options', {
      'properties': {
        'verbose': {'type': 'boolean'},
        'limit': {'type': 'integer'},
      },
    })

    // Handler
    .handler((args) async {
      return {'result': 'success'};
    })

    // Callbacks
    .onStart((args) => print('Starting with $args'))
    .onComplete((result) => print('Completed: $result'))
    .onError((error) => print('Failed: $error'))

    // Timeout
    .timeout(Duration(seconds: 60))

    .build();
```

## Alternative: createTool Helper

```dart
final tool = createTool(
  name: 'search',
  description: 'Search the web',
  parameters: {
    'type': 'object',
    'properties': {
      'query': {'type': 'string', 'description': 'Search query'},
      'limit': {'type': 'integer', 'default': 10},
    },
    'required': ['query'],
  },
  handler: (args) async {
    final query = args['query'] as String;
    return {'results': ['Result 1', 'Result 2']};
  },
);
```

## Registering Multiple Tools

```dart
registry.registerAll([
  weatherTool,
  searchTool,
  calculatorTool,
]);

// Or register inline
registry.register(
  RaptrAIToolBuilder('hello')
      .description('Say hello')
      .handler((args) async => {'message': 'Hello!'})
      .build(),
);
```

## Executing Tools Manually

```dart
// Execute a single tool call
final result = await registry.execute(toolCall);

if (result.success) {
  print('Result: ${result.data}');
} else {
  print('Error: ${result.error}');
}

// Execute multiple in parallel
final results = await registry.executeAll(toolCalls);

// Convert result to message
final message = result.toMessage();
```

## Tool Executor with UI

For automatic execution with lifecycle hooks:

```dart
final executor = RaptrAIToolExecutor(
  registry: registry,
  controller: conversationController,
  requireApproval: true, // Show approval dialog
  onToolStart: (toolCall) {
    print('Executing: ${toolCall.name}');
  },
  onToolComplete: (toolCall, result) {
    print('Completed: ${result.data}');
  },
  onToolError: (toolCall, error) {
    print('Failed: $error');
  },
);

// Process tool calls from assistant response
await executor.processToolCalls(message.toolCalls);
```

## Tool Approval UI

Control when to ask for user approval:

```dart
RaptrAIChat(
  provider: openai,
  tools: registry.definitions,
  toolRegistry: registry,
  toolApprovalMode: RaptrAIToolApprovalMode.firstUse, // or .auto, .always, .never
)
```

Or use the dialog directly:

```dart
showDialog(
  context: context,
  builder: (_) => RaptrAIToolApprovalDialog(
    toolCall: toolCall,
    toolDescription: 'Gets weather information for any city',
    onApprove: () => executor.execute(toolCall),
    onDeny: () => controller.cancelToolCall(toolCall),
  ),
);
```

## Example Tools

### Calculator

```dart
final calculator = RaptrAIToolBuilder('calculate')
    .description('Evaluate a math expression')
    .addStringParam('expression', required: true)
    .handler((args) async {
      final expr = args['expression'] as String;
      // Use a math parser library
      final result = evaluateMath(expr);
      return {'expression': expr, 'result': result};
    })
    .build();
```

### Web Search

```dart
final webSearch = RaptrAIToolBuilder('web_search')
    .description('Search the internet')
    .addStringParam('query', required: true)
    .addIntegerParam('limit', defaultValue: 5)
    .timeout(Duration(seconds: 30))
    .handler((args) async {
      final query = args['query'] as String;
      final limit = args['limit'] as int? ?? 5;
      final results = await searchApi.search(query, limit: limit);
      return {'query': query, 'results': results};
    })
    .build();
```

### Database Query

```dart
final dbQuery = RaptrAIToolBuilder('query_database')
    .description('Query the user database')
    .addStringParam('sql', required: true)
    .addBooleanParam('readonly', defaultValue: true)
    .handler((args) async {
      final sql = args['sql'] as String;
      final readonly = args['readonly'] as bool? ?? true;

      if (!readonly && !sql.toLowerCase().startsWith('select')) {
        return {'error': 'Only SELECT queries allowed in readonly mode'};
      }

      final results = await database.query(sql);
      return {'rows': results, 'count': results.length};
    })
    .build();
```

### File Operations

```dart
final readFile = RaptrAIToolBuilder('read_file')
    .description('Read contents of a file')
    .addStringParam('path', required: true)
    .handler((args) async {
      final path = args['path'] as String;
      // Validate path for security
      if (!isAllowedPath(path)) {
        return {'error': 'Access denied'};
      }
      final content = await File(path).readAsString();
      return {'path': path, 'content': content};
    })
    .build();
```

## Error Handling

Tools should return errors in the result, not throw:

```dart
.handler((args) async {
  try {
    final result = await riskyOperation(args);
    return {'success': true, 'data': result};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
})
```

The executor will catch unhandled exceptions and report them properly.
