/// Usage tracking for AI API calls.
///
/// Tracks tokens, API calls, and estimated costs across providers.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:raptrai/src/providers/provider_interface.dart';

/// Tracks API usage including tokens, requests, and estimated costs.
///
/// Example usage:
/// ```dart
/// final tracker = RaptrAIUsageTracker(
///   onUsageUpdate: (usage) {
///     print('Total tokens: ${usage.totalTokens}');
///     print('Estimated cost: \$${usage.estimatedCost.toStringAsFixed(4)}');
///   },
///   limits: RaptrAIUsageLimits(
///     maxTokensPerDay: 100000,
///     maxRequestsPerMinute: 10,
///   ),
/// );
///
/// // Connect to conversation controller
/// controller.onUsageUpdate = tracker.trackUsage;
///
/// // Check if limit exceeded
/// if (tracker.isLimitExceeded) {
///   showPaywall();
/// }
/// ```
class RaptrAIUsageTracker extends ChangeNotifier {
  RaptrAIUsageTracker({
    this.onUsageUpdate,
    this.onLimitExceeded,
    this.limits,
    Map<String, RaptrAIModelPricing>? pricing,
  }) : _pricing = pricing ?? _defaultPricing;

  /// Callback when usage is updated.
  final void Function(RaptrAIUsageSnapshot usage)? onUsageUpdate;

  /// Callback when a usage limit is exceeded.
  final void Function(RaptrAILimitType limitType)? onLimitExceeded;

  /// Usage limits.
  final RaptrAIUsageLimits? limits;

  /// Pricing per model.
  final Map<String, RaptrAIModelPricing> _pricing;

  // Tracking data
  int _totalPromptTokens = 0;
  int _totalCompletionTokens = 0;
  int _totalRequests = 0;
  double _totalCost = 0.0;

  // Per-period tracking
  final Map<String, _PeriodUsage> _periodUsage = {};

  // Request timestamps for rate limiting
  final List<DateTime> _recentRequests = [];

  /// Total prompt tokens used.
  int get totalPromptTokens => _totalPromptTokens;

  /// Total completion tokens used.
  int get totalCompletionTokens => _totalCompletionTokens;

  /// Total tokens used.
  int get totalTokens => _totalPromptTokens + _totalCompletionTokens;

  /// Total requests made.
  int get totalRequests => _totalRequests;

  /// Total estimated cost in USD.
  double get totalCost => _totalCost;

  /// Current usage snapshot.
  RaptrAIUsageSnapshot get currentUsage => RaptrAIUsageSnapshot(
        promptTokens: _totalPromptTokens,
        completionTokens: _totalCompletionTokens,
        totalTokens: totalTokens,
        requests: _totalRequests,
        estimatedCost: _totalCost,
        periodUsage: Map.fromEntries(
          _periodUsage.entries.map(
            (e) => MapEntry(e.key, e.value.toSnapshot()),
          ),
        ),
      );

  /// Whether any limit is currently exceeded.
  bool get isLimitExceeded {
    if (limits == null) return false;
    return _checkLimits().isNotEmpty;
  }

  /// Get current limit status.
  List<RaptrAILimitStatus> getLimitStatus() {
    if (limits == null) return [];
    return _checkLimits();
  }

  /// Track usage from a provider response.
  void trackUsage(RaptrAIUsage usage, {String? model}) {
    _totalPromptTokens += usage.promptTokens;
    _totalCompletionTokens += usage.completionTokens;
    _totalRequests++;

    // Track request timestamp for rate limiting
    final now = DateTime.now();
    _recentRequests.add(now);
    _cleanupRecentRequests(now);

    // Calculate cost if pricing available
    if (model != null && _pricing.containsKey(model)) {
      final modelPricing = _pricing[model]!;
      _totalCost += (usage.promptTokens / 1000000) * modelPricing.inputPricePerMillion;
      _totalCost += (usage.completionTokens / 1000000) * modelPricing.outputPricePerMillion;
    }

    // Update period tracking
    _updatePeriodUsage(usage, model);

    // Check limits
    final exceededLimits = _checkLimits();
    for (final status in exceededLimits) {
      if (status.isExceeded) {
        onLimitExceeded?.call(status.limitType);
      }
    }

    // Notify listeners
    onUsageUpdate?.call(currentUsage);
    notifyListeners();
  }

