local AStar = {}
local writer = require("PF2020/writeToFile")
PriorityQueue = require("PF2020/priorityQueue")
Queue = require("PF2020/queue")
local open = PriorityQueue()
local closed = Queue()
local life = _G.life

AStar.__index = AStar
setmetatable(
  AStar,
  {
    __call = function (self)
      setmetatable({}, self)
      return self
    end
  }
)

function AStar:init(l, graph, startNode, exitNode)
  self.nodes = graph.nodes
  self.edges = graph.edges
  self.startNode = startNode
  self.exitNode = exitNode

  function getNeighbors(id)
    local listOfNeighbors = {}
    for k,v in pairs(self.edges) do
      if(v.i1 == id) then
        table.insert(listOfNeighbors, self.nodes[v.i2])
      elseif(v.i2 == id) then
        table.insert(listOfNeighbors, self.nodes[v.i1])
      end
    end
    return listOfNeighbors
  end

  function calculateDistance(n1, n2)
    return math.sqrt(((n1.x - n2.x)^2 + (n1.y - n2.y)^2)) * 10
  end

  function calculateLife(n, currLife)
    if(n.value == "i" or n.value == "u") then
      return currLife
    end
    if(n.value == "f") then
      return math.floor(currLife / 2)
    elseif(tonumber(n.value) == 9) then
      return currLife * 2
    elseif (tonumber(n.value) < 5) then
      return currLife + tonumber(n.value)
    else
      return currLife + (4 - tonumber(n.value))
    end
  end

  function isClosed(n)
    return closed:contains(n)
  end


  function calculateHeuristic(pqNode)
    return pqNode.distance + pqNode.steps
  end

  function createPriorityQueueNode(node, parent, steps, currLife, exitNode)
    local n = {
      node = node,
      parent = parent,
      steps = steps,
      life = currLife,
      distance = calculateDistance(node, exitNode)
    }
    return n
  end

  function calculateClosestNode(n1)
    local min = self.exitNode[1]
    local tmp
    for k=2, #self.exitNode do
      if(calculateDistance(n1, self.exitNode[k]) < calculateDistance(n1, min)) then
        min = self.exitNode[k]
      end
    end
    return min
  end
end


function AStar:findPath()
  local n
  local tmp
  local l = _G.life
  local dist
  local closest
  local bestSteps = #self.nodes
  n = createPriorityQueueNode(self.startNode, self.startNode, 0, _G.life, calculateClosestNode(self.startNode))
  open:put(n, calculateHeuristic(n))

  while open:empty() == false do
    n = open:pop()

    if(n.node.value ~= "i") then
      if (n.node.value == "u") then
        bestSteps = n.steps
        closed:push(n)
        goto continue
      else 
        l = calculateLife(n.node, n.life)
        if(l < 1) then
          print("DEADDED")
        end
      end
    end

    if(l > 0) then
      for k,v in pairs(getNeighbors(n.node.i)) do
        closest = calculateClosestNode(v)
        if(n.parent.node == nil) then
          n.parent.node = {}
          n.parent.node.i = n.parent.i
        end
        if(n.steps+1 <= bestSteps and v.i ~= n.parent.node.i) then
          tmp = createPriorityQueueNode(v, n, n.steps+1, l, closest)
          open:put(tmp, calculateHeuristic(tmp))
        end
      end
      closed:push(n)
    end
    ::continue::
  end
end

function movePointer(n)
  local tmp = n.parent
  return tmp
end

function AStar:derivePath()
  local tmp_list = {}
  local possible_solutions = {}

  local node = true
  while node ~= false do
    node = closed:dequeue()
    if(node == false) then
      break
    end
    if(node.node.value == "u") then
      table.insert(possible_solutions, node)
    end
  end

  local best = possible_solutions[1]
  local finalLife
  if(best == nil) then
    finalLife = -1
  else
    for k=2, #possible_solutions do
      if(possible_solutions[k].life < best.life) then
        best = possible_solutions[k]
      end
    end
    finalLife = best.life
    while best.parent.node.i ~= "i" do
      tmp_list[tostring(best.node.x).."_"..tostring(best.node.y)] = true
      best = movePointer(best)
      if(best.node.value == "i") then
        tmp_list[tostring(best.node.x).."_"..tostring(best.node.y)] = true
        break
      end
    end
  end

  writer(_G.grid, tmp_list, finalLife)
end

return AStar
