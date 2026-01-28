-- Add current directory to runtime path so we can require the plugin
vim.opt.rtp:prepend(".")

local bridge = require("lua.vscode-bridge.init")

-- Run setup
bridge.setup()

-- Assertions
local errors = {}

-- Check status command exists
vim.cmd("VSCodeSettings")

if vim.opt.tabstop:get() ~= 3 then
  table.insert(errors, "Expected tabstop 3, got " .. vim.opt.tabstop:get())
end

if vim.opt.shiftwidth:get() ~= 3 then
  table.insert(errors, "Expected shiftwidth 3, got " .. vim.opt.shiftwidth:get())
end

if vim.opt.expandtab:get() ~= false then
  table.insert(errors, "Expected expandtab false, got " .. tostring(vim.opt.expandtab:get()))
end

-- Check wildignore (rough check if pattern exists)
local wildignore = vim.opt.wildignore:get()
local found_node_modules = false
for _, p in ipairs(wildignore) do
  if p == "**/node_modules" then found_node_modules = true end
end
if not found_node_modules then
  table.insert(errors, "Expected wildignore to contain **/node_modules")
end

-- Check autocmd
local autocmds = vim.api.nvim_get_autocmds({ group = "VSCodeBridgeFormat", event = "BufWritePre" })
if #autocmds == 0 then
  table.insert(errors, "Expected BufWritePre autocmd for formatting")
end

if #errors > 0 then
  print("FAILED:")
  for _, e in ipairs(errors) do
    print("- " .. e)
  end
  vim.cmd("cquit 1")
else
  print("PASSED")
  vim.cmd("quit")
end
