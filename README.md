# VSCode Bridge for Neovim

![CI Status](https://github.com/amurf/vscode-bridge/actions/workflows/test.yml/badge.svg)

**vscode-bridge** is a lightweight Neovim plugin written in Lua that seamlessly bridges Visual Studio Code configurations to your Neovim environment. It automatically detects and applies settings from `.vscode/settings.json` in your project root, ensuring a consistent coding experience across editors.

## Features

- **Automatic Configuration Loading**: Detects `.vscode/settings.json` in the current working directory.
- **Live Reloading**: Automatically reloads settings when `.vscode/settings.json` changes or when switching directories.
- **Language Specific Settings**: Supports `"[language]"` blocks to apply settings only for specific file types.
- **Extension Recommendations**: Checks `.vscode/extensions.json` and notifies about recommended extensions.
- **JSONC Support**: Capable of parsing JSON with comments (Standard in VSCode configs).
- **Supported Settings**:
  - **Indentation**: `editor.tabSize`, `editor.insertSpaces`.
  - **Formatting**: `editor.formatOnSave`.
  - **UI**: `editor.rulers`, `editor.wordWrap`, `editor.lineNumbers`.
  - **Files**: `files.exclude`, `files.encoding`, `files.eol`, `files.trimTrailingWhitespace`, `files.insertFinalNewline`.

## Installation

Install using your favorite package manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "amurf/vscode-bridge", -- Replace with actual repo path
  opts = {},
  config = function()
    require("vscode-bridge").setup()
  end
}
```

### Manual

Add the plugin to your runtime path and require it in your `init.lua`:

```lua
local bridge = require("vscode-bridge")
bridge.setup()
```

## Usage

Once installed, **VSCode Bridge** works automatically. When you open Neovim in a directory with a `.vscode/settings.json` file, it will apply the relevant settings.

### Commands

- `:VSCodeSettings` - displays the current status of loaded settings and their mapping to Neovim options.

## Configuration Mapping

The plugin currently supports the following standard VSCode settings:

| VSCode Setting | Neovim Option | Notes |
| :--- | :--- | :--- |
| `editor.tabSize` | `tabstop`, `shiftwidth` | Sets both values to match VSCode. |
| `editor.insertSpaces` | `expandtab` | `true` sets expandtab, `false` clears it. |
| `editor.rulers` | `colorcolumn` | Supports array of column numbers. |
| `editor.wordWrap` | `wrap` | `on`/`off` maps to `true`/`false`. |
| `editor.lineNumbers` | `number`, `relativenumber` | Supports `on` (number), `off`, `relative` (hybrid). |
| `editor.formatOnSave` | `autocmd BufWritePre` | Triggers `vim.lsp.buf.format()` on save. |
| `files.exclude` | `wildignore` | Appends patterns to Neovim's ignore list. |
| `files.encoding` | `fileencoding` | `utf8`, `iso88591`, `windows1252`. |
| `files.eol` | `fileformat` | `\n` (unix), `\r\n` (dos). |
| `files.trimTrailingWhitespace` | `autocmd BufWritePre` | Trims trailing whitespace on save. |
| `files.insertFinalNewline` | `fixendofline` | |

## Language Specific Settings

The plugin supports language-scoped settings. For example:

```json
"[python]": {
    "editor.tabSize": 4,
    "editor.formatOnSave": true
}
```

These settings are applied using `FileType` autocommands when you enter a buffer of that language.

## Extension Recommendations

If `.vscode/extensions.json` is present, the plugin will load it and notify you of the recommended extensions for the project.

## Development

Runs the test suite using `tests/run_tests.lua`.

```bash
nvim -l tests/run_tests.lua
```

## License

MIT
