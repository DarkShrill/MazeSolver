
require "maze"

local mazeA  = nil
local solveA = false

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end

  math.randomseed(os.time())
  
  --mazeA = mazeDecodeFile("/mazes/testDoubleSolution.txt")
--  mazeA = mazeDecodeFile("/mazes/input.txt")
  mazeA = mazeDecodeFile("/mazes/test2.txt")
  --mazeA = mazeDecodeFile("/mazes/testBig.txt")
  
end

function love.update(dt)
  if not solveA then
    mazeSolvePath(mazeA)
    mazePrint(mazeA)
    solveA = true
  end
end

function love.draw()
  if mazeA then
    mazeDraw(mazeA)
  end
end


