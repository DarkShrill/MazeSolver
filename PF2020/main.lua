require("PF2020/import")

local grid = _G.grid
local var_dump = require("PF2020/var_dump")
local nodes = {}
local edges = {}
local startNode
local exitNode = {}
index = 1
edgesIndex = 1

function print_table(grid) 
  for i=1, #grid do
    for k=1, #grid[i] do
      io.write(grid[i][k])
    end
    io.write("\n")
  end
end

function CreateNode(x, y, value)
  local nd = NodeExistsXY(x,y)
  if(grid[x][y] ~= "m" and grid[x][y] ~= "p") then
    if(nd == -1) then 
      local node = {
        i = index,
        x = x,
        y = y,
        value = value,
      }
      
      if(grid[x][y] == "i") then
        startNode = node
      elseif(grid[x][y] == "u") then
        table.insert(exitNode, node)
      end

      nodes[index] = node
      index = index + 1
      return node
    else
      return nd
    end

  end
  return false
end

function CreateEdge(i1, i2)
  if(i1 == false or i2 == false) then
    return false
  end

  if (EdgeExists(i1.i, i2.i) == true) then
    return false
  end

  local edge = {
    i1 = i1.i,
    i2 = i2.i,
  }
  edges[edgesIndex] = edge
  edgesIndex = edgesIndex + 1
  return edge
end

function GetNodeValue(i)
  for k=1, #nodes do
    if nodes[k].i == i then
      return nodes[k].value
    end
  end
end

function NodeExistsXY(x, y)
  for k=1, #nodes do
    if nodes[k].x == x and nodes[k].y == y then
      return nodes[k]
    end
  end
  return -1
end

function NodeExists(i)
  for k,v in pairs(nodes) do
    if k == i then
      return true
    end
  end
  return false
end

function EdgeExists(i1, i2)
  if (NodeExists(i1) == false) or (NodeExists(i2) == false) then
    return false
  end

  for k=1, #edges do
    if (edges[k].i1 == i1 or edges[k].i1 == i2) and (edges[k].i2 == i1 or edges[k].i2 == i2) then
      return true
    end
  end
  return false
end

local currentNode
local leftNode
local downNode
for i=2, #grid-1 do
  for k=2, #grid[i]-1 do
    currentNode = CreateNode(i, k, grid[i][k])
    leftNode = CreateNode(i+1, k, grid[i+1][k])
    CreateEdge(currentNode, leftNode)
    downNode = CreateNode(i, k+1, grid[i][k+1])
    CreateEdge(currentNode, downNode)
  end
end

aStar = require("PF2020/Astar")
local astar = aStar()
astar:init(_G.life, { nodes = nodes, edges = edges }, startNode, exitNode)
astar:findPath()
astar:derivePath()