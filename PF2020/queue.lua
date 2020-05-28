local Queue = {}
Queue.__index = Queue
local var_dump = require("PF2020/var_dump")

setmetatable(
  Queue,
  {
    __call = function (self)
      setmetatable({}, self)
      self:initialize()
      return self
    end
  }
)

function Queue:initialize()
  self.q = {}
end

function Queue:push (value)
  table.insert(self.q, value)
end

function Queue:pop()
  if(#self.q == 0) then 
    return false
  else 
    return table.remove(self.q, 1)
  end
end

function Queue:dequeue()
  if(#self.q == 0) then 
    return false
  else 
    return table.remove(self.q, #self.q)
  end
end

function Queue:isEmpty()
  return #self.q == 0
end

function Queue:contains(item)
  for k=1, #self.q do
    if(self.q[k].node.i == item.i) then
      return true
    end
  end
  return false
end


function Queue:print()
  for k=1, #self.q do
    var_dump(self.q[k])
  end
end

return Queue