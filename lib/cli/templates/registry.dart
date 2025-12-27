import 'basic_chat.dart';
import 'tool_calling.dart';
import 'multi_thread.dart';

/// A template file to be generated.
class TemplateFile {
  final String path;
  final String content;

  const TemplateFile({
    required this.path,
    required this.content,
  });
}

/// A template that can be added to a project.
class Template {
  final String name;
  final String description;
  final List<TemplateFile> files;
  final String? postInstall;

  const Template({
    required this.name,
    required this.description,
    required this.files,
    this.postInstall,
  });
}

/// Registry of all available templates.
class TemplateRegistry {
  static final List<Template> all = [
    basicChatTemplate,
    toolCallingTemplate,
    multiThreadTemplate,
  ];

  /// Find a template by name.
  static Template? find(String name) {
    final lowercaseName = name.toLowerCase();
    for (final template in all) {
      if (template.name.toLowerCase() == lowercaseName) {
        return template;
      }
    }
    return null;
  }
}
