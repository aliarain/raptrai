import 'dart:io';

/// Helper for reading and modifying pubspec.yaml files.
class PubspecHelper {
  final String content;

  PubspecHelper._(this.content);

  /// Read a pubspec.yaml file.
  static PubspecHelper read(File file) {
    return PubspecHelper._(file.readAsStringSync());
  }

  /// Check if a dependency exists.
  bool hasDependency(String name) {
    // Simple check - look for the dependency name in dependencies section
    final lines = content.split('\n');
    bool inDependencies = false;

    for (final line in lines) {
      if (line.trim() == 'dependencies:') {
        inDependencies = true;
        continue;
      }
      if (inDependencies) {
        // Check if we've left the dependencies section
        if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
          inDependencies = false;
          continue;
        }
        // Check for the dependency
        if (line.trim().startsWith('$name:')) {
          return true;
        }
      }
    }
    return false;
  }

  /// Add a dependency to pubspec.yaml.
  static void addDependency(File file, String name, String version) {
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    final newLines = <String>[];
    bool added = false;
    bool inDependencies = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      newLines.add(line);

      if (line.trim() == 'dependencies:') {
        inDependencies = true;
        continue;
      }

      if (inDependencies && !added) {
        // Find the right place to insert (after flutter_sdk or at end of deps)
        final nextLine = i + 1 < lines.length ? lines[i + 1] : '';

        // If next line is not indented or is empty section header, insert here
        if (nextLine.isNotEmpty &&
            !nextLine.startsWith(' ') &&
            !nextLine.startsWith('\t')) {
          newLines.insert(newLines.length - 1, '  $name: $version');
          added = true;
          inDependencies = false;
        }
        // If we're at a dependency line and alphabetically should insert
        else if (line.trim().isNotEmpty &&
                 line.startsWith('  ') &&
                 !line.trim().startsWith('#')) {
          final depName = line.trim().split(':').first;
          if (depName.compareTo(name) > 0 && !added) {
            newLines.insert(newLines.length - 1, '  $name: $version');
            added = true;
          }
        }
      }
    }

    // If not added yet, find dependencies section and add at end
    if (!added) {
      final result = <String>[];
      bool foundDeps = false;
      int lastDepIndex = -1;

      for (int i = 0; i < newLines.length; i++) {
        result.add(newLines[i]);
        if (newLines[i].trim() == 'dependencies:') {
          foundDeps = true;
        }
        if (foundDeps && newLines[i].startsWith('  ') && !newLines[i].trim().startsWith('#')) {
          lastDepIndex = result.length;
        }
        if (foundDeps && lastDepIndex > 0 &&
            newLines[i].isNotEmpty &&
            !newLines[i].startsWith(' ') &&
            !newLines[i].startsWith('\t') &&
            newLines[i].trim() != 'dependencies:') {
          result.insert(lastDepIndex, '  $name: $version');
          added = true;
          foundDeps = false;
        }
      }

      if (!added && lastDepIndex > 0) {
        result.insert(lastDepIndex, '  $name: $version');
      }

      file.writeAsStringSync(result.join('\n'));
      return;
    }

    file.writeAsStringSync(newLines.join('\n'));
  }
}