  /// Check if a request can be made without exceeding limits.
  bool canMakeRequest({int estimatedTokens = 0}) {
    if (limits == null) return true;

    // Check rate limit
    if (limits!.maxRequestsPerMinute != null) {
      final now = DateTime.now();
      _cleanupRecentRequests(now);
      if (_recentRequests.length >= limits!.maxRequestsPerMinute!) {
        return false;
      }
    }

    // Check daily token limit
    if (limits!.maxTokensPerDay != null) {
      final todayUsage = _getPeriodUsage(_getDayKey(DateTime.now()));
      if (todayUsage.totalTokens + estimatedTokens > limits!.maxTokensPerDay!) {
        return false;
      }
    }

    return true;
  }

  /// Wait until a request can be made (for rate limiting).
  Future<void> waitForAvailability() async {
    while (!canMakeRequest()) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  /// Reset all usage tracking.
  void reset() {
    _totalPromptTokens = 0;
    _totalCompletionTokens = 0;
    _totalRequests = 0;
    _totalCost = 0.0;
    _periodUsage.clear();
    _recentRequests.clear();
    notifyListeners();
  }

  /// Reset daily usage (call at midnight).
  void resetDaily() {
    final todayKey = _getDayKey(DateTime.now());
    _periodUsage.remove(todayKey);
    notifyListeners();
  }

  /// Get usage for a specific day.
  RaptrAIPeriodUsage? getUsageForDay(DateTime date) {
    final key = _getDayKey(date);
    return _periodUsage[key]?.toSnapshot();
  }

  /// Export usage data as JSON-serializable map.
  Map<String, dynamic> exportUsage() {
    return {
      'totalPromptTokens': _totalPromptTokens,
      'totalCompletionTokens': _totalCompletionTokens,
      'totalRequests': _totalRequests,
      'totalCost': _totalCost,
      'periodUsage': _periodUsage.map(
        (k, v) => MapEntry(k, v.toJson()),
      ),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import usage data.
  void importUsage(Map<String, dynamic> data) {
    _totalPromptTokens = (data['totalPromptTokens'] as num?)?.toInt() ?? 0;
    _totalCompletionTokens = (data['totalCompletionTokens'] as num?)?.toInt() ?? 0;
    _totalRequests = (data['totalRequests'] as num?)?.toInt() ?? 0;
    _totalCost = (data['totalCost'] as num?)?.toDouble() ?? 0.0;

    final periodData = data['periodUsage'] as Map<String, dynamic>?;
    if (periodData != null) {
      _periodUsage.clear();
      periodData.forEach((key, value) {
        _periodUsage[key] = _PeriodUsage.fromJson(value as Map<String, dynamic>);
      });
    }

    notifyListeners();
  }

  void _updatePeriodUsage(RaptrAIUsage usage, String? model) {
    final now = DateTime.now();
    final dayKey = _getDayKey(now);

    _periodUsage.putIfAbsent(dayKey, _PeriodUsage.new);
    _periodUsage[dayKey]!.add(usage, model, _pricing);
  }

  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  _PeriodUsage _getPeriodUsage(String key) {
    return _periodUsage[key] ?? _PeriodUsage();
  }

  void _cleanupRecentRequests(DateTime now) {
    final cutoff = now.subtract(const Duration(minutes: 1));
    _recentRequests.removeWhere((t) => t.isBefore(cutoff));
  }

  List<RaptrAILimitStatus> _checkLimits() {
    if (limits == null) return [];

    final results = <RaptrAILimitStatus>[];

    // Check daily token limit
    if (limits!.maxTokensPerDay != null) {
      final todayUsage = _getPeriodUsage(_getDayKey(DateTime.now()));
      results.add(RaptrAILimitStatus(
        limitType: RaptrAILimitType.dailyTokens,
        current: todayUsage.totalTokens,
        limit: limits!.maxTokensPerDay!,
        isExceeded: todayUsage.totalTokens >= limits!.maxTokensPerDay!,
      ));
    }

    // Check rate limit
    if (limits!.maxRequestsPerMinute != null) {
      final now = DateTime.now();
      _cleanupRecentRequests(now);
      results.add(RaptrAILimitStatus(
        limitType: RaptrAILimitType.requestsPerMinute,
        current: _recentRequests.length,
        limit: limits!.maxRequestsPerMinute!,
        isExceeded: _recentRequests.length >= limits!.maxRequestsPerMinute!,
      ));
    }

    // Check daily cost limit
    if (limits!.maxCostPerDay != null) {
      final todayUsage = _getPeriodUsage(_getDayKey(DateTime.now()));
      results.add(RaptrAILimitStatus(
        limitType: RaptrAILimitType.dailyCost,
        current: todayUsage.cost.round(),
        limit: (limits!.maxCostPerDay! * 100).round(), // cents
        isExceeded: todayUsage.cost >= limits!.maxCostPerDay!,
      ));
    }

    return results;
  }

  /// Default pricing for common models (USD per million tokens).
  static final Map<String, RaptrAIModelPricing> _defaultPricing = {
    // OpenAI
    'gpt-4-turbo': const RaptrAIModelPricing(
      inputPricePerMillion: 10.0,
      outputPricePerMillion: 30.0,
    ),
    'gpt-4-turbo-preview': const RaptrAIModelPricing(
      inputPricePerMillion: 10.0,
      outputPricePerMillion: 30.0,
    ),
    'gpt-4': const RaptrAIModelPricing(
      inputPricePerMillion: 30.0,
      outputPricePerMillion: 60.0,
    ),
    'gpt-4o': const RaptrAIModelPricing(
      inputPricePerMillion: 5.0,
      outputPricePerMillion: 15.0,
    ),
    'gpt-4o-mini': const RaptrAIModelPricing(
      inputPricePerMillion: 0.15,
      outputPricePerMillion: 0.60,
    ),
    'gpt-3.5-turbo': const RaptrAIModelPricing(
      inputPricePerMillion: 0.50,
      outputPricePerMillion: 1.50,
    ),
    // Anthropic
    'claude-3-opus-20240229': const RaptrAIModelPricing(
      inputPricePerMillion: 15.0,
      outputPricePerMillion: 75.0,
    ),
    'claude-3-sonnet-20240229': const RaptrAIModelPricing(
      inputPricePerMillion: 3.0,
      outputPricePerMillion: 15.0,
    ),
    'claude-3-haiku-20240307': const RaptrAIModelPricing(
      inputPricePerMillion: 0.25,
      outputPricePerMillion: 1.25,
    ),
    'claude-3-5-sonnet-20241022': const RaptrAIModelPricing(
      inputPricePerMillion: 3.0,
      outputPricePerMillion: 15.0,
    ),
    // Google
    'gemini-1.5-pro': const RaptrAIModelPricing(
      inputPricePerMillion: 3.50,
      outputPricePerMillion: 10.50,
    ),
    'gemini-1.5-flash': const RaptrAIModelPricing(
      inputPricePerMillion: 0.075,
      outputPricePerMillion: 0.30,
    ),
    'gemini-pro': const RaptrAIModelPricing(
      inputPricePerMillion: 0.50,
      outputPricePerMillion: 1.50,
    ),
  };
}

/// Pricing information for a model.
@immutable
class RaptrAIModelPricing {
  const RaptrAIModelPricing({
    required this.inputPricePerMillion,
    required this.outputPricePerMillion,
  });

  /// Price per million input tokens in USD.
  final double inputPricePerMillion;

  /// Price per million output tokens in USD.
  final double outputPricePerMillion;
}

/// Usage limits configuration.
@immutable
class RaptrAIUsageLimits {
  const RaptrAIUsageLimits({
    this.maxTokensPerDay,
    this.maxRequestsPerMinute,
    this.maxCostPerDay,
    this.maxTokensPerRequest,
  });

  /// Maximum tokens allowed per day.
  final int? maxTokensPerDay;

  /// Maximum requests per minute (rate limiting).
  final int? maxRequestsPerMinute;

  /// Maximum cost per day in USD.
  final double? maxCostPerDay;

  /// Maximum tokens per single request.
  final int? maxTokensPerRequest;
}

/// Types of usage limits.
enum RaptrAILimitType {
  /// Daily token limit.
  dailyTokens,

  /// Requests per minute rate limit.
  requestsPerMinute,

  /// Daily cost limit.
  dailyCost,

  /// Per-request token limit.
  requestTokens,
}

/// Status of a usage limit.
@immutable
class RaptrAILimitStatus {
  const RaptrAILimitStatus({
    required this.limitType,
    required this.current,
    required this.limit,
    required this.isExceeded,
  });

  /// Type of limit.
  final RaptrAILimitType limitType;

  /// Current usage value.
  final int current;

  /// Limit value.
  final int limit;

  /// Whether the limit is exceeded.
  final bool isExceeded;

  /// Percentage of limit used (0.0 to 1.0+).
  double get percentUsed => limit > 0 ? current / limit : 0.0;

  /// Remaining before limit.
  int get remaining => (limit - current).clamp(0, limit);
}

/// Snapshot of current usage.
@immutable
class RaptrAIUsageSnapshot {
  const RaptrAIUsageSnapshot({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.requests,
    required this.estimatedCost,
    this.periodUsage = const {},
  });

  /// Total prompt tokens used.
  final int promptTokens;

  /// Total completion tokens used.
  final int completionTokens;

  /// Total tokens used.
  final int totalTokens;

  /// Total requests made.
  final int requests;

  /// Estimated cost in USD.
  final double estimatedCost;

  /// Usage by period (e.g., by day).
  final Map<String, RaptrAIPeriodUsage> periodUsage;
}

/// Usage for a specific period (e.g., a day).
@immutable
class RaptrAIPeriodUsage {
  const RaptrAIPeriodUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.requests,
    required this.cost,
  });

  /// Prompt tokens in this period.
  final int promptTokens;

  /// Completion tokens in this period.
  final int completionTokens;

  /// Total tokens in this period.
  final int totalTokens;

  /// Requests in this period.
  final int requests;

  /// Cost in this period (USD).
  final double cost;
}

/// Internal mutable period usage tracker.
class _PeriodUsage {
  int promptTokens = 0;
  int completionTokens = 0;
  int requests = 0;
  double cost = 0.0;

