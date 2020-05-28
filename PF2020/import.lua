function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

print(arg[1])
local file = arg[1]
local lines = lines_from(file)

local life = tonumber(lines[1])
local grid = {}
local i = 1

for k=2, #lines do
  grid[k-1] = {}
  for c in lines[k]:gmatch"." do
    grid[k-1][i] = c
    i = i + 1
  end
  i = 1
end

_G.grid = grid
_G.life = life