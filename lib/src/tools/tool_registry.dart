/// Tool registry and execution framework for RaptrAI.
///
/// Provides a simple way to define, register, and execute tools
/// that AI models can call during conversations.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:raptrai/src/providers/provider_interface.dart';

/// A registered tool that can be called by AI providers.
///
/// Example usage:
/// ```dart
/// final weatherTool = RaptrAIRegisteredTool(
///   definition: RaptrAIToolDefinition(
///     name: 'get_weather',
///     description: 'Get current weather for a location',
///     parameters: {
///       'type': 'object',
///       'properties': {
///         'location': {'type': 'string', 'description': 'City name'},
///         'unit': {'type': 'string', 'enum': ['celsius', 'fahrenheit']},
///       },
///       'required': ['location'],
///     },
///   ),
///   handler: (args) async {
///     final location = args['location'] as String;
///     // Fetch weather...
///     return {'temperature': 22, 'condition': 'sunny'};
///   },
/// );
/// ```
@immutable
class RaptrAIRegisteredTool {
  const RaptrAIRegisteredTool({
    required this.definition,
    required this.handler,
    this.onStart,
    this.onComplete,
    this.onError,
    this.timeout = const Duration(seconds: 30),
  });

  /// Tool definition for AI providers.
  final RaptrAIToolDefinition definition;

  /// Function that executes the tool.
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> arguments) handler;

  /// Callback when tool execution starts.
  final void Function(Map<String, dynamic> arguments)? onStart;

  /// Callback when tool execution completes.
  final void Function(Map<String, dynamic> result)? onComplete;

  /// Callback when tool execution fails.
  final void Function(Object error)? onError;

  /// Timeout for tool execution.
  final Duration timeout;

  /// Tool name (convenience getter).
  String get name => definition.name;

  /// Tool description (convenience getter).
  String get description => definition.description;
}

/// Registry for managing and executing tools.
///
/// Example usage:
/// ```dart
/// final registry = RaptrAIToolRegistry();
///
/// // Register tools
/// registry.register(weatherTool);
/// registry.register(searchTool);
///
/// // Get definitions for AI provider
/// final definitions = registry.definitions;
///
/// // Execute a tool call
/// final result = await registry.execute(toolCall);
/// ```
class RaptrAIToolRegistry {
  RaptrAIToolRegistry();

  final Map<String, RaptrAIRegisteredTool> _tools = {};

  /// All registered tools.
  Iterable<RaptrAIRegisteredTool> get tools => _tools.values;

  /// All tool definitions for AI providers.
  List<RaptrAIToolDefinition> get definitions =>
      _tools.values.map((t) => t.definition).toList();

  /// Number of registered tools.
  int get length => _tools.length;

  /// Whether the registry is empty.
  bool get isEmpty => _tools.isEmpty;

  /// Whether the registry has tools.
  bool get isNotEmpty => _tools.isNotEmpty;

  /// Register a tool.
  void register(RaptrAIRegisteredTool tool) {
    _tools[tool.name] = tool;
  }

  /// Register multiple tools.
  void registerAll(Iterable<RaptrAIRegisteredTool> tools) {
    for (final tool in tools) {
      register(tool);
    }
  }

  /// Unregister a tool by name.
  void unregister(String name) {
    _tools.remove(name);
  }

  /// Check if a tool is registered.
  bool has(String name) => _tools.containsKey(name);

  /// Get a tool by name.
  RaptrAIRegisteredTool? get(String name) => _tools[name];

