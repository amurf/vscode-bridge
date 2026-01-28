local M = {}

-- Helper to remove comments from JSONC (simplified)
-- Removes // style comments and /* */ block comments
local function strip_comments(str)
  local result = {}
  local len = #str
  local i = 1
  local in_string = false
  local check_escape = false
  
  while i <= len do
    local char = str:sub(i, i)
    local next_char = str:sub(i+1, i+1)
    
    if in_string then
      table.insert(result, char)
      if check_escape then
        check_escape = false -- Escaped character processed
      elseif char == "\\" then
        check_escape = true
      elseif char == '"' then
        in_string = false
      end
      i = i + 1
    else
      if char == '"' then
        in_string = true
        table.insert(result, char)
        i = i + 1
      elseif char == "/" then
        if next_char == "/" then
          -- Single line comment: skip until newline
          i = i + 2
          while i <= len and str:sub(i, i) ~= "\n" do
            i = i + 1
          end
          -- Keep the newline mainly for line numbering, but JSON doesn't care
          -- actually standard JSON shouldn't have newlines in random places, 
          -- but leaving the newline helps preserve line counts if we care.
        elseif next_char == "*" then
          -- Block comment: skip until */
          i = i + 2
          while i <= len - 1 do
            if str:sub(i, i) == "*" and str:sub(i+1, i+1) == "/" then
              i = i + 2 -- Skip closing */
              break
            end
            i = i + 1
          end
        else
          table.insert(result, char)
          i = i + 1
        end
      else
        table.insert(result, char)
        i = i + 1
      end
    end
  end
  
  local clean = table.concat(result)
  
  -- Remove trailing commas before } or ]
  clean = clean:gsub(",(%s*[}%]])", "%1")
  
  return clean
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
