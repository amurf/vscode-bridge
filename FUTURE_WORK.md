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
**Status**: De-scoped / Deferred.

**Reason**: High complexity (shell handling, output capturing, probem matchers). Currently out of scope for the lightweight nature of this plugin.

## 4. Launch Configurations (launch.json)
**Status**: De-scoped / Deferred.

**Reason**: Very High complexity. Requires deep integration with `nvim-dap` adapters and converting complex JSON configurations.

## 5. Robustness & Globs
**Current State**:
- JSON comment stripping uses regex (fragile).
- Glob conversion (files.exclude -> wildignore) is simplistic.

**Proposal**:
- Improve `strip_comments` (maybe a proper lexer state machine as noted in TODOs).
- Implement a proper Glob-to-Vim-Wildcard converter.

**Complexity**: Medium.
**Value**: Medium. Reliability fix.

## 6. Live Configuration Reload
**Current State**: Only reloads on `DirChanged`. Editing `settings.json` directly requires a manual `:e` or restart to pick up changes.

**Proposal**:
- Use `vim.uv.new_fs_event` (or `vim.loop`) to watch the `.vscode/settings.json` file.
- Auto-trigger `load_config` on file write.

**Complexity**: Low/Medium.
**Value**: High. Greatly improves the feedback loop when tweaking settings.

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