  /// Execute a tool call and return the result.
  Future<RaptrAIToolResult> execute(RaptrAIToolCall toolCall) async {
    final tool = _tools[toolCall.name];
    if (tool == null) {
      return RaptrAIToolResult(
        toolCallId: toolCall.id,
        toolName: toolCall.name,
        success: false,
        error: 'Tool not found: ${toolCall.name}',
      );
    }

    tool.onStart?.call(toolCall.arguments);

    try {
      final result = await tool.handler(toolCall.arguments).timeout(
            tool.timeout,
            onTimeout: () => throw TimeoutException(
              'Tool execution timed out',
              tool.timeout,
            ),
          );

      tool.onComplete?.call(result);

      return RaptrAIToolResult(
        toolCallId: toolCall.id,
        toolName: toolCall.name,
        success: true,
        data: result,
      );
    } catch (e) {
      tool.onError?.call(e);

      return RaptrAIToolResult(
        toolCallId: toolCall.id,
        toolName: toolCall.name,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Execute multiple tool calls in parallel.
  Future<List<RaptrAIToolResult>> executeAll(List<RaptrAIToolCall> toolCalls) {
    return Future.wait(toolCalls.map(execute));
  }

  /// Execute a tool call and return as a message for the conversation.
  Future<RaptrAIMessage> executeAsMessage(RaptrAIToolCall toolCall) async {
    final result = await execute(toolCall);
    return result.toMessage();
  }

  /// Clear all registered tools.
  void clear() => _tools.clear();
}

/// Result of a tool execution.
@immutable
class RaptrAIToolResult {
  const RaptrAIToolResult({
    required this.toolCallId,
    required this.toolName,
    required this.success,
    this.data,
    this.error,
  });

  /// ID of the tool call this result is for.
  final String toolCallId;

  /// Name of the tool that was executed.
  final String toolName;

  /// Whether execution was successful.
  final bool success;

  /// Result data (if successful).
  final Map<String, dynamic>? data;

  /// Error message (if failed).
  final String? error;

  /// Convert to a message for the conversation.
  RaptrAIMessage toMessage() {
    final content = success
        ? _formatResult(data)
        : 'Error: $error';

    return RaptrAIMessage.tool(
      toolCallId: toolCallId,
      content: content,
      name: toolName,
    );
  }

  String _formatResult(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return 'Success';
    }
    // Format as readable string
    final buffer = StringBuffer();
    for (final entry in data.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    return buffer.toString().trim();
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'toolCallId': toolCallId,
      'toolName': toolName,
      'success': success,
      'data': data,
      'error': error,
    };
  }
}

/// Builder for creating tool definitions with a fluent API.
///
/// Example usage:
/// ```dart
/// final tool = RaptrAIToolBuilder('get_weather')
///   .description('Get current weather for a location')
///   .addStringParam('location', description: 'City name', required: true)
///   .addEnumParam('unit', ['celsius', 'fahrenheit'], defaultValue: 'celsius')
///   .handler((args) async {
///     // Implementation
///     return {'temperature': 22};
///   })
///   .build();
/// ```
class RaptrAIToolBuilder {
  RaptrAIToolBuilder(this._name);

  final String _name;
  String _description = '';
  final Map<String, Map<String, dynamic>> _properties = {};
  final List<String> _required = [];
  Future<Map<String, dynamic>> Function(Map<String, dynamic>)? _handler;
  void Function(Map<String, dynamic>)? _onStart;
  void Function(Map<String, dynamic>)? _onComplete;
  void Function(Object)? _onError;
  Duration _timeout = const Duration(seconds: 30);

  /// Set the tool description.
  RaptrAIToolBuilder description(String description) {
    _description = description;
    return this;
  }

  /// Add a string parameter.
  RaptrAIToolBuilder addStringParam(
    String name, {
    String? description,
    bool required = false,
    String? defaultValue,
  }) {
    _properties[name] = {
      'type': 'string',
      if (description != null) 'description': description,
      if (defaultValue != null) 'default': defaultValue,
    };
    if (required) _required.add(name);
    return this;
  }

  /// Add a number parameter.
  RaptrAIToolBuilder addNumberParam(
    String name, {
    String? description,
    bool required = false,
    num? minimum,
    num? maximum,
    num? defaultValue,
  }) {
    _properties[name] = {
      'type': 'number',
      if (description != null) 'description': description,
      if (minimum != null) 'minimum': minimum,
      if (maximum != null) 'maximum': maximum,
      if (defaultValue != null) 'default': defaultValue,
    };
    if (required) _required.add(name);
    return this;
  }

  /// Add an integer parameter.
  RaptrAIToolBuilder addIntegerParam(
    String name, {
    String? description,
    bool required = false,
    int? minimum,
    int? maximum,
    int? defaultValue,
  }) {
    _properties[name] = {
      'type': 'integer',
      if (description != null) 'description': description,
      if (minimum != null) 'minimum': minimum,
      if (maximum != null) 'maximum': maximum,
      if (defaultValue != null) 'default': defaultValue,
    };
    if (required) _required.add(name);
    return this;
  }

  /// Add a boolean parameter.
  RaptrAIToolBuilder addBooleanParam(
    String name, {
    String? description,
    bool required = false,
    bool? defaultValue,
  }) {
    _properties[name] = {
      'type': 'boolean',
      if (description != null) 'description': description,
      if (defaultValue != null) 'default': defaultValue,
    };
    if (required) _required.add(name);
    return this;
  }

  /// Add an enum parameter.
  RaptrAIToolBuilder addEnumParam(
    String name,
    List<String> values, {
    String? description,
    bool required = false,
    String? defaultValue,
  }) {
    _properties[name] = {
      'type': 'string',
      'enum': values,
      if (description != null) 'description': description,
      if (defaultValue != null) 'default': defaultValue,
    };
    if (required) _required.add(name);
    return this;
  }

  /// Add an array parameter.
  RaptrAIToolBuilder addArrayParam(
    String name, {
    String itemType = 'string',
    String? description,
    bool required = false,
  }) {
    _properties[name] = {
      'type': 'array',
      'items': {'type': itemType},
      if (description != null) 'description': description,
    };
    if (required) _required.add(name);
    return this;
  }

  /// Add an object parameter with custom schema.
  RaptrAIToolBuilder addObjectParam(
    String name,
    Map<String, dynamic> schema, {
    String? description,
    bool required = false,
  }) {
    _properties[name] = {
      'type': 'object',
      ...schema,
      if (description != null) 'description': description,
    };
    if (required) _required.add(name);
    return this;
  }

  /// Set the handler function.
  RaptrAIToolBuilder handler(
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) handler,
  ) {
    _handler = handler;
    return this;
  }

  /// Set the onStart callback.
  RaptrAIToolBuilder onStart(void Function(Map<String, dynamic>) callback) {
    _onStart = callback;
    return this;
  }

  /// Set the onComplete callback.
  RaptrAIToolBuilder onComplete(void Function(Map<String, dynamic>) callback) {
    _onComplete = callback;
    return this;
  }

  /// Set the onError callback.
  RaptrAIToolBuilder onError(void Function(Object) callback) {
    _onError = callback;
    return this;
  }

  /// Set the timeout.
  RaptrAIToolBuilder timeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }

  /// Build the registered tool.
  RaptrAIRegisteredTool build() {
    if (_handler == null) {
      throw StateError('Handler must be set before building');
    }

    return RaptrAIRegisteredTool(
      definition: RaptrAIToolDefinition(
        name: _name,
        description: _description,
        parameters: {
          'type': 'object',
          'properties': _properties,
          if (_required.isNotEmpty) 'required': _required,
        },
      ),
      handler: _handler!,
      onStart: _onStart,
      onComplete: _onComplete,
      onError: _onError,
      timeout: _timeout,
    );
  }
}

/// Convenience function to create a simple tool.
RaptrAIRegisteredTool createTool({
  required String name,
  required String description,
  required Map<String, dynamic> parameters,
  required Future<Map<String, dynamic>> Function(Map<String, dynamic>) handler,
  Duration timeout = const Duration(seconds: 30),
}) {
  return RaptrAIRegisteredTool(
    definition: RaptrAIToolDefinition(
      name: name,
      description: description,
      parameters: parameters,
    ),
    handler: handler,
    timeout: timeout,
  );
}
