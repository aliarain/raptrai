import 'dart:io';

import 'console.dart';

/// Utility for writing template files to disk.
class FileWriter {
  final String basePath;
  final bool force;

  FileWriter({
    required this.basePath,
    this.force = false,
  });

  /// Write a file to the specified path.
  /// Returns true if file was written, false if skipped.
  bool write(String relativePath, String content) {
    final fullPath = '$basePath/$relativePath';
    final file = File(fullPath);

    // Check if file exists and we're not forcing
    if (file.existsSync() && !force) {
      Console.fileSkipped(relativePath);
      return false;
    }

    // Create directory if needed
    final dir = file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // Write the file
    file.writeAsStringSync(content);
    return true;
  }
}
