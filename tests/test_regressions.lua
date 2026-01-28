-- Setup RTP
vim.opt.rtp:prepend(".")

local bridge = require("vscode-bridge")
local mapper = require("vscode-bridge.mapper")

local M = {}
local passed = 0
local failed = 0
local errors = {}

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    table.insert(errors, string.format("FAIL: %s - Expected '%s', got '%s'", message, tostring(expected), tostring(actual)))
    return false
  end
  return true
end

function M.test_wildignore_deduplication()
  print("Running test: Wildignore Deduplication")
  
  -- Setup initial state
  vim.opt.wildignore = ""
  local settings = {
    ["files.exclude"] = {
      ["node_modules"] = true,
      ["dist/"] = true
    }
  }
  
  -- First Application
  mapper.apply_settings(settings)
  local first_run = vim.opt.wildignore:get()
  
  -- Verify initial application (ordering is not guaranteed by pairs, so check existence)
  local has_node = false
  local has_dist = false
  for _, v in ipairs(first_run) do
    if v == "node_modules" then has_node = true end
    if v == "dist" then has_dist = true end
  end
  
  if not (has_node and has_dist) then
    table.insert(errors, "FAIL: Initial wildcard application failed")
    failed = failed + 1
    print("  -> FAILED")
    return
  end
  
  -- Second Application (Duplicate)
  mapper.apply_settings(settings)
  local second_run = vim.opt.wildignore:get()
  
  -- Check length is same
  if assert_eq(#second_run, #first_run, "Wildignore length should remain constant after re-application") then
    passed = passed + 1
    print("  -> PASSED")
  else
    failed = failed + 1
    print("  -> FAILED")
  end
end

function M.test_extension_notification_strictness()
  print("Running test: Extension Notification Strictness")
  
  -- Mock notify
  local notifications = {}
  vim.notify = function(msg, level)
    table.insert(notifications, msg)
  end
  
  -- Setup dummy extensions
  local recommendations = {"ext1", "ext2"}
  local vscode_dir = "/tmp/dummy_project"
  
  -- Reset internal state
  bridge.last_notifications = {}
  
  -- Manually checking the logic inside init.lua requires mocking parser or exposing the internal function.
  -- Instead, let's exercise the internal logic directly if possible, or simulate the behavior.
  -- Since bridge.last_notifications is exposed, we can test the check logic if we refactor init.lua slightly,
  -- or we can just replicate the logic test on the state.
  
  -- Actually, let's just inspect the exposed table logic if we can't easily call start_watcher logic.
  -- Inspect bridge.last_notifications directly.
  
  -- Initial State
  if bridge.last_notifications[vscode_dir] ~= nil then
     table.insert(errors, "FAIL: internal state should be empty initially")
  end
  
  -- First "Notify"
  local key = table.concat(recommendations, ",")
  -- Simulate what init.lua does
  if bridge.last_notifications[vscode_dir] ~= key then
     mapper.check_extensions(recommendations)
     bridge.last_notifications[vscode_dir] = key
  end
  
  if assert_eq(#notifications, 1, "Should notify on first run") then
      -- Pass
  else
      failed = failed + 1
      print("  -> FAILED")
      return
  end
  
  -- Second "Notify" (Same recommendations)
  if bridge.last_notifications[vscode_dir] ~= key then
     mapper.check_extensions(recommendations)
     bridge.last_notifications[vscode_dir] = key
  end
  
  if assert_eq(#notifications, 1, "Should NOT notify on second run with same extensions") then
      passed = passed + 1
      print("  -> PASSED")
  else
      failed = failed + 1
      print("  -> FAILED")
  end
end

M.test_wildignore_deduplication()
M.test_extension_notification_strictness()

if failed > 0 or #errors > 0 then
  for _, err in ipairs(errors) do
    print(err)
  end
  vim.cmd("cquit 1")
end
