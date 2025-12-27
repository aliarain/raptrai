import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A widget that displays streaming text with an animated cursor.
///
/// Used to show AI responses as they're being generated.
class RaptrAIStreamingText extends StatefulWidget {
  /// The text content to display.
  final String text;

  /// Text style.
  final TextStyle? style;

  /// Whether to show the blinking cursor.
  final bool showCursor;

  /// Cursor character.
  final String cursor;

  /// Cursor color.
  final Color? cursorColor;

  /// Whether the stream is complete.
  final bool isComplete;

  /// Callback when stream completes.
  final VoidCallback? onComplete;

  const RaptrAIStreamingText({
    super.key,
    required this.text,
    this.style,
    this.showCursor = true,
    this.cursor = '▋',
    this.cursorColor,
    this.isComplete = false,
    this.onComplete,
  });

  @override
  State<RaptrAIStreamingText> createState() => _RaptrAIStreamingTextState();
}

class _RaptrAIStreamingTextState extends State<RaptrAIStreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RaptrAIStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isComplete && !oldWidget.isComplete) {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStyle = TextStyle(
      color: isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
      height: 1.5,
    );
    final textStyle = widget.style ?? defaultStyle;
    final cursorColor = widget.cursorColor ?? RaptrAIColors.accent;

    if (widget.isComplete || !widget.showCursor) {
      return Text(widget.text, style: textStyle);
    }

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: widget.text),
          WidgetSpan(
            child: AnimatedBuilder(
              animation: _cursorController,
              builder: (context, child) {
                return Opacity(
                  opacity: _cursorController.value,
                  child: Text(
                    widget.cursor,
                    style: textStyle.copyWith(color: cursorColor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that reveals text character by character with typing animation.
class RaptrAITypewriterText extends StatefulWidget {
  /// The full text to reveal.
  final String text;

  /// Text style.
  final TextStyle? style;

  /// Duration per character.
  final Duration characterDuration;

  /// Callback when animation completes.
  final VoidCallback? onComplete;

  /// Whether to start animation immediately.
  final bool autoStart;

  const RaptrAITypewriterText({
    super.key,
    required this.text,
    this.style,
    this.characterDuration = const Duration(milliseconds: 30),
    this.onComplete,
    this.autoStart = true,
  });

  @override
  State<RaptrAITypewriterText> createState() => RaptrAITypewriterTextState();
}

class RaptrAITypewriterTextState extends State<RaptrAITypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    if (widget.autoStart) {
      start();
    }
  }

  void _setupAnimation() {
    final totalDuration = widget.characterDuration * widget.text.length;

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isComplete) {
        _isComplete = true;
        widget.onComplete?.call();
      }
    });
  }

  /// Starts the typewriter animation.
  void start() {
    _controller.forward();
  }

  /// Resets and restarts the animation.
  void restart() {
    _isComplete = false;
    _controller.reset();
    _controller.forward();
  }

  /// Skips to the end of the animation.
  void skip() {
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RaptrAITypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.dispose();
      _setupAnimation();
      if (widget.autoStart) {
        start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStyle = TextStyle(
      color: isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
      height: 1.5,
    );

    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        return Text(
          widget.text.substring(0, _characterCount.value),
          style: widget.style ?? defaultStyle,
        );
      },
    );
  }
}
