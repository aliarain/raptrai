/// Tool executor for handling tool calls in conversations.
///
/// Provides automated tool execution with conversation integration.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:raptrai/src/conversation/conversation_controller.dart';
import 'package:raptrai/src/providers/provider_interface.dart';
import 'package:raptrai/src/tools/tool_registry.dart';

/// Executor that handles tool calls automatically in a conversation.
///
/// Example usage:
/// ```dart
/// final executor = RaptrAIToolExecutor(
///   registry: toolRegistry,
///   controller: conversationController,
///   autoExecute: true,
/// );
///
/// // Tool calls are automatically executed when the AI requests them
/// await executor.processResponse(response);
/// ```
class RaptrAIToolExecutor {
  RaptrAIToolExecutor({
    required this.registry,
    this.controller,
    this.autoExecute = true,
    this.maxIterations = 10,
    this.onToolStart,
    this.onToolComplete,
    this.onToolError,
    this.requireApproval,
  });

  /// Tool registry containing available tools.
  final RaptrAIToolRegistry registry;

  /// Conversation controller for sending follow-up messages.
  final RaptrAIConversationController? controller;

  /// Whether to automatically execute tool calls.
  final bool autoExecute;

  /// Maximum iterations of tool call -> response loops.
  final int maxIterations;

  /// Callback when a tool starts executing.
  final void Function(RaptrAIToolCall toolCall)? onToolStart;

  /// Callback when a tool completes.
  final void Function(RaptrAIToolCall toolCall, RaptrAIToolResult result)? onToolComplete;

  /// Callback when a tool errors.
  final void Function(RaptrAIToolCall toolCall, Object error)? onToolError;

  /// Optional approval callback - if provided, tools wait for approval.
  final Future<bool> Function(RaptrAIToolCall toolCall)? requireApproval;

