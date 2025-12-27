import 'dart:io';

import 'commands/init_command.dart';
import 'commands/add_command.dart';
import 'commands/list_command.dart';

/// RaptrAI CLI entry point.
void runCli(List<String> args) {
  if (args.isEmpty) {
    _printUsage();
    return;
  }

  final command = args[0];
  final commandArgs = args.length > 1 ? args.sublist(1) : <String>[];

  switch (command) {
    case 'init':
      InitCommand().run(commandArgs);
      break;
    case 'add':
      AddCommand().run(commandArgs);
      break;
    case 'list':
    case 'ls':
      ListCommand().run(commandArgs);
      break;
    case 'help':
    case '-h':
    case '--help':
      _printUsage();
      break;
    case 'version':
    case '-v':
    case '--version':
      _printVersion();
      break;
    default:
      _printError('Unknown command: $command');
      _printUsage();
      exit(1);
  }
}

void _printUsage() {
  stdout.writeln('''
${_cyan}RaptrAI CLI${_reset} - The shadcn/ui for AI apps in Flutter

${_yellow}Usage:${_reset}
  raptrai <command> [arguments]

${_yellow}Commands:${_reset}
  ${_green}init${_reset}          Initialize RaptrAI in your Flutter project
  ${_green}add${_reset} <name>    Add a template to your project
  ${_green}list${_reset}          List all available templates

${_yellow}Examples:${_reset}
  \$ dart run raptrai init
  \$ dart run raptrai add basic-chat
  \$ dart run raptrai add tool-calling --path lib/features/chat

${_yellow}Options:${_reset}
  -h, --help      Show this help message
  -v, --version   Show version information

${_dim}Run "raptrai <command> --help" for more information about a command.${_reset}
''');
}

void _printVersion() {
  stdout.writeln('RaptrAI CLI v0.1.0');
}

void _printError(String message) {
  stderr.writeln('${_red}Error:${_reset} $message');
}

// ANSI color codes
const _reset = '\x1B[0m';
const _red = '\x1B[31m';
const _green = '\x1B[32m';
const _yellow = '\x1B[33m';
const _cyan = '\x1B[36m';
const _dim = '\x1B[2m';
