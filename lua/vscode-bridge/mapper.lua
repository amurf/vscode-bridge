local M = {}

-- Helper to apply settings to a specific scope (global or local)
local function apply_core_settings(settings, opts)
  -- Indentation
  if settings["editor.tabSize"] then
    opts.tabstop = settings["editor.tabSize"]
    opts.shiftwidth = settings["editor.tabSize"]
  end

  if settings["editor.insertSpaces"] ~= nil then
    opts.expandtab = settings["editor.insertSpaces"]
  end

  -- UI
  if settings["editor.rulers"] then
    if type(settings["editor.rulers"]) == "table" then
      opts.colorcolumn = settings["editor.rulers"]
    end
  end
  
  -- Note: wildignore is global only, so we handle it separately or only in global context
end

local function glob_to_wildcard(pattern)
  -- Remove trailing slash (VSCode handles "dist/" as "dist")
  -- Vim wildignore "dist" handles "dist" file or "dist" dir
  if pattern:sub(-1) == "/" then
    pattern = pattern:sub(1, -2)
  end
  
  -- Handle ** (VSCode recursive) -> Vim handles ** mostly same way
  -- No change needed for ** usually, but let's ensure it's valid.
  
  -- If pattern starts with /, remove it for relative consistency?
  -- VSCode "dist" means relative to root.
  
  return pattern
end

function M.apply_settings(settings)
  if not settings then return end

  -- 1. Apply Global Settings
  apply_core_settings(settings, vim.opt)

  -- Exclusions (Global only)
  if settings["files.exclude"] then
    local wildignore = vim.opt.wildignore:get()
    for pattern, excluded in pairs(settings["files.exclude"]) do
      if excluded then
        table.insert(wildignore, glob_to_wildcard(pattern))
      end
    end
    vim.opt.wildignore = wildignore
  end

  -- Format on Save (Global for now, usually configured at root)
  if settings["editor.formatOnSave"] then
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function()
        vim.lsp.buf.format()
      end,
      group = vim.api.nvim_create_augroup("VSCodeBridgeFormat", { clear = true })
    })
  end

  -- 2. Language Specific Settings
  local group = vim.api.nvim_create_augroup("VSCodeBridgeLanguage", { clear = true })
  
  for key, value in pairs(settings) do
    local lang = key:match("^%[(.*)%]$")
    if lang and type(value) == "table" then
      -- VSCode language IDs differ slightly from Vim filetypes
      -- e.g. "javascript" -> "javascript", "python" -> "python"
      -- We assume direct mapping for now.
      
      vim.api.nvim_create_autocmd("FileType", {
        pattern = lang,
        group = group,
        callback = function()
          -- Apply to buffer local options
          apply_core_settings(value, vim.opt_local)
        end
      })
    end
  end
end

function M.check_extensions(recommendations)
  if not recommendations then return end
  
  -- Simple notification for now
  local msg = "VSCode Recommended Extensions:\n"
  for _, ext in ipairs(recommendations) do
    msg = msg .. "- " .. ext .. "\n"
  end
  
  vim.notify(msg, vim.log.levels.INFO)
end

return M
