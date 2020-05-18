
require "astar"

local countAllPath  = 0
local filesystem    = love.filesystem
local tonumber      = tonumber
local string        = string
local print         = print

local setColour     = love.graphics.setColor
local rectangle     = love.graphics.rectangle
local ellipse       = love.graphics.ellipse
local text          = love.graphics.print
local math          = math

local SPACE         = 24
local CASELLA__F    = -254
local CASELLA__P    = -255

local function splitString(str, delim, keep)
  local tokens = {}
  for w in string.gmatch( str, "([^".. delim.."]*)"..delim.."?" ) do
    tokens[#tokens+1] = w
    if keep == true then
      tokens[#tokens] = tokens[#tokens]..delim
    end
  end
  table.remove(tokens)
  return tokens
end

local function shuffle(tbl)
  local size          = #tbl
  for i = size, 1, -1 do
    local rand        = math.random(size)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
end

local function CreateNewNode(x, y, i)
  local node = {
                 i              = i,
                 x              = x,
                 y              = y,
                 neighbours     = {},
                 neighbourCount = 0,
                 parent         = {},
                 lifePoint      = -1,
               }
  return node
end

local function AddNeighbourToNode(node, neighbour)
  if neighbour ~= nil then
    node.neighbourCount                  = node.neighbourCount + 1
    node.neighbours[node.neighbourCount] = neighbour
  end
end

local function FindNodeFromCordinates(nodes, x, y)
  for i = 1, #nodes do
    local node = nodes[i]
    if node.x == x and node.y == y then
      return node, i
    end
  end
  return nil, -1
end

local function InitWalkableNode(maze)
  maze.nodes             = {}
  local nodes            = maze.nodes
  local nodeCount        = 0
  local grid             = maze.grid
  for mazeY = 1, maze.height do
    for mazeX = 1, maze.width do
      if (grid[mazeY][mazeX] == true) then
        nodeCount        = nodeCount + 1
        local node       = CreateNewNode(mazeX, mazeY, nodeCount)
        nodes[nodeCount] = node
      end
    end
  end
  maze.nodeCount         = nodeCount
end

local function PopulateNeighboursMap(maze)
  
  local nodes            = maze.nodes
  local grid             = maze.grid
  
  for i = 1,  maze.nodeCount do
    local node    = nodes[i]
    local mazeX   = node.x
    local mazeY   = node.y
    
    if (mazeY <= maze.height-1) then -- SUD
      if (grid[mazeY+1][mazeX] == true) then
        local newNode = FindNodeFromCordinates(nodes, mazeX, mazeY+1)
        AddNeighbourToNode(node, newNode)
      end
    end
    
    if (mazeX <= maze.width-1) then -- EST
      if (grid[mazeY][mazeX+1] == true) then
        local newNode = FindNodeFromCordinates(nodes, mazeX+1, mazeY)
        AddNeighbourToNode(node, newNode)
      end
    end
    
    if (mazeX > 1) then -- OEST
      if (grid[mazeY][mazeX-1] == true) then
        local newNode = FindNodeFromCordinates(nodes, mazeX-1, mazeY)
        AddNeighbourToNode(node, newNode)
      end
    end
    
    if (mazeY > 1) then -- NORD
      if (grid[mazeY-1][mazeX] == true) then
        local newNode = FindNodeFromCordinates(nodes, mazeX, mazeY-1)
        AddNeighbourToNode(node, newNode)
      end
    end
  end
end


function shuffleData(neighbours,start)
  
  local count = #neighbours
  local temp = {}
  local value = start
  local c1 = 1
  while count > 0 do
    
    temp[c1] = neighbours[value]
    
    if value >= #neighbours then
      value = 0
    end
    
    count = count - 1
    value = value + 1
    c1 = c1 + 1
    
  end
  
  neighbours = temp
  
  return neighbours
  end
  
function bfsRandom2(start,nodes,exitIndex,maze,pathSol)
  
  local visited = {}
  local queue   = {}
  local count   = 1
  local iter = function (n) return not visited[n] end
  
  
  visited[start] = true;
  
  table.insert(queue,nodes[start])
  
  pathSol[nodes[start].i] = nodes[start]
  
  while 0 < #queue do
    
    local curr = queue[1]
    
    if curr.i == exitIndex then
      
      --qualcosa
      break
    
    end
    
    table.remove(queue,1)
    
      
    if #curr.neighbours > 1 then
        shuffle(curr.neighbours)
    end

    
    for p, n in ipairs(curr.neighbours) do
      
      --verificare se è una cella valida da fare
      
      --verifico che già non l'ho visitato
      if iter(n.i) then
        
        visited[n.i] = true
        
        --aggiungo alla lista tutti i suoi vicini
        table.insert(queue,n)
        
        n.parent = curr
        pathSol[n.i] = n
      end
    end
  end
end


function westNodeIsValid(node,visited)
    
  local iter = function (n) return not visited[n] end
  
  for i,n in ipairs(node.neighbours) do
    if ((n.x == (node.x-1))and(n.y == node.y) and iter(n.i)) then
      return true,n
    end
  end
  return false
end

function estNodeIsValid(node,visited)
    
  local iter = function (n) return not visited[n] end
  
  for i,n in ipairs(node.neighbours) do
    if ((n.x == (node.x+1))and(n.y == node.y) and iter(n.i)) then
      return true,n
    end
  end
  return false
end

function northNodeIsValid(node,visited)
    
  local iter = function (n) return not visited[n] end
  
  for i,n in ipairs(node.neighbours) do
    if ((n.x == (node.x))and(n.y == node.y - 1) and iter(n.i)) then
      return true,n
    end
  end
  return false
end

function sudNodeIsValid(node,visited)
  
  local iter = function (n) return not visited[n] end
  
  for i,n in ipairs(node.neighbours) do
    if ((n.x == (node.x))and(n.y == node.y + 1) and iter(n.i)) then
      return true,n
    end
  end
  return false
end


function countPath(node,path,exitIndex,visited,countAllPath,pathSol)
  
  local queue   = {}
  local iter = function (n) return not visited[n] end
  
  if node.i == exitIndex then
    table.insert(path,node)
--    table.insert(pathSol[#pathSol],path)
    
    for i,n in ipairs(path) do
      table.insert(pathSol[#pathSol],n)
    end
    
    
    for i,n in ipairs(path) do
      if n.i == node.i then
        table.remove(path,i)
        break
      end
    end
    pathSol[#pathSol + 1] = {}
    countAllPath = countAllPath + 1
    return countAllPath
  end
  
  
  if iter(node.i) then
    visited[node.i] = true
    
    table.insert(path,node)
     
    bool,no = sudNodeIsValid(node,visited)
    
    if bool then
      countAllPath = countPath(no,path,exitIndex,visited,countAllPath,pathSol)
    end
    
    bool,no = northNodeIsValid(node,visited)
    
    if bool then
      countAllPath = countPath(no,path,exitIndex,visited,countAllPath,pathSol)
    end
    
    bool,no = estNodeIsValid(node,visited)
    
    if bool then
      countAllPath = countPath(no,path,exitIndex,visited,countAllPath,pathSol)
    end
    
    bool,no = westNodeIsValid(node,visited)
    
    if bool then
      countAllPath = countPath(no,path,exitIndex,visited,countAllPath,pathSol)
    end
    
  end
  
  visited[node.i] = false
  
  for i,n in ipairs(path) do
    if n.i == node.i then
      table.remove(path,i)
      break
    end
  end
  
  return countAllPath
  
  end


function bfs(start,nodes,exitIndex,maze,pathSol)
  
  local visited = {}
  local queue   = {}
  local count   = 1
  local iter = function (n) return not visited[n] end
  
  
  visited[start] = true;
  
--  for i,n in ipairs(nodes[start].neighbours) do
--    table.insert(queue,n)
--  end
  table.insert(queue,nodes[start])
  
  pathSol[nodes[start].i] = nodes[start]
  
  while 0 < #queue do
    
    local curr = queue[1]
    
    if curr.i == exitIndex then
      
      --qualcosa
      break
    
    end
    
    table.remove(queue,1)
    
    for p, n in ipairs(curr.neighbours) do
      
      --verificare se è una cella valida da fare
      
      --verifico che già non l'ho visitato
      if iter(n.i) then
        
        visited[n.i] = true
        
        --aggiungo alla lista tutti i suoi vicini
        table.insert(queue,n)
        
        n.parent = curr
        pathSol[n.i] = n
        --count = count + 1
        
        
        
        
        
      end
      
      
    end
    
    
  end
  
  
end

function GetBaseInfo(fullpath,maze)
  
  local mazeX
  local BaseInfo = {
                      StartX = -1,
                      StartY = -1,
                      
                      ExitX  = -1,
                      ExitY  = -1,
              
                      PozzoX  = -1,
                      PozzoY  = -1,
              
                   }
          
    local lineCount            = 0
    local mazeY                = 1
          
    for line in filesystem.lines(fullpath) do
     
      lineCount                = lineCount + 1
      local splitStr           = splitString(line, " ", false)
     
      if (lineCount == 1) then
        goto SKIP
      end

      for mazeX = 1, #splitStr do
        if (splitStr[mazeX] == 'm') then
          maze.grid[mazeY][mazeX] = false
        else
          maze.grid[mazeY][mazeX] = true--splitStr[mazeX]
          if(splitStr[mazeX] == 'u')then              -- USCITA
            BaseInfo.ExitX = mazeX
            BaseInfo.ExitY = mazeY
          end
          if(splitStr[mazeX] == 'i')then              -- INGRESSO
            BaseInfo.StartX = mazeX
            BaseInfo.StartY = mazeY
          end
          if(splitStr[mazeX] == 'p')then              -- POZZO
            BaseInfo.PozzoX = mazeX
            BaseInfo.PozzoY = mazeY
          end
        end
      end
      mazeY = mazeY + 1
::SKIP::
     
    end
    
    return BaseInfo
  
end

function GetFileCol(fullpath)
  local count = 0;
  for n in filesystem.lines(fullpath) do
    count = count + 1
    if count > 2 then
      return (((#n)+1)/2)
    end
  end
  return count
end

function GetFileRow(fullpath)
  local count = 0;
  for _ in filesystem.lines(fullpath) do
    count = count + 1
  end
  return count - 1
end

function MazeAddLifePoint(fullpath,maze)
  
  local lineCount            = 0
  local mazeY                = 1
  local count                = 1
        
  for line in filesystem.lines(fullpath) do
   
    lineCount                = lineCount + 1
    local splitStr           = splitString(line, " ", false)
   
    if (lineCount == 1) then
      goto SKIP
    end

    for mazeX = 1, #splitStr do
      if (splitStr[mazeX] == 'm')then
    else
        if((splitStr[mazeX] == 'u') or (splitStr[mazeX] == 'i'))then
        elseif(splitStr[mazeX] == 'f')then
          maze.nodes[count].lifePoint = CASELLA__F --ID DELLA CASELLA F
        elseif(splitStr[mazeX] == 'p')then
          maze.nodes[count].lifePoint = CASELLA__P --ID DELLA CASELLA P
        else
          maze.nodes[count].lifePoint = tonumber(splitStr[mazeX])
        end
          count = count + 1
      end
    end
    mazeY = mazeY + 1
::SKIP::
   
  end
end

function mazeDecodeFile(fullpath)
  
  local maze = {
                startLife  = 0,
    
                 width     = 0,
                 height    = 0,
                 grid      = {},
                 
                 startX    = 0,
                 startY    = 0,
                 exitX     = 0,
                 exitY     = 0,
                 pozzoX    = 0,
                 pozzoY    = 0,
                 
                 nodes     = {},
                 nodeCount = 0,
                 path      = {},
                 
                 startIndex = 0,
                 endIndex   = 0,
                 
                 ready     = false,
                 solved    = false,
                                
               }
  
  local fileinfo = filesystem.getInfo(fullpath)
  if fileinfo == nil then
    print("No file: '"..fullpath.."'")
    do return maze end
  end
  
  local lineCount            = 0
  local mazeY                = 1
    
  
  for line in filesystem.lines(fullpath) do
    
    lineCount                = lineCount + 1
    
    local splitStr           = splitString(line, " ", false)
    
    if (lineCount == 1) then
      maze.startLife         = tonumber(splitStr[1])
      maze.height            = GetFileRow(fullpath)
      maze.width             = GetFileCol(fullpath)
      for i = 1, maze.height do
        maze.grid[i]         = {}
      end
    else
      for mazeX = 1, maze.width do
        if ((splitStr[mazeX]) == 'm') then
          maze.grid[mazeY][mazeX] = false
        else
          maze.grid[mazeY][mazeX] = true
        end
      end
      mazeY      = mazeY + 1
      maze.ready = true
      
    end
  end
  
  
  InitWalkableNode(maze)
  
  PopulateNeighboursMap(maze)
  
  
  BaseInfo               = GetBaseInfo(fullpath,maze)
  maze.startX            = BaseInfo.StartX
  maze.startY            = BaseInfo.StartY

  maze.exitX             = BaseInfo.ExitX
  maze.exitY             = BaseInfo.ExitY

  maze.pozzoX            = BaseInfo.PozzoX
  maze.pozzoY            = BaseInfo.PozzoY
  
  MazeAddLifePoint(fullpath,maze)

  return maze
end

function NewPathStruct(life,pathS)
  local PathStruct = {
                        life = life,
                        path = pathS,
                      }
  return PathStruct
end

function ReturnBestWay(status,path,life)
  local data = {
                  exist = status,
                  path = path,
                  life = life,
               }
   return data
end

function SearchBestWay(maze,pathSol)
  
  local path        = nil
  local RemainPath  = {{}}
  local PathStruct = {
                        life = -1,
                        path = {},
                      }
  
  -- TROVO TUTTI I PATH CHE MI PERMETTONO DI ARRIVARE ALL'USCITA CON UNA VITA > 0
  
  for i = 1,#pathSol - 1 do
    local __path = pathSol[i]
    local life = maze.startLife
    
    for j = 1, #__path do
      if ((__path[j].lifePoint >= 1) and (__path[j].lifePoint <= 4))then
        life = life + __path[j].lifePoint
      elseif ((__path[j].lifePoint >= 5) and (__path[j].lifePoint <= 8))then
        life = life + (4 - __path[j].lifePoint)
      elseif (__path[j].lifePoint == 9)then
        life = life * 2
      elseif (__path[j].lifePoint == CASELLA__F)then
        if(life == 1)then
          goto DEAD
        end
        life = life / 2
        life = floor(life)
      elseif (__path[j].lifePoint == CASELLA__P)then
        goto DEAD
      end
      
      if(life <= 0)then
        goto DEAD
      end
      
    end
    
    RemainPath[#RemainPath] = NewPathStruct(life,__path)
    RemainPath[#RemainPath + 1] = {}
    
    
::DEAD::
      
  end
    
  if(#RemainPath == 1)then
    if(RemainPath[1] == nil)then
      return false
    end
  end
  
  
  -- RIMUOVO L'ULTIMO ELEMENTO CHE NON SERE (E' VUOTO)
  table.remove(RemainPath,#RemainPath)
  
  -- TROVO TUTTI I PATH CHE MI PERMETTONO DI ARRIVARE ALL'USCITA CON IL NUMERO DI PASSI MINORE
  local MinimumPath = {{}}
  local MinIndex    = -1
  for _,data in ipairs(RemainPath) do
    if(MinIndex == -1)then
      MinIndex = #data.path
      MinimumPath[#MinimumPath] = NewPathStruct(data.life,data.path)
      MinimumPath[#MinimumPath + 1] = {}
      goto SKIP
    end
    
    if(#data.path < MinIndex)then
      
      -- TOLGO TUTTI I VALORI MINIMI PRECENDETI (POSSONO ESSERE ANCHE PIU DI UNO)
      local tempVal = MinIndex
      for n,data in ipairs(MinimumPath) do
        if(#data.path == tempVal)then
          table.remove(MinimumPath,n)
        end
      end
      
      MinIndex = #data.path
      MinimumPath = nil
      MinimumPath = {}
      MinimumPath[#MinimumPath] = NewPathStruct(data.life,data.path)
      MinimumPath[#MinimumPath + 1] = {}
    elseif(#data.path == MinIndex)then
      MinimumPath[#MinimumPath] = NewPathStruct(data.life,data.path)
      MinimumPath[#MinimumPath + 1] = {}
    end
    
::SKIP::
    
  end
  
  -- RIMUOVO L'ULTIMO ELEMENTO CHE NON SERE (E' VUOTO)
  table.remove(MinimumPath,#MinimumPath)
  
  
  -- TROVO IL PATH CON MAGGIORE VITA
 
  table.sort(MinimumPath, function (left, right)
    return left.life < right.life
  end)
  
  
  _,data = ipairs(MinimumPath[1])
  
  
  return ReturnBestWay(true,data.path,data.life)
end

local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
end

function mazeSolvePath(maze)
  maze.solved         = false
  maze.path           = nil
  maze.trim           = nil
  
  
  if not maze.ready then
    print("No maze data to solve")
    return
  end
  
  -- Reset the start and exit marks
  local nodes            = maze.nodes
  _, maze.startIndex     = FindNodeFromCordinates(nodes, maze.startX, maze.startY)
  _, maze.exitIndex      = FindNodeFromCordinates(nodes, maze.exitX, maze.exitY)
  if (maze.startIndex == -1 or maze.exitIndex == -1) then
    print("No start or exit node")
    return
  end
  local startNode = nodes[maze.startIndex]
  local exitNode = nodes[maze.exitIndex]
  
  local startTime = love.timer.getTime()
  print("Solving")
  
  local pathSol       = {{}}
  local path          = {}
    

  local visited = {}

  --##############################################################################################################################
  --#############                                                                                                    #############
  --#############                                              RISOLVO CON A*                                        #############
  --#############                                                                                                    #############
  --##############################################################################################################################
    
  pathSol[1] = a_star(startNode,exitNode,maze.nodes,maze.startLife)


    
  local life = CalLife(pathSol[1],maze.startLife)

  --LA SOLUZIONE SI TROVA IN "pathSol[1]" e la vita sta in "life" 

  pathSol       = {{}}


  --##############################################################################################################################
  --#############                                                                                                    #############
  --#############                                              RISOLVO CON DFS                                       #############
  --#############                                                                                                    #############
  --##############################################################################################################################

  countAllPath = countPath(maze.nodes[maze.startIndex],path,maze.exitIndex,visited,countAllPath,pathSol)
  
  if(countAllPath > 0)then
    --ESISTE UNA SOLUZIONE (SENZA MURI CHE BLOCCANO L'USCITA)
    
    local result = SearchBestWay(maze,pathSol)
    
    if(result.exist == true)then
      --ESISTE UNA SOLUZIONE (SENZA MORIRE)
      maze.path = result.path
    end
    
  end
  
  --LA SOLUZIONE SI TROVA IN "maze.path" e la vita sta in "result.life" 
  
  pathSol       = {{}}
  
  --##############################################################################################################################
  --#############                                                                                                    #############
  --#############                                              RISOLVO CON BFS                                       #############
  --#############                                                                                                    #############
  --##############################################################################################################################
  
  bfsRandom2(maze.startIndex, maze.nodes, maze.exitIndex,maze,pathSol)   
  
  goto END
    
    --bfsRandom2(maze.startIndex, maze.nodes, maze.exitIndex,maze,pathSol)    
    
::END::
  -- Done
  local endTime = love.timer.getTime()
  local outTime = endTime - startTime
  print("\tDone: "..outTime.." s")
  
end
  
function mazePrint(maze)
  
  if not maze.ready then
    print("No maze data to print")
    return
  end
  
  if maze.width > 30 then
    print("Maze too large to print")
    return
  end
  
  if maze.solved then
    print("Solution")
    
    local currentRow    = ""
    local path          = maze.path
    local grid          = maze.grid
    
    for mazeY = 1, maze.height do
      for mazeX = 1, maze.width do
        if (grid[mazeY][mazeX] == true) then
          
          if (mazeY == maze.startY and mazeX == maze.startX) then
            currentRow = currentRow.."S"
            
          elseif (mazeY == maze.exitY and mazeX == maze.exitX) then
            currentRow = currentRow.."E"
            
          else -- Scan through path list for a node that is part of the solution
            local matchedNode = false
            for listIndex = 1, #path do
              local node = path[listIndex]
              if (mazeY == node.y and mazeX == node.x) then
                matchedNode = true
                break
              end
            end
            
            if (matchedNode == true) then
              currentRow = currentRow.."X"
            else
              currentRow = currentRow.." "
            end
            
          end
          
        else
          currentRow = currentRow.."#"
          
        end
        
      end
      
      print("\t"..currentRow)
      currentRow = ""
    end
  
  else
    print("No Solution")
  
  end
  
end

function mazeDraw(maze)

  if not maze.ready then
    return
  end
  
  --
  local gridSpace     = SPACE
  local gridStartX    = gridSpace
  local gridStartY    = gridSpace
  local gridHalf      = gridSpace * 0.5
  local tokenSize     = gridSpace / 2 -- 8
  local tokenSize2    = gridSpace / 4 -- 4
  local tokenSize3    = gridSpace / 3 -- 2

  --
  local grid          = maze.grid
  local path          = maze.path

  
  local posX          = 0
  local posY          = gridStartY
  
  for mazeY = 1, maze.height do
    posX = gridStartX
    
    for mazeX = 1, maze.width do
      
      if (grid[mazeY][mazeX] == true) then
        
        if (mazeY == maze.startY and mazeX == maze.startX) then -- Start
          setColour(0.1, 0.6, 0.1, 1)
          ellipse("line", math.floor(gridHalf + posX), math.floor(gridHalf + posY), tokenSize, tokenSize)
          
        elseif (mazeY == maze.exitY and mazeX == maze.exitX) then -- Exit
          setColour(0.6, 0.6, 0.1, 1)
          ellipse("line", math.floor(gridHalf + posX), math.floor(gridHalf + posY), tokenSize, tokenSize)
          
        end
        
      else -- Wall
        setColour(0.3, 0.3, 0.3, 1)
        rectangle("fill", math.floor(posX), math.floor(posY), gridSpace, gridSpace)
        
      end
      
      posX = posX + gridSpace
      
    end
    
    posY = posY + gridSpace
    
  end
  
  if not maze.bounds then
    
    maze.bounds = {
                    x  = gridStartX,
                    y  = gridStartY,
                    x2 = posX,
                    y2 = posY,
                    w  = posX - gridStartX,
                    h  = posY - gridStartY,
                  }
    
  end
  
  if maze.solved and path then -- PATH
    
    for i = 1, #path do
      local node = path[i]
      posX = gridStartX + ((node.x-1) * gridSpace)
      posY = gridStartY + ((node.y-1) * gridSpace)
      
      setColour(0.1, 0.1, 0.5, 1)
      ellipse("fill", math.floor(gridHalf + posX), math.floor(gridHalf + posY), tokenSize2, tokenSize2)
      
    end
    
  end
  
  
end