  /// Execute a single tool call.
  Future<RaptrAIToolResult> execute(RaptrAIToolCall toolCall) async {
    // Check approval if required
    if (requireApproval != null) {
      final approved = await requireApproval!(toolCall);
      if (!approved) {
        return RaptrAIToolResult(
          toolCallId: toolCall.id,
          toolName: toolCall.name,
          success: false,
          error: 'Tool execution was not approved',
        );
      }
    }

    onToolStart?.call(toolCall);

    try {
      final result = await registry.execute(toolCall);
      onToolComplete?.call(toolCall, result);
      return result;
    } catch (e) {
      onToolError?.call(toolCall, e);
      return RaptrAIToolResult(
        toolCallId: toolCall.id,
        toolName: toolCall.name,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Execute multiple tool calls (in parallel by default).
  Future<List<RaptrAIToolResult>> executeAll(
    List<RaptrAIToolCall> toolCalls, {
    bool parallel = true,
  }) async {
    if (parallel) {
      return Future.wait(toolCalls.map(execute));
    } else {
      final results = <RaptrAIToolResult>[];
      for (final toolCall in toolCalls) {
        results.add(await execute(toolCall));
      }
      return results;
    }
  }

  /// Process tool calls from a message and return results as messages.
  Future<List<RaptrAIMessage>> processToolCalls(
    List<RaptrAIToolCall> toolCalls,
  ) async {
    final results = await executeAll(toolCalls);
    return results.map((r) => r.toMessage()).toList();
  }
}

/// Status of a tool execution for UI display.
enum RaptrAIToolExecutionStatus {
  /// Waiting to start.
  pending,

  /// Waiting for user approval.
  awaitingApproval,

  /// Currently executing.
  running,

  /// Completed successfully.
  completed,

  /// Failed with error.
  failed,

  /// Cancelled by user.
  cancelled,
}

/// Tracks the state of tool executions for UI display.
class RaptrAIToolExecutionState extends ChangeNotifier {
  final Map<String, RaptrAIToolExecutionInfo> _executions = {};

  /// Get all current executions.
  Map<String, RaptrAIToolExecutionInfo> get executions => Map.unmodifiable(_executions);

  /// Get execution info for a tool call.
  RaptrAIToolExecutionInfo? getExecution(String toolCallId) => _executions[toolCallId];

  /// Start tracking a tool execution.
  void startExecution(RaptrAIToolCall toolCall) {
    _executions[toolCall.id] = RaptrAIToolExecutionInfo(
      toolCall: toolCall,
      status: RaptrAIToolExecutionStatus.running,
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  /// Mark execution as awaiting approval.
  void awaitApproval(String toolCallId) {
    final info = _executions[toolCallId];
    if (info != null) {
      _executions[toolCallId] = info.copyWith(
        status: RaptrAIToolExecutionStatus.awaitingApproval,
      );
      notifyListeners();
    }
  }

  /// Mark execution as completed.
  void completeExecution(String toolCallId, RaptrAIToolResult result) {
    final info = _executions[toolCallId];
    if (info != null) {
      _executions[toolCallId] = info.copyWith(
        status: result.success
            ? RaptrAIToolExecutionStatus.completed
            : RaptrAIToolExecutionStatus.failed,
        result: result,
        endTime: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Mark execution as failed.
  void failExecution(String toolCallId, String error) {
    final info = _executions[toolCallId];
    if (info != null) {
      _executions[toolCallId] = info.copyWith(
        status: RaptrAIToolExecutionStatus.failed,
        error: error,
        endTime: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Cancel an execution.
  void cancelExecution(String toolCallId) {
    final info = _executions[toolCallId];
    if (info != null) {
      _executions[toolCallId] = info.copyWith(
        status: RaptrAIToolExecutionStatus.cancelled,
        endTime: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Clear all executions.
  void clear() {
    _executions.clear();
    notifyListeners();
  }

  /// Remove completed/failed executions.
  void clearCompleted() {
    _executions.removeWhere((_, info) =>
        info.status == RaptrAIToolExecutionStatus.completed ||
        info.status == RaptrAIToolExecutionStatus.failed ||
        info.status == RaptrAIToolExecutionStatus.cancelled);
    notifyListeners();
  }
}

/// Information about a tool execution for UI display.
@immutable
class RaptrAIToolExecutionInfo {
  const RaptrAIToolExecutionInfo({
    required this.toolCall,
    required this.status,
    this.startTime,
    this.endTime,
    this.result,
    this.error,
  });

  /// The tool call being executed.
  final RaptrAIToolCall toolCall;

  /// Current execution status.
  final RaptrAIToolExecutionStatus status;

  /// When execution started.
  final DateTime? startTime;

  /// When execution ended.
  final DateTime? endTime;

  /// Result of the execution (if completed).
  final RaptrAIToolResult? result;

  /// Error message (if failed).
  final String? error;

  /// Duration of the execution.
  Duration? get duration =>
      startTime != null && endTime != null
          ? endTime!.difference(startTime!)
          : null;

  /// Create a copy with updated fields.
  RaptrAIToolExecutionInfo copyWith({
    RaptrAIToolCall? toolCall,
    RaptrAIToolExecutionStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    RaptrAIToolResult? result,
    String? error,
  }) {
    return RaptrAIToolExecutionInfo(
      toolCall: toolCall ?? this.toolCall,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

/// Common tool definitions that can be reused.
class RaptrAICommonTools {
  RaptrAICommonTools._();

  /// Create a web search tool definition.
  static RaptrAIToolDefinition webSearch({
    String name = 'web_search',
    String description = 'Search the web for information',
  }) {
    return RaptrAIToolDefinition(
      name: name,
      description: description,
      parameters: {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'The search query',
          },
          'num_results': {
            'type': 'integer',
            'description': 'Number of results to return',
            'default': 5,
          },
        },
        'required': ['query'],
      },
    );
  }

  /// Create a calculator tool definition.
  static RaptrAIToolDefinition calculator({
    String name = 'calculator',
    String description = 'Perform mathematical calculations',
  }) {
    return RaptrAIToolDefinition(
      name: name,
      description: description,
      parameters: {
        'type': 'object',
        'properties': {
          'expression': {
            'type': 'string',
            'description': 'Mathematical expression to evaluate',
          },
        },
        'required': ['expression'],
      },
    );
  }

  /// Create a get current time tool definition.
  static RaptrAIToolDefinition getCurrentTime({
    String name = 'get_current_time',
    String description = 'Get the current date and time',
  }) {
    return RaptrAIToolDefinition(
      name: name,
      description: description,
      parameters: {
        'type': 'object',
        'properties': {
          'timezone': {
            'type': 'string',
            'description': 'Timezone (e.g., "America/New_York")',
          },
        },
      },
    );
  }

  /// Create a weather tool definition.
  static RaptrAIToolDefinition getWeather({
    String name = 'get_weather',
    String description = 'Get current weather for a location',
  }) {
    return RaptrAIToolDefinition(
      name: name,
      description: description,
      parameters: {
        'type': 'object',
        'properties': {
          'location': {
            'type': 'string',
            'description': 'City name or location',
          },
          'unit': {
            'type': 'string',
            'enum': ['celsius', 'fahrenheit'],
            'default': 'celsius',
          },
        },
        'required': ['location'],
      },
    );
  }
}
