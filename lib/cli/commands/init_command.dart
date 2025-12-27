import 'dart:io';

import '../utils/console.dart';
import '../utils/pubspec.dart';

/// Initialize RaptrAI in a Flutter project.
class InitCommand {
  void run(List<String> args) {
    if (args.contains('--help') || args.contains('-h')) {
      _printHelp();
      return;
    }

    Console.info('Initializing RaptrAI in your project...\n');

    // Check if we're in a Flutter project
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      Console.error('No pubspec.yaml found. Are you in a Flutter project?');
      exit(1);
    }

    // Check if raptrai is already in dependencies
    final pubspec = PubspecHelper.read(pubspecFile);
    if (pubspec.hasDependency('raptrai')) {
      Console.success('RaptrAI is already in your dependencies!');
      Console.info('\nYou can now add templates with:');
      Console.command('  dart run raptrai add basic-chat');
      return;
    }

    // Add raptrai to dependencies
    Console.step('Adding raptrai to pubspec.yaml...');

    try {
      PubspecHelper.addDependency(pubspecFile, 'raptrai', '^0.1.0');
      Console.success('Added raptrai to dependencies');
    } catch (e) {
      Console.error('Failed to update pubspec.yaml: $e');
      Console.info('\nPlease add manually:');
      Console.code('''
dependencies:
  raptrai: ^0.1.0
''');
      exit(1);
    }

    // Run flutter pub get
    Console.step('Running flutter pub get...');
    final result = Process.runSync('flutter', ['pub', 'get']);
    if (result.exitCode != 0) {
      Console.warning('flutter pub get failed. Run it manually.');
    } else {
      Console.success('Dependencies installed');
    }

    // Print next steps
    Console.info('');
    Console.success('RaptrAI initialized successfully!\n');
    Console.info('Next steps:');
    Console.info('  1. Add a template to get started:');
    Console.command('     dart run raptrai add basic-chat\n');
    Console.info('  2. Or see all available templates:');
    Console.command('     dart run raptrai list\n');
  }

  void _printHelp() {
    stdout.writeln('''
Initialize RaptrAI in your Flutter project.

Usage: raptrai init [options]

Options:
  -h, --help    Show this help message

This command will:
  1. Add raptrai to your pubspec.yaml
  2. Run flutter pub get
  3. Set up the basic configuration

Example:
  \$ dart run raptrai init
''');
  }
}
