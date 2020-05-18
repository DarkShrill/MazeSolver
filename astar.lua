local INF = 1/0
local cachedPaths = nil

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------

function dist ( x1, y1, x2, y2 )
	
	return math.sqrt ( math.pow ( x2 - x1, 2 ) + math.pow ( y2 - y1, 2 ) )
end

function dist_between ( nodeA, nodeB )

	return dist ( nodeA.x, nodeA.y, nodeB.x, nodeB.y )
end

function heuristic_cost_estimate ( nodeA, nodeB )

	return dist ( nodeA.x, nodeA.y, nodeB.x, nodeB.y )
end

function is_valid_node ( node, neighbour )

	return true
end

function lowest_f_score ( set, f_score )

	local lowest, bestNode = INF, nil
	for _, node in ipairs ( set ) do
		local score = f_score [ node ]
		if score < lowest then
			lowest, bestNode = score, node
		end
	end
	return bestNode
end

function getNeighbour(node)

	local neighbours = {}
	for _, node in ipairs ( node.neighbours ) do
    table.insert ( neighbours, node )
	end
	return neighbours
end

function neighbour_nodes ( theNode, nodes )

	local neighbours = {}
	for _, node in ipairs ( nodes ) do
		if theNode ~= node and is_valid_node ( theNode, node ) then
			table.insert ( neighbours, node )
		end
	end
	return neighbours
end

function not_in ( set, theNode )

	for _, node in ipairs ( set ) do
		if node == theNode then return false end
	end
	return true
end

function remove_node ( set, theNode )

	for i, node in ipairs ( set ) do
		if node == theNode then 
			set [ i ] = set [ #set ]
			set [ #set ] = nil
			break
		end
	end	
end

function unwind_path ( flat_path, map, current_node )

	if map [ current_node ] then
		table.insert ( flat_path, 1, map [ current_node ] ) 
		return unwind_path ( flat_path, map, map [ current_node ] )
	else
		return flat_path
	end
end

----------------------------------------------------------------
-- pathfinding functions
----------------------------------------------------------------





function clear_cached_paths ()

	cachedPaths = nil
end

function distance ( x1, y1, x2, y2 )
	
	return dist ( x1, y1, x2, y2 )
end

local valid_node_func = function ( node, neighbour ) 

	local MAX_DIST = 300
		
	-- helper function in the a-star module, returns distance between points
	if  distance( node.x, node.y, neighbour.x, neighbour.y ) < MAX_DIST then
		return true
	end
	return false
end

function GetLifeOperation(life,dataLife)
  
  
  if ((dataLife >= 1) and (dataLife <= 4))then
        life = life + dataLife
      elseif ((dataLife >= 5) and (dataLife <= 8))then
        life = life + (4 - dataLife)
      elseif (dataLife == 9)then
        life = life * 2
      elseif (dataLife == CASELLA__F)then
        if(life == 1)then
          return -1
        end
        life = life / 2
        life = floor(life)
      elseif (dataLife == CASELLA__P)then
        return -1
      end
  return life
end

function CalLife(__path,startLife)
    local life = startLife
    
    for j = 1, #__path do
      if ((__path[j].lifePoint >= 1) and (__path[j].lifePoint <= 4))then
        life = life + __path[j].lifePoint
      elseif ((__path[j].lifePoint >= 5) and (__path[j].lifePoint <= 8))then
        life = life + (4 - __path[j].lifePoint)
      elseif (__path[j].lifePoint == 9)then
        life = life * 2
      elseif (__path[j].lifePoint == CASELLA__F)then
        if(life == 1)then
          return -1
        end
        life = life / 2
        life = floor(life)
      elseif (__path[j].lifePoint == CASELLA__P)then
        return -1
      end
      
      if(life <= 0)then
        return -1
      end
      
    end
  return life
end

function a_star ( start, goal, nodes, life)

	local closedset = {}
	local openset = { start }
	local came_from = {}

	--if valid_node_func then is_valid_node = valid_node_func end

	local g_score, f_score = {}, {}
	g_score [ start ] = 0
	f_score [ start ] = g_score [ start ] + heuristic_cost_estimate ( start, goal )

	while #openset > 0 do
	
		local current = lowest_f_score ( openset, f_score )
		if current == goal then
			local path = unwind_path ( {}, came_from, goal )
			table.insert ( path, goal )
			return path
		end

		remove_node ( openset, current )		
		table.insert ( closedset, current )
		
--		local neighbors = neighbor_nodes ( current, nodes )  OLD
    local neighbours = getNeighbour(current)
		for _, neighbour in ipairs ( neighbours ) do 
			if not_in ( closedset, neighbour ) then
			
				local tentative_g_score = g_score [ current ] + dist_between ( current, neighbour )
				 
				if not_in ( openset, neighbour ) or tentative_g_score < g_score [ neighbour ] then 
					came_from [ neighbour ] = current
					g_score 	[ neighbour ] = tentative_g_score
					f_score 	[ neighbour ] = g_score [ neighbour ] + heuristic_cost_estimate ( neighbour, goal )
					if not_in ( openset, neighbour ) then
            local currLife = life
            life = GetLifeOperation(life,neighbour.lifePoint)
            if(life > 0)then
              table.insert ( openset, neighbour )
            else
              table.insert ( closedset, current )
              life = currLife
            end
					end
				end
			end
		end
	end
	return nil -- no valid path
end

function path ( start, goal, nodes, ignore_cache, valid_node_func )

	if not cachedPaths then cachedPaths = {} end
	if not cachedPaths [ start ] then
		cachedPaths [ start ] = {}
	elseif cachedPaths [ start ] [ goal ] and not ignore_cache then
		return cachedPaths [ start ] [ goal ]
	end

      local resPath = a_star ( start, goal, nodes, valid_node_func )
      if not cachedPaths [ start ] [ goal ] and not ignore_cache then
              cachedPaths [ start ] [ goal ] = resPath
      end

	return resPath
end