# Future Feature Enhancements for vscode-vim

Based on the investigation of the current codebase (v0.1), here are the recommended enhancements to bring the plugin closer to a full "VSCode-in-Neovim" experience.

## 1. Language-Specific Settings Support (Implemented)
**Current State**: Implemented via `mapper.lua`. Supports parsing `"[language]"` blocks and applying buffer-local settings using FileType autocommands.

**Proposal**:
- Parse `"[language]"` blocks.
- Create FileType autocommands to apply these settings only when entering a buffer of that type.
- Revert global settings when leaving? (Or just rely on buffer-local options which Neovim handles well).

**Complexity**: Medium.
**Value**: High. Essential for polyglot repositories (e.g. 2 spaces for JS, 4 for Python).

## 2. Extensions Recommendations
**Current State**: `mapper.lua` contains a `check_extensions` function that is currently dead code. `extensions.json` is never loaded.

**Proposal**:
- Update `init.lua` to look for `.vscode/extensions.json`.
- Parse recommendations array.
- Warn or Notify the user if recommended extensions are missing (or just list them).

**Complexity**: Low.
**Value**: Medium. Helpful for project onboarding.

## 3. Task Runner Integration (tasks.json)
**Current State**: Zero support.

**Proposal**:
- Parse `.vscode/tasks.json`.
- Create a `:VSCodeTasks` command to list and run tasks.
- Execute shell commands using `vim.fn.jobstart` or `vim.cmd("term ...")`.

**Complexity**: High. Requires shell handling, output capturing, and potentially problem matchers.
**Value**: High. Tasks are a core part of VSCode workflows.

## 4. Launch Configurations (launch.json)
**Current State**: Zero support.

**Proposal**:
- Parse `.vscode/launch.json`.
- Convert configurations into nvim-dap formats.
- Requires nvim-dap as a dependency.

**Complexity**: Very High. Requires deep knowledge of DAP adapters.
**Value**: High for power users.

## 5. Robustness & Globs
**Current State**:
- JSON comment stripping uses regex (fragile).
- Glob conversion (files.exclude -> wildignore) is simplistic.

**Proposal**:
- Improve `strip_comments` (maybe a proper lexer state machine as noted in TODOs).
- Implement a proper Glob-to-Vim-Wildcard converter.

**Complexity**: Medium.
**Value**: Medium. Reliability fix.
