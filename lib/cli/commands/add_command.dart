import 'dart:io';

import '../templates/registry.dart';
import '../utils/console.dart';
import '../utils/file_writer.dart';

/// Add a template to the project.
class AddCommand {
  void run(List<String> args) {
    if (args.contains('--help') || args.contains('-h')) {
      _printHelp();
      return;
    }

    if (args.isEmpty) {
      Console.error('Please specify a template name.');
      Console.info('\nAvailable templates:');
      for (final t in TemplateRegistry.all) {
        Console.info('  - ${t.name}');
      }
      Console.info('\nUsage:');
      Console.command('  dart run raptrai add <template-name>');
      exit(1);
    }

    final templateName = args[0];
    final template = TemplateRegistry.find(templateName);

    if (template == null) {
      Console.error('Template "$templateName" not found.');
      Console.info('\nAvailable templates:');
      for (final t in TemplateRegistry.all) {
        Console.info('  - ${t.name}');
      }
      exit(1);
    }

    // Parse options
    String outputPath = 'lib';
    bool force = false;

    for (int i = 1; i < args.length; i++) {
      if (args[i] == '--path' && i + 1 < args.length) {
        outputPath = args[i + 1];
        i++;
      } else if (args[i] == '--force' || args[i] == '-f') {
        force = true;
      }
    }

    Console.info('Adding ${template.name} template...\n');

    // Check if we're in a Flutter project
    if (!File('pubspec.yaml').existsSync()) {
      Console.error('No pubspec.yaml found. Are you in a Flutter project?');
      Console.info('Run this command from your Flutter project root.');
      exit(1);
    }

    // Write template files
    final writer = FileWriter(basePath: outputPath, force: force);

    try {
      for (final file in template.files) {
        writer.write(file.path, file.content);
        Console.fileCreated(file.path);
      }
    } catch (e) {
      Console.error('Failed to write files: $e');
      exit(1);
    }

    Console.info('');
    Console.success('${template.name} template added successfully!\n');

    if (template.postInstall != null) {
      Console.info('Next steps:');
      Console.info(template.postInstall!);
    }
  }

  void _printHelp() {
    stdout.writeln('''
Add a template to your project.

Usage: raptrai add <template> [options]

Arguments:
  template      Name of the template to add

Options:
  --path        Output directory (default: lib)
  -f, --force   Overwrite existing files
  -h, --help    Show this help message

Available templates:
${TemplateRegistry.all.map((t) => '  - ${t.name.padRight(16)} ${t.description}').join('\n')}

Examples:
  \$ dart run raptrai add basic-chat
  \$ dart run raptrai add tool-calling --path lib/features/ai
  \$ dart run raptrai add multi-thread --force
''');
  }
}
