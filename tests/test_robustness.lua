
print("Starting VSCode Bridge Robustness Tests...")

-- Add project root to runtime path
vim.opt.rtp:prepend(".")

local parser = require("lua.vscode-bridge.parser")
local mapper = require("lua.vscode-bridge.mapper")

local passed = 0
local failed = 0
local errors = {}

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    table.insert(errors, string.format("FAIL: %s\n  Expected: '%s'\n  Got:      '%s'", message, tostring(expected), tostring(actual)))
    return false
  end
  return true
end

local function run_test(name, fn)
  print("Running test: " .. name)
  local status, err = pcall(fn)
  if status then
    if err ~= false then
        passed = passed + 1
        print("  -> PASSED")
    else
        failed = failed + 1
        print("  -> FAILED")
    end
  else
    failed = failed + 1
    print("  -> CRASHED: " .. tostring(err))
    table.insert(errors, "CRASH in " .. name .. ": " .. tostring(err))
  end
end

-- =============================================================================
-- TEST: Parser Robustness (JSON Comment Stripping)
-- =============================================================================

run_test("strip_comments_basic_comments", function()
  -- Write temp file.
  local tmp_file = "check_strip.json"
  local content = [[
  {
    "key": "value", // This is a comment
    "another": 123 /* This is a block comment */
  }
  ]]
  local f = io.open(tmp_file, "w")
  f:write(content)
  f:close()
  
  local data = parser.read_json_file(tmp_file)
  os.remove(tmp_file)
  
  if not data then return false end
  return assert_eq(data.key, "value", "key matches") and assert_eq(data.another, 123, "val matches")
end)

run_test("strip_comments_in_strings", function()
  -- This is the critical test case that currently fails with regex approach
  local tmp_file = "check_strings.json"
  local content = [[
  {
    "url": "http://example.com",
    "path": "folder//file",
    "glob": "**/*.js",
    "escaped": "End quote \" // not a comment"
  }
  ]]
  -- Regex replacer might accidentally strip //example.com
  
  local f = io.open(tmp_file, "w")
  f:write(content)
  f:close()
  
  local data = parser.read_json_file(tmp_file)
  os.remove(tmp_file)
  
  if not data then 
      table.insert(errors, "Failed to parse JSON string content")
      return false 
  end
  
  local res = true
  res = assert_eq(data.url, "http://example.com", "url preserved") and res
  res = assert_eq(data.path, "folder//file", "double slash path preserved") and res
  res = assert_eq(data.escaped, "End quote \" // not a comment", "escaped quote preserved") and res
  return res
end)


run_test("strip_trailing_comma_in_strings", function()
  -- Test that trailing comma logic doesn't eat commas inside strings
  local tmp_file = "check_comma_string.json"
  -- {"key": "value,}"} -> should remain valid and have comma
  local content = [[
  {
    "key": "value,}"
  }
  ]]
  local f = io.open(tmp_file, "w")
  f:write(content)
  f:close()
  
  local data = parser.read_json_file(tmp_file)
  os.remove(tmp_file)
  
  if not data then 
      table.insert(errors, "Failed to parse JSON with comma in string")
      return false 
  end
  
  return assert_eq(data.key, "value,}", "Comma inside string preserved")
end)

-- =============================================================================
-- TEST: Glob to Wildcard Conversion
-- =============================================================================

-- mapper.glob_to_wildcard is not exported yet. We will verify via mapper.apply_settings for files.exclude.

run_test("glob_conversion_wildignore", function()
  -- Reset wildignore
  vim.opt.wildignore = ""
  
  local settings = {
    ["files.exclude"] = {
      ["node_modules/"] = true,
      ["dist"] = true,
      ["**/*.log"] = true,
      ["src/temp"] = false -- should not be added
    }
  }
  
  mapper.apply_settings(settings)
  
  local ignorlist = vim.opt.wildignore:get()
  
  -- Logic check
  local function list_contains(list, val)
    for _, v in ipairs(list) do
      if v == val then return true end
    end
    return false
  end
  
  local res = true
  -- We expect "node_modules" (stripped trailing slash) or existing behavior
  -- We expect "**/*.log"
  -- We expect "dist"
  
  res = assert_eq(list_contains(ignorlist, "node_modules"), true, "node_modules added") and res
  res = assert_eq(list_contains(ignorlist, "dist"), true, "dist added") and res
  res = assert_eq(list_contains(ignorlist, "**/*.log"), true, "globs added") and res
  res = assert_eq(list_contains(ignorlist, "src/temp"), false, "false exclusion ignored") and res
  
  return res
end)


-- SUMMARY
print("====================================")
print(string.format("Robustness Tests Completed: %d Passed, %d Failed", passed, failed))
if #errors > 0 then
  print("Errors:")
  for _, err in ipairs(errors) do
    print(err)
  end
  vim.cmd("cquit 1")
else
  vim.cmd("quit")
end
