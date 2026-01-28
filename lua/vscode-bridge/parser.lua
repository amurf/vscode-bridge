local M = {}

-- Helper to remove comments from JSONC (simplified)
-- Removes // style comments and /* */ block comments
local function strip_comments(str)
  -- Remove single line // comments (careful not to match inside strings?)
  -- This is a simple regex approach, might be fragile but good for V1.
  -- TODO: Proper state machine parser if complex cases fail.
  
  -- Remove block comments /* ... */
  str = str:gsub("/%*.-%*/", "")
  
  -- Remove single line comments // ...
  str = str:gsub("//[^\n]*", "")
  
  -- Remove trailing commas before } or ]
  -- This handles: { "a": 1, } -> { "a": 1 }
  str = str:gsub(",(%s*[}%]])", "%1")
  
  return str
end

function M.read_json_file(filepath)
  local file = io.open(filepath, "r")
  if not file then return nil end
  
  local content = file:read("*a")
  file:close()
  
  if not content or content == "" then return nil end
  
  local jsonc = strip_comments(content)
  local ok, data = pcall(vim.json.decode, jsonc)
  
  if not ok then
    vim.notify(data, vim.log.levels.WARN)
    return nil
  end
  
  return data
end

return M
