local writer = function(grid, path, l)
  local head = "<html><head><style>.left { float: left} .cell {width:16px;height:16px;background-color:grey; border: 1px solid white;text-align:center} .wall {background-color:black} .pit {background-color:purple} .start{background-color:red;color: white} .finish{background-color:green; color:white} .path {background-color:#4169E1;color: white}</style></head><body>"
  local file = io.open("C:\\Users\\Marica Quadrini\\Desktop\\maze.html", "w")
  local main_file = io.open("C:\\Users\\Marica Quadrini\\Desktop\\maze.txt", "w")
  file:write(head .. "<div>Vita Iniziale: " .. _G.life .. "</div><br/>")
  main_file:write("Vita Iniziale: " .. _G.life .. "\n")
  local html = ""

  for k=1, #grid do
    for j=1, #grid[k] do
      if(grid[k][j] == "m") then
        html = html .. "<div class='left cell wall'></div>"
        main_file:write("m")
      elseif(grid[k][j] == "p") then
        html = html .. "<div class='left cell pit'></div>"
        main_file:write("p")
      elseif(grid[k][j] == "i") then
        html = html .. "<div class='left cell start'><b>I</b></div>"
        main_file:write("i")
      elseif(grid[k][j] == "u") then
        html = html .. "<div class='left cell finish'><b>U</b></div>"
        main_file:write("u")
      else 
        if(path[tostring(k).."_"..tostring(j)] == true) then 
          html = html .. "<div class='left cell path'>" .. grid[k][j] .. "</div>"
          main_file:write("*")
        else
          html = html .. "<div class='left cell'>" .. grid[k][j] .. "</div>"
          main_file:write(grid[k][j])
        end
      end
    end
    html = html .. "<br/>"
    main_file:write("\n")
  end

  file:write(html)
  if(l == -1) then 
    file:write("<div><br/>Non ci sono soluzioni</div></body></html>")
    main_file:write("Non ci sono soluzioni\n")
  else
    file:write("<div><br/>Vita Finale: " .. l .. "</div></body></html>")
    main_file:write("Vita Finale: " .. l .. "\n")
  end


end

return writer