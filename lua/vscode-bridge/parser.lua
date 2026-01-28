local M = {}

-- Helper to remove comments from JSONC (simplified)
-- Removes // style comments and /* */ block comments
local function strip_comments(str)
  local result = {}
  local len = #str
  local i = 1
  local in_string = false
  local check_escape = false
  local pending_comma = false
  local pending_whitespace = {} -- To preserve whitespace after a comma until we decide

  -- Helper to flush pending comma and whitespace
  local function flush_pending()
    if pending_comma then
      table.insert(result, ",")
      pending_comma = false
    end
    for _, ws in ipairs(pending_whitespace) do
      table.insert(result, ws)
    end
    pending_whitespace = {}
  end

  while i <= len do
    local char = str:sub(i, i)
    local next_char = str:sub(i+1, i+1)
    
    if in_string then
      table.insert(result, char)
      
      if check_escape then
        check_escape = false
      elseif char == "\\" then
        check_escape = true
      elseif char == '"' then
        in_string = false
      end
      i = i + 1
    else
      -- NOT in string
      
      -- 1. Handle Comments first
      if char == "/" and next_char == "/" then
         -- Single line comment
         i = i + 2
         while i <= len and str:sub(i, i) ~= "\n" do
           i = i + 1
         end
         -- Now we are at newline (or end). 
         
      elseif char == "/" and next_char == "*" then
        -- Block comment
        i = i + 2
        while i <= len - 1 do
          if str:sub(i, i) == "*" and str:sub(i+1, i+1) == "/" then
            i = i + 2
            break
          end
          i = i + 1
        end
        -- Treated effectively as whitespace
        
      elseif char == '"' then
        -- Start of string
        flush_pending() -- Previous comma was valid
        in_string = true
        table.insert(result, char)
        i = i + 1

      elseif char == "," then
        -- Found a comma. Mark it pending.
        flush_pending()
        pending_comma = true
        i = i + 1

      elseif char:match("%s") then
        -- Whitespace
        if pending_comma then
          table.insert(pending_whitespace, char)
        else
          table.insert(result, char)
        end
        i = i + 1

      elseif char == "}" or char == "]" then
        -- Closing brace/bracket
        -- Discard pending comma!
        pending_comma = false
        
        -- Flush pending whitespace (it's safe to keep whitespace before closing brace)
        for _, ws in ipairs(pending_whitespace) do
          table.insert(result, ws)
        end
        pending_whitespace = {}
        
        table.insert(result, char)
        i = i + 1

      else
        -- Any other character (e.g. numbers, booleans, null, or key start)
        flush_pending()
        table.insert(result, char)
        i = i + 1
      end
    end
  end
  
  return table.concat(result)
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