  int get totalTokens => promptTokens + completionTokens;

  void add(
    RaptrAIUsage usage,
    String? model,
    Map<String, RaptrAIModelPricing> pricing,
  ) {
    promptTokens += usage.promptTokens;
    completionTokens += usage.completionTokens;
    requests++;

    if (model != null && pricing.containsKey(model)) {
      final modelPricing = pricing[model]!;
      cost += (usage.promptTokens / 1000000) * modelPricing.inputPricePerMillion;
      cost += (usage.completionTokens / 1000000) * modelPricing.outputPricePerMillion;
    }
  }

  RaptrAIPeriodUsage toSnapshot() {
    return RaptrAIPeriodUsage(
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      totalTokens: totalTokens,
      requests: requests,
      cost: cost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promptTokens': promptTokens,
      'completionTokens': completionTokens,
      'requests': requests,
      'cost': cost,
    };
  }

  static _PeriodUsage fromJson(Map<String, dynamic> json) {
    return _PeriodUsage()
      ..promptTokens = (json['promptTokens'] as num?)?.toInt() ?? 0
      ..completionTokens = (json['completionTokens'] as num?)?.toInt() ?? 0
      ..requests = (json['requests'] as num?)?.toInt() ?? 0
      ..cost = (json['cost'] as num?)?.toDouble() ?? 0.0;
  }
}
