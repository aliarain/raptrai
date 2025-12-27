import 'dart:io';

/// Console output utilities with ANSI color support.
class Console {
  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  /// Print an error message in red.
  static void error(String message) {
    stderr.writeln('$_red✗ $message$_reset');
  }

  /// Print an info message.
  static void info(String message) {
    stdout.writeln(message);
  }

  /// Print a success message in green.
  static void success(String message) {
    stdout.writeln('$_green✓ $message$_reset');
  }

  /// Print a warning message in yellow.
  static void warning(String message) {
    stdout.writeln('$_yellow⚠ $message$_reset');
  }

  /// Print a step indicator.
  static void step(String message) {
    stdout.writeln('$_cyan→ $message$_reset');
  }

  /// Print a command suggestion in cyan.
  static void command(String message) {
    stdout.writeln('$_cyan$message$_reset');
  }

  /// Print a code block in dim.
  static void code(String code) {
    stdout.writeln('$_dim$code$_reset');
  }

  /// Print file created message.
  static void fileCreated(String path) {
    stdout.writeln('  $_green+$_reset $path');
  }

  /// Print file skipped message.
  static void fileSkipped(String path) {
    stdout.writeln('  $_yellow○$_reset $path (exists, use --force to overwrite)');
  }

  /// Print a template listing.
  static void template({
    required String name,
    required String description,
    required int files,
  }) {
    stdout.writeln('  $_bold$_magenta$name$_reset');
    stdout.writeln('    $description');
    stdout.writeln('    $_dim$files file${files == 1 ? '' : 's'}$_reset\n');
  }

  /// Print the RaptrAI logo/header.
  static void header() {
    stdout.writeln('''
$_bold$_magenta
  ██████╗  █████╗ ██████╗ ████████╗██████╗  █████╗ ██╗
  ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██║
  ██████╔╝███████║██████╔╝   ██║   ██████╔╝███████║██║
  ██╔══██╗██╔══██║██╔═══╝    ██║   ██╔══██╗██╔══██║██║
  ██║  ██║██║  ██║██║        ██║   ██║  ██║██║  ██║██║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝
$_reset  $_dim The shadcn/ui for AI apps in Flutter$_reset
''');
  }
}
