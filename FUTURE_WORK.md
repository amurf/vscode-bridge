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
**Current State**: Implemented. The plugin checks `.vscode/extensions.json` and uses `vim.notify` to list recommendations. It tracks notifications to avoid spam.

**Proposal**:
- (Done) Update `init.lua` to look for `.vscode/extensions.json`.
- (Done) Parse recommendations array.
- (Done) Notify the user.


## 3. Task Runner Integration (tasks.json)
**Status**: De-scoped / Deferred.

**Reason**: High complexity (shell handling, output capturing, probem matchers). Currently out of scope for the lightweight nature of this plugin.

## 4. Launch Configurations (launch.json)
**Status**: De-scoped / Deferred.

**Reason**: Very High complexity. Requires deep integration with `nvim-dap` adapters and converting complex JSON configurations.

## 5. Robustness & Globs
**Current State**:
- JSON parser uses a custom state machine to strip comments and trailing commas (Robust).
- Glob conversion (files.exclude -> wildignore) is basic but functional.

**Proposal**:
- (Done) Improve `strip_comments`.
- (Ongoing) Enhance Glob-to-Vim-Wildcard converter for complex patterns.

**Complexity**: Medium.
**Value**: Medium. Reliability fix.

## 6. Live Configuration Reload
**Current State**: Implemented. Uses `vim.uv.new_fs_event` to watch `.vscode` directory and reloads on changes.

**Proposal**:
- (Done) Use `vim.uv.new_fs_event`.
- (Done) Auto-trigger `load_config` on file write.


## 7. VSCode Snippets Support
**Current State**: Zero support.

**Proposal**:
- Parse `.vscode/*.code-snippets` files.
- Convert them to `LuaSnip` or native Neovim snippets (v0.10+).

**Complexity**: Medium.
**Value**: High. Many teams share project-specific snippets.

## 8. Formatter Control
**Current State**: blindly calls `vim.lsp.buf.format()` if `editor.formatOnSave` is true.

**Proposal**:
- Respect `editor.defaultFormatter` if possible (map to specific LSP client?).
- Check if an LSP is actually attached before formatting to avoid errors.

**Complexity**: Low.
**Value**: Medium. Avoids errors in non-LSP buffers.
