local parser = require("vscode-bridge.parser")
local mapper = require("vscode-bridge.mapper")

local M = {}
M.current_settings = nil

function M.show_status()
  local settings = M.current_settings
  if not settings then
    print("VSCode Bridge: No settings loaded.")
    return
  end

  print("=== VSCode Bridge Status ===")
  print("VSCode Settings Found: Yes")
  
  -- Tab Size
  local tabSize = settings["editor.tabSize"] or "N/A"
  print(string.format("editor.tabSize: %s | vim.opt.tabstop: %d", tabSize, vim.opt.tabstop:get()))
  
  -- Insert Spaces
  local insertSpaces = tostring(settings["editor.insertSpaces"])
  print(string.format("editor.insertSpaces: %s | vim.opt.expandtab: %s", insertSpaces, tostring(vim.opt.expandtab:get())))
  print("=============================")
end

function M.load_config()
  -- Find .vscode root
  local cwd = vim.fn.getcwd()
  local vscode_dir = cwd .. "/.vscode"
  
  -- Load settings.json
  local settings = parser.read_json_file(vscode_dir .. "/settings.json")
  M.current_settings = settings
  
  -- Reset defaults? technically we should, but for V1 we just overwrite if new settings exist.
  -- If we switch to a project WITHOUT settings, we might want to warn or clear?
  -- For now, just apply what we find.
  
  if settings then
    mapper.apply_settings(settings)
    vim.notify("VSCode settings loaded for " .. cwd, vim.log.levels.INFO)
  end

  -- Load extensions.json
  local extensions = parser.read_json_file(vscode_dir .. "/extensions.json")
  if extensions and extensions.recommendations then
    mapper.check_extensions(extensions.recommendations)
  end
end

function M.setup(opts)
  -- Initial load
  M.load_config()
  
  -- Auto-reload on directory change
  vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "*",
    callback = function()
      M.load_config()
    end,
    group = vim.api.nvim_create_augroup("VSCodeBridgeDirChange", { clear = true })
  })
  
  vim.api.nvim_create_user_command("VSCodeSettings", M.show_status, {})
end

return M
