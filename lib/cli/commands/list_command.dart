import 'dart:io';

import '../templates/registry.dart';
import '../utils/console.dart';

/// List all available templates.
class ListCommand {
  void run(List<String> args) {
    if (args.contains('--help') || args.contains('-h')) {
      _printHelp();
      return;
    }

    Console.info('Available templates:\n');

    for (final template in TemplateRegistry.all) {
      Console.template(
        name: template.name,
        description: template.description,
        files: template.files.length,
      );
    }

    Console.info('\nUsage:');
    Console.command('  dart run raptrai add <template-name>');
    Console.info('\nExample:');
    Console.command('  dart run raptrai add basic-chat');
    Console.command('  dart run raptrai add tool-calling --path lib/features/ai');
  }

  void _printHelp() {
    stdout.writeln('''
List all available RaptrAI templates.

Usage: raptrai list [options]

Options:
  -h, --help    Show this help message

Templates are pre-built Flutter code that you can add to your project.
They include screens, widgets, and configurations for common AI app patterns.

Example:
  \$ dart run raptrai list
''');
  }
}
