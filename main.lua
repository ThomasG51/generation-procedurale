-- definition d'un donjon
local dungeon = {}
dungeon.columns = 9
dungeon.rows = 6
dungeon.cellWidth = 34
dungeon.cellHeight = 13
dungeon.cellGap = 5
dungeon.map = {}
dungeon.startRoom = nil


-- usine pour creer des salles
function generateRoom(row, col)
  local newRoom = {}
  
  newRoom.row = row
  newRoom.column = col
  newRoom.isOpen = false
  newRoom.hasDoorUp = false
  newRoom.hasDoorRight = false
  newRoom.hasDoorDown = false
  newRoom.hasDoorLeft = false
  
  return newRoom
end


function generateStartRoom(roomList)
  -- definition des coordonnees de la salle de depart
  local startRoomY = math.random(1, dungeon.rows)
  local startRoomX = math.random(1, dungeon.columns)
  
  -- on recupere la case de la map avec les coordonnées de départ et on l'ouvre
  local startRoom = dungeon.map[startRoomY][startRoomX]
  startRoom.isOpen = true
  
  -- ajout de la salle de depart a la liste des salles
  table.insert(roomList, startRoom)
  
  -- memorisation de la salle de depart dans le donjon
  dungeon.startRoom = startRoom
end


function generateDungeon()
  -- remise a zero de la map a chaque nouvelle generation
  dungeon.map = {}
  
  -- generation du schema de la map
  local row, col
  for row = 1, dungeon.rows do
    dungeon.map[row] = {}
    for col = 1, dungeon.columns do
      dungeon.map[row][col] = generateRoom(row, col)
    end
  end
  
  -- parametrage des salles
  local roomList = {}
  local roomCount = 20
  
  -- generation de la salle de départ
  generateStartRoom(roomList)
  
  -- generation des autres salles
  while #roomList < roomCount do
    
    -- on selectionne aleatoirement une salle de la liste
    local selectedRoom = roomList[math.random(1, #roomList)]
    
    -- creation de la nouvelle salle a ajouter
    local newRoom = nil
    
    -- selection aleatoire d'une direction et verification de sa disponibilité
    local direction = math.random(1, 4)
    
    -- recupération de la salle au dessus de la salle selectionnee
    if direction == 1 and selectedRoom.row > 1 then
      newRoom = dungeon.map[selectedRoom.row - 1][selectedRoom.column]
      
      -- on verifie que la salle est bien fermer et non utilisee
      if newRoom.isOpen == false then
        -- creation d'un porte vers le bas pour la salle selectionnee
        selectedRoom.hasDoorUp = true
        -- creation d'un porte vers le haut pour la nouvelle salle
        newRoom.hasDoorDown = true
        -- ouverture de la nouvelle salle
        newRoom.isOpen = true
        table.insert(roomList, newRoom)
      end
      
    -- recupération de la salle a droite de la salle selectionnee  
    elseif direction == 2 and selectedRoom.column < dungeon.columns then
      newRoom = dungeon.map[selectedRoom.row][selectedRoom.column + 1]
      
      if newRoom.isOpen == false then
        selectedRoom.hasDoorRight = true
        newRoom.hasDoorLeft = true
        newRoom.isOpen = true
        table.insert(roomList, newRoom)
      end
      
    -- recupération de la salle au dessous de la salle selectionnee
    elseif direction == 3 and selectedRoom.row < dungeon.rows then
      newRoom = dungeon.map[selectedRoom.row + 1][selectedRoom.column]
      
      if newRoom.isOpen == false then
        selectedRoom.hasDoorDown = true
        newRoom.hasDoorUp = true
        newRoom.isOpen = true
        table.insert(roomList, newRoom)
      end
      
    -- recupération de la salle a gauche de la salle selectionnee  
    elseif direction == 4 and selectedRoom.column > 1 then
      newRoom = dungeon.map[selectedRoom.row][selectedRoom.column - 1]
      
      if newRoom.isOpen == false then
        selectedRoom.hasDoorLeft = true
        newRoom.hasDoorRight = true
        newRoom.isOpen = true
        table.insert(roomList, newRoom)
      end
    end
    
  end
end


-- Fontions de base pour Love2d
function love.load()
  generateDungeon()
end

function love.update(dt)
  
end

function love.draw()
  -- affichage de la map
  local x = dungeon.cellGap
  local y = dungeon.cellGap
  
  local row, col
  for row = 1, dungeon.rows do
    for col = 1, dungeon.columns do
      -- recuperation de la salle que l'on dessine
      local room = dungeon.map[row][col]
      
      -- on grise les cellules vides
      if room.isOpen == false then
        love.graphics.setColor(60/255, 60/255, 60/255)
      -- on affiche en orange la salle de départ
      elseif room == dungeon.startRoom then
        love.graphics.setColor(255/255, 120/255, 0/255)
      -- on affiche en blanc les salles actives
      else
        love.graphics.setColor(255/255, 255/255, 255/255)
      end
      
      -- affichage de la salle
      love.graphics.rectangle("fill", x, y, dungeon.cellWidth, dungeon.cellHeight)
      
      -- affichage des portes de la salle
      if room.hasDoorUp == true then
        love.graphics.setColor(255/255, 60/255, 60/255)
        love.graphics.rectangle("fill", (x - 2) + (dungeon.cellWidth/2), y, 4, 2)
      end
      
      if room.hasDoorRight == true then
        love.graphics.setColor(255/255, 60/255, 60/255)
        love.graphics.rectangle("fill", x + dungeon.cellWidth - 2, y + (dungeon.cellHeight/2) - 2, 2, 4)
      end
      
      if room.hasDoorDown == true then
        love.graphics.setColor(255/255, 60/255, 60/255)
        love.graphics.rectangle("fill", (x - 2) + (dungeon.cellWidth/2), y + dungeon.cellHeight - 2, 4, 2)
      end
      
      if room.hasDoorLeft == true then
        love.graphics.setColor(255/255, 60/255, 60/255)
        love.graphics.rectangle("fill", x, (y-2) + (dungeon.cellHeight/2), 2, 4)
      end
      
      x = x + dungeon.cellWidth + dungeon.cellGap
      
    end
    x = dungeon.cellGap
    y = y + dungeon.cellHeight + dungeon.cellGap
    
    -- on remet la couleur blanche par defaut pour eviter le erreur d'affichage 
    love.graphics.setColor(255/255, 255/255, 255/255)
  end
end

function love.keypressed()
  if key == "space" or " " then
    generateDungeon()
  end
end