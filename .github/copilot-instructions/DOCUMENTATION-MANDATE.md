# 🚨 CRITICAL: Documentation Mandate

**This is a MANDATORY requirement for all code changes**

## Golden Rule

> **If you write code, you MUST document it. No exceptions.**

## When Documentation is REQUIRED

Document **IMMEDIATELY** after any of these actions:

### 1. Database Changes
- ✅ Schema modifications (new tables, columns, indexes)
- ✅ Version increments
- ✅ Migration logic
- ✅ New queries or CRUD operations
- **Update**: `data-model.md`, main `copilot-instructions.md` (version history)

### 2. New Features
- ✅ Any new user-facing functionality
- ✅ New screens or major UI components
- ✅ New services or business logic
- ✅ New background processes
- **Update**: `features.md`, `progress.md`, create dedicated file if complex

### 3. Architecture Changes
- ✅ New dependencies added
- ✅ New design patterns introduced
- ✅ Service structure modifications
- ✅ State management changes
- **Update**: `technical-architecture.md`, main `copilot-instructions.md`

### 4. Critical Systems
- ✅ Notification system modifications
- ✅ Background task changes
- ✅ Permission requirements
- ✅ Data persistence strategies
- **Update**: Dedicated system documentation file (e.g., `notifications.md`)

### 5. Bug Fixes with Behavioral Impact
- ✅ Fixes that change user experience
- ✅ Workarounds for platform limitations
- ✅ Performance optimizations
- **Update**: `progress.md` (Recent Updates section)

### 6. UI/UX Changes
- ✅ New screens or layouts
- ✅ Navigation pattern changes
- ✅ Theme or styling updates
- **Update**: `ui-design.md`, `features.md`

### 7. Dependencies
- ✅ Every new package added
- ✅ Version updates with breaking changes
- **Update**: Main `copilot-instructions.md` (Critical Dependencies)

## Documentation Standards

### Required Elements

Each documentation update MUST include:

1. **Date**: ISO 8601 format (YYYY-MM-DD) at top of file
2. **What Changed**: Clear description of the change
3. **Why**: Rationale for the decision
4. **How**: Implementation details with code examples if relevant
5. **Impact**: What files/systems are affected
6. **Related Files**: List with paths
7. **Dependencies**: New packages or version requirements
8. **Best Practices**: Patterns to follow when working with this code
9. **Warnings**: Common pitfalls or gotchas

### Documentation Locations

- **Quick Reference**: Main `copilot-instructions.md` (at repository root `.github/`)
- **Detailed Specs**: Individual files in `.github/copilot-instructions/`
- **Status Tracking**: `progress.md` for what's done/next
- **System Architecture**: Dedicated files for complex systems

## Process Checklist

Before completing ANY task:

- [ ] Code written and tested
- [ ] Relevant documentation files identified
- [ ] Documentation updated with all required elements
- [ ] `progress.md` updated (if applicable)
- [ ] Version numbers incremented (if database changed)
- [ ] Cross-references updated in related docs

## Examples of Good Documentation

### Example 1: Adding a Feature
```
✅ Updated `features.md`:
   - Added section for "Database Backup & Restore"
   - Documented export/import flows
   
✅ Created `database-backup.md`:
   - Complete implementation guide
   - Error handling patterns
   - User experience flows
   
✅ Updated `progress.md`:
   - Added to completed features
   - Updated current status
   
✅ Updated `data-model.md`:
   - Noted backup strategy
```

### Example 2: Database Schema Change
```
✅ Updated main `copilot-instructions.md`:
   - Incremented version: 3 → 4
   - Added v4 to version history
   - Documented new column in schema section
   
✅ Updated `data-model.md`:
   - Added new field to entity definition
   - Explained purpose and behavior
   
✅ Updated `progress.md`:
   - Added to recent updates section
```

## Anti-Patterns (NEVER DO THIS)

❌ "I'll document it later" - NO. Document NOW.
❌ "The code is self-documenting" - Not enough. Write docs.
❌ "It's a small change" - Size doesn't matter. Document it.
❌ "I forgot to document" - Go back and document it before moving on.
❌ "Documentation can wait until feature is complete" - Document as you go.

## Why This Matters

1. **Context Preservation**: Future you (or Copilot) needs to understand why decisions were made
2. **Consistency**: Ensures all team members follow same patterns
3. **Onboarding**: New contributors can understand the system quickly
4. **Debugging**: Documentation reveals intent when code behavior is unclear
5. **Maintenance**: Reduces cognitive load when making changes months later

## Enforcement

This is not a suggestion. This is a **REQUIREMENT**.

Every code commit should have corresponding documentation updates. If documentation is missing, the work is considered **incomplete**.

## Quick Documentation Template

```markdown
# [Feature/System Name]

**Date**: YYYY-MM-DD

## Overview
[What is this and why does it exist?]

## Implementation
[How does it work?]

## Files Affected
- path/to/file1.dart
- path/to/file2.dart

## Dependencies
- package_name: ^version

## Usage
[Code examples showing how to use this]

## Best Practices
[Patterns to follow]

## Common Pitfalls
[Things to watch out for]

## Future Enhancements
[Ideas for improvement]
```

---

**Remember**: Documentation is not overhead. It's an essential part of the development process.

**Document everything. Document immediately. Document completely.**
