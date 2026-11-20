---
inclusion: always
name: code-quality-and-standards
description: Strict, less-code, token-efficient, safe, and up-to-date development guidelines
---

# Development Principles & Code Standards

## 1. Up-to-Date Documentation First (Anti-Hallucination)
- **Always query Context7 MCP** for library/package documentation before using newer APIs, upgrading dependencies, or fixing deprecated methods.
- Never invent API methods or rely on outdated memory for external SDKs (Firebase, Flutter packages, Next.js, FastAPI, Prisma, etc.).

## 2. Less Code & Minimal Boilerplate (YAGNI)
- **You Aren't Gonna Need It**: Write the simplest idiomatic solution that fulfills the requirement. Do NOT create speculative abstractions, excessive wrapper classes, or premature design patterns.
- **Diff-Based Modifications**: Never rewrite an entire file if only modifying a few lines or a single function. Make surgical, targeted edits.
- **Utilize Standard Libraries**: Favor built-in language/framework features over introducing new dependencies or redundant custom utility functions.

## 3. Strict Coding Standards & Zero Fluff
- **Zero Unwanted Comments**: Do NOT inject conversational comments (e.g., `// changed by AI`, `// this function does XYZ`). Keep only critical business logic docstrings and existing developer comments.
- **Type Rigor**: Maintain strict typing (TypeScript `strict: true`, Python type annotations, Dart null safety). Avoid `any` or untyped `dynamic` traps.
- **Contract-First**: Define clean schemas/interfaces before implementing logic.

## 4. Verification Gates (Before Completing Tasks)
Never consider a turn or task done without running static verification via RTK:
- **TypeScript / Node**: `rtk tsc --noEmit` & `rtk lint` (or test runner)
- **Flutter / Dart**: `rtk dart analyze`
- **Python**: `rtk ruff check` / `rtk mypy` / `rtk pytest`
Ensure 0 unresolved errors or warnings before reporting back to the user.

## 5. Token Efficiency & Safety
- **RTK Enforcement**: Always prefix terminal commands with `rtk` (e.g., `rtk git status`, `rtk pytest`).
- **Selective Reading**: Use `grep` or read specific line ranges rather than loading entire large files into context.
- **Safe State Changes**: Never execute destructive commands (`rm -rf`, `git reset --hard`) without explicit confirmation.
