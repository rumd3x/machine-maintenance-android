# Copilot Instructions Documentation

**🚨 READ FIRST**: [DOCUMENTATION-MANDATE.md](DOCUMENTATION-MANDATE.md) - **MANDATORY** documentation requirements for ALL code changes.

This folder contains structured documentation for GitHub Copilot to understand the project context, requirements, and decisions.

## Structure

### Setup & Configuration
- **documentation-structure.md** - How copilot-instructions are organized and maintained
- **android-requirements.md** - Android app requirements and constraints
- **technical-architecture.md** - Technical stack and architecture decisions
- **flutter-setup.md** - Flutter project initialization and build configuration

### Product Definition
- **app-concept.md** - Core app concept and principles
- **features.md** - Detailed feature specifications and functionality
- **data-model.md** - Database schema and data structures
- **ui-design.md** - UI/UX design guidelines and reference

### Development
- **progress.md** - Current development status and roadmap
- **notifications.md** - Notification system architecture and implementation
- **database-backup.md** - Database export/import functionality
- **maintenance-history.md** - Maintenance tracking and history features
- **version-management.md** - App versioning strategy and automation

### CI/CD & Release
- **ci-cd-pipeline.md** - Jenkins CI/CD pipeline architecture and stages
- **play-store-publishing.md** - Play Store publishing integration and security

## Purpose

All instructions and decisions communicated during development are recorded here to maintain context and ensure consistency throughout the project lifecycle.

## Documentation Requirements

**CRITICAL**: All code changes, new features, and architectural decisions MUST be documented in this directory.

### When to Document

Document immediately after:
1. **Adding new features** - Update features.md and create dedicated documentation file if complex
2. **Modifying database schema** - Update data-model.md and increment version in copilot-instructions.md
3. **Changing architecture** - Update technical-architecture.md
4. **Adding dependencies** - Document in relevant files and copilot-instructions.md
5. **Implementing critical systems** - Create dedicated documentation file (e.g., notifications.md, database-backup.md)
6. **Bug fixes affecting behavior** - Document workarounds and solutions
7. **UI/UX changes** - Update ui-design.md

### Documentation Standards

- Use ISO 8601 date format in headers
- Include code examples for complex implementations
- Document error handling patterns
- List all related files and their purposes
- Include best practices and warnings
- Update progress.md to track implementation status

### Required Elements

Each documentation file should include:
- Date created/updated
- Overview/purpose
- Implementation details
- Related files with paths
- Dependencies
- Best practices
- Error handling approach
- Future enhancements (if applicable)

**Remember**: If it's important enough to code, it's important enough to document.
