# Contributing to rules_bun

Thank you for your interest in contributing to rules_bun!

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/mcalhoun/rules_bun.git
   cd rules_bun
   ```

2. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```

3. Build and test:
   ```bash
   bazel test //tests/...
   bazel build //...
   ```

## Code Style

- Use Prettier for code formatting
- Follow Bazel/Starlark style guidelines
- Add docstrings to all public functions
- Keep lines under 100 characters when possible

## Testing

- Add unit tests for new rule implementations
- Add integration tests for new features
- Ensure all tests pass before submitting a PR

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes
3. Ensure all tests pass
4. Update documentation if needed
5. Submit a pull request with a clear description

## Questions?

Open an issue or start a discussion on GitHub.

