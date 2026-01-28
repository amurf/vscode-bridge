local M = {}

function M.apply_settings(settings)
  if not settings then return end

  -- Indentation
  if settings["editor.tabSize"] then
    vim.opt.tabstop = settings["editor.tabSize"]
    vim.opt.shiftwidth = settings["editor.tabSize"]
  end

  if settings["editor.insertSpaces"] ~= nil then
    vim.opt.expandtab = settings["editor.insertSpaces"]
  end

  -- UI
  if settings["editor.rulers"] then
    -- Validating it's a list
    if type(settings["editor.rulers"]) == "table" then
      -- vim.opt.colorcolumn expects string "80,100" or list of numbers
      -- for local setting we often pass string, but let's try mapping list directly if supported or join
      vim.opt.colorcolumn = settings["editor.rulers"] 
    end
  end

  -- Exclusions
  if settings["files.exclude"] then
    local wildignore = vim.opt.wildignore:get()
    for pattern, excluded in pairs(settings["files.exclude"]) do
      if excluded then
        -- VSCode glob conversion to Vim wildcard is complex
        -- For V1, simple cleanups:
        -- **/node_modules -> **/node_modules/* or similar?
        -- Vim wildignore usually just needs the name or path
        -- Let's just append verbatim and see what sticks for common cases
        table.insert(wildignore, pattern)
      end
    end
    vim.opt.wildignore = wildignore
  end

  -- Format on Save
  if settings["editor.formatOnSave"] then
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function()
        vim.lsp.buf.format()
      end,
      group = vim.api.nvim_create_augroup("VSCodeBridgeFormat", { clear = true })
    })
  end
end

function M.check_extensions(recommendations)
  if not recommendations then return end
  
  -- Simple notification for now
  local msg = "VSCode Recommended Extensions:\n"
  for _, ext in ipairs(recommendations) do
    msg = msg .. "- " .. ext .. "\n"
  end
  
  -- Only notify if explicit demand? Or just informational
  -- vim.notify(msg, vim.log.levels.INFO)
end

return M
