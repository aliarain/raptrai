#!/usr/bin/env dart

import 'package:raptrai/cli/cli.dart';

/// RaptrAI CLI - The shadcn/ui for AI apps in Flutter
///
/// Usage:
///   raptrai init          Initialize RaptrAI in your project
///   raptrai add <name>    Add a template to your project
///   raptrai list          List available templates
///
/// Examples:
///   dart run raptrai init
///   dart run raptrai add basic-chat
///   dart run raptrai add tool-calling
void main(List<String> args) => runCli(args);
