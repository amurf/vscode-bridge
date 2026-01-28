# VSCode Bridge for Neovim

**vscode-bridge** is a lightweight Neovim plugin written in Lua that seamlessly bridges Visual Studio Code configurations to your Neovim environment. It automatically detects and applies settings from `.vscode/settings.json` in your project root, ensuring a consistent coding experience across editors.

## Features

- **Automatic Configuration Loading**: Detects `.vscode/settings.json` in the current working directory.
- **Dynamic Reloading**: Automatically reloads settings when you change directories.
- **JSONC Support**: Capable of parsing JSON with comments (Standard in VSCode configs).
- **Supported Settings**:
  - **Indentation**: Maps `editor.tabSize` and `editor.insertSpaces` to Neovim's `tabstop`/`shiftwidth` and `expandtab`.
  - **Formatting**: Enables `formatOnSave` by hooking into `BufWritePre`.
  - **UI**: Maps `editor.rulers` to `colorcolumn`.
  - **File Exclusion**: Adds `files.exclude` patterns to `wildignore`.

## Installation

Install using your favorite package manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/vscode-bridge", -- Replace with actual repo path
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
| `editor.formatOnSave` | `autocmd BufWritePre` | Triggers `vim.lsp.buf.format()` on save. |
| `files.exclude` | `wildignore` | Appends patterns to Neovim's ignore list. |

## Development

Runs the test suite using `tests/run_tests.lua`.

```bash
nvim -l tests/run_tests.lua
```

## License

MIT
