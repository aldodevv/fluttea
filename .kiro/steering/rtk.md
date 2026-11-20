---
inclusion: always
name: rtk-token-killer
description: Rules for using RTK (Rust Token Killer) to minimize token consumption when executing shell commands
---

# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy for all terminal and shell commands.

## Mandatory Rule for Tool Execution
Whenever you execute shell or bash commands via `execute_bash` or any terminal tool, **ALWAYS** prefix the command with `rtk` to minimize token consumption and compress terminal output.

RTK intercepts and intelligently compresses command output before it enters your context window, saving 60-90% of tokens on common operations.

## Command Reference & Examples

### Git Operations
- `rtk git status` (instead of `git status`)
- `rtk git diff` (instead of `git diff`)
- `rtk git log` (instead of `git log`)
- `rtk git show <commit>` (instead of `git show`)
- `rtk git branch -a` / `rtk git checkout <branch>`

### File & Directory Inspection
- `rtk ls` or `rtk ls -la` (instead of `ls` or `ls -la`)
- `rtk find <path> ...` (instead of `find ...`)
- `rtk grep <pattern> <path>` (instead of `grep ...`)
- `rtk read <file>` (filters boilerplate, whitespace, large chunks)

### Mobile & App Development (Flutter, Dart, Android, iOS)
- `rtk flutter test` (instead of `flutter test`)
- `rtk flutter pub get`
- `rtk flutter run ...`
- `rtk dart analyze`

### JavaScript / TypeScript & Package Managers
- `rtk npm run <script>` / `rtk npm test` / `rtk npm install`
- `rtk npx <cmd>` (e.g. `rtk npx vitest`, `rtk npx eslint`, `rtk npx tsc`)
- `rtk pnpm <cmd>`
- `rtk tsc` / `rtk lint` / `rtk vitest` / `rtk jest`

### Backend, Python, Rust, Go
- `rtk cargo test` / `rtk cargo check` / `rtk cargo build`
- `rtk pytest` / `rtk ruff` / `rtk mypy`
- `rtk go test` / `rtk golangci-lint`

### Other Common Tools
- `rtk docker ps` / `rtk docker logs`
- `rtk gh pr list` / `rtk gh issue list`
- `rtk curl <url>`

## Chained Commands
Always prepend `rtk` to each command in chains:
```bash
rtk git add . && rtk git commit -m "feat: updates"
```

## Meta & Debugging Commands
- `rtk gain`: Show token savings analytics and history
- `rtk gain --history`: Show history of commands with token savings
- `rtk proxy <command>`: Run raw command without filtering if exact uncompressed output is needed for debugging.
