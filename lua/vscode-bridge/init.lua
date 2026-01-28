local parser = require("vscode-bridge.parser")
local mapper = require("vscode-bridge.mapper")

local M = {}
M.config_watcher = nil
M.last_notifications = {}

local function stop_watcher()
  if M.config_watcher then
    M.config_watcher:stop()
    if not M.config_watcher:is_closing() then
      M.config_watcher:close()
    end
    M.config_watcher = nil
  end
end

local function start_watcher(vscode_dir)
  stop_watcher()
  
  local uv = vim.uv or vim.loop
  local watcher = uv.new_fs_event()
  if not watcher then return end
  
  -- Watch the .vscode directory
  -- We watch the directory to detect if settings.json is created/deleted/modified
  -- Watching the file explicitly fails if it doesn't exist yet.
  watcher:start(vscode_dir, {}, vim.schedule_wrap(function(err, filename, events)
    if err then return end
    if filename == "settings.json" or filename == "extensions.json" then
      M.load_config()
    end
  end))
  
  M.config_watcher = watcher
end

function M.load_config()
  -- Find .vscode root
  local cwd = vim.fn.getcwd()
  local vscode_dir = cwd .. "/.vscode"
  
  -- Setup watcher
  if vim.fn.isdirectory(vscode_dir) == 1 then
     start_watcher(vscode_dir)
  else
     stop_watcher()
  end
  
  -- Load settings.json
  local settings = parser.read_json_file(vscode_dir .. "/settings.json")
  M.current_settings = settings
  
  -- Reset defaults? technically we should, but for V1 we just overwrite if new settings exist.
  -- If we switch to a project WITHOUT settings, we might want to warn or clear?
  -- For now, just apply what we find.
  
  if settings then
    mapper.apply_settings(settings)
  end

  -- Load extensions.json
  local extensions = parser.read_json_file(vscode_dir .. "/extensions.json")
  if extensions and extensions.recommendations then
    local recommendations = extensions.recommendations
    table.sort(recommendations)
    local key = table.concat(recommendations, ",")
    
    if M.last_notifications[vscode_dir] ~= key then
      mapper.check_extensions(recommendations)
      M.last_notifications[vscode_dir] = key
    end
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
  
  -- Cleanup on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      stop_watcher()
    end
  })
  
  vim.api.nvim_create_user_command("VSCodeSettings", M.show_status, {})
end
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

return M
