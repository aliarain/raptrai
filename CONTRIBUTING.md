# Contributing to RaptrAI

Thank you for your interest in contributing to RaptrAI! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/raptrx/raptrai/issues)
2. If not, create a new issue with:
   - A clear, descriptive title
   - Steps to reproduce the bug
   - Expected vs actual behavior
   - Flutter/Dart version
   - Device/platform information
   - Screenshots if applicable

### Suggesting Features

1. Check existing issues for similar suggestions
2. Create a new issue with the "feature request" label
3. Describe the feature and its use case
4. Explain why it would benefit users

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Write/update tests
5. Run tests: `flutter test`
6. Run analyzer: `flutter analyze`
7. Commit with clear messages
8. Push to your fork
9. Create a Pull Request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/raptrx/raptrai.git
cd raptrai

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run the example app
cd example
flutter run
```

## Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Format code with `dart format .`
- Write documentation for public APIs
- Add tests for new features

## Commit Messages

Use clear, descriptive commit messages:

```
type(scope): description

- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Code style changes (formatting, etc.)
- refactor: Code refactoring
- test: Adding/updating tests
- chore: Maintenance tasks
```

Example: `feat(providers): add support for custom AI providers`

## Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Ensure all tests pass before submitting PR
- Aim for good test coverage

## Documentation

- Update README if adding new features
- Add dartdoc comments to public APIs
- Update CHANGELOG.md for notable changes

## Questions?

Feel free to open an issue with the "question" label or reach out to the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
