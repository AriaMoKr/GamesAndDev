-- Tetriminos
-- by Aria Kraft
-- basic puzzle block game illustrating simple Lua & Love2D game prototype

-- initial global variable values
blocksize = 38 -- block size in pixels
marginleft, margintop = 200, 6 -- offset x & y of the board in the window
width, height = 10, 15 -- size of the board's grid x & y
curpiece = 1 -- just a place holder for the current piece for reference purposes - it gets reset with a new game
lastmove = 0 -- a timer for the piece lowering function - it gets reset when the piece is moved down
rotation = 1 -- the current rotation of the current piece
gameover = false -- game over indicator -- it gets reset with a new game

-- color table used by pieces - red, green, and blue ( 0 to 255 )
colors = {
  {255, 0, 0},
  {255, 127, 0},
  {255, 0, 255},
  {0, 0, 255},
  {0, 255, 0},
  {127, 127, 255},
  {0, 255, 255}
}  

-- each piece is listed with their corresponding rotations. The number is used as a lookup in the colors table
pieceI = {
  "    "..
	"    "..
	"1111"..
  "    ",
  
  " 1  "..
	" 1  "..
	" 1  "..
  " 1  ",
}

pieceJ = {
  "    "..
  " 2  "..
  " 222"..
  "    ",
  
  "    "..
  " 22 "..
  " 2  "..
  " 2  ",
  
  "    "..
  " 222"..
  "   2"..
  "    ",
  
  "  2 "..
  "  2 "..
  " 22 "..
  "    "
}

pieceL = {
  "    "..
  "   3"..
  " 333"..
  "    ",
  
  " 3  "..
  " 3  "..
  " 33 "..
  "    ",
  
  "    "..
  " 333"..
  " 3  "..
  "    ",
  
  "    "..
  " 33 "..
  "  3 "..
  "  3 "
}

pieceO = {
  "    "..
  " 44 "..
  " 44 "..
  "    "
}

pieceS = {
  "    "..
  "  55"..
  " 55 "..
  "    ",

  " 5  "..
  " 55 "..
  "  5 "..
  "    "
}

pieceT = {
  "    "..
  " 666"..
  "  6 "..
  "    ",

  "  6 "..
  " 66 "..
  "  6 "..
  "    ",

  "  6 "..
  " 666"..
  "    "..
  "    ",
  
  "  6 "..
  "  66"..
  "  6 "..
  "    ",  
}

pieceZ = {
  "    "..
  " 77 "..
  "  77"..
  "    ",
  
  "  7 "..
  " 77 "..
  " 7  "..
  "    "
}

-- all pieces rolled up in one table for indexing
pieces = {
  pieceI,
  pieceJ,
  pieceL,
  pieceO,
  pieceS,
  pieceT,
  pieceZ,
}

-- checks if the current piece will collide given the position (px, py) and the rotation (_rotation)
function doesCollide(px, py, _rotation)
	collide = false
	
	for y = 1, 4 do
		for x = 1, 4 do
			if getCurPieceBlock(x, y, _rotation) then
				ix = px + x - 1
				iy = py + y - 1
				if ix < 1 or ix > width or iy < 1 or iy > height then
					collide = true
        elseif board[iy][ix] ~= ' ' then
          collide = true
				end
			end
		end
	end

	return collide
end

-- shows the game over screen
function drawGameOver()
  local goMargin = 10
  local height = love.graphics.getHeight()
  local width = love.graphics.getWidth()
  local gw = width - goMargin * 2
  local gh = height - goMargin * 2
  
  love.graphics.setColor({255, 0, 0})
  love.graphics.rectangle("fill", goMargin, goMargin, gw, gh)
end

-- draws each frame
function love.draw()
	drawBoard()
  if gameover then
    drawGameOver()
  else
    drawPiece()
  end
end

-- counts the amount of blocks on the current line (y)
function countOnLine(y)
  c = 0
  for x = 1, width do
    if board[y][x] ~= ' ' then
      c = c + 1
    end
  end
  return c
end

-- wipes out the line (y) - used when line is full after the player fills it
function clearLine(y)
  for x = 1, width do
    board[y][x] = ' '
  end
end

-- moves everything above the line (y) to line (y) after it is cleared
function moveEverythingDown(y)
  i = y
  while i > 1 do
    board[i] = board[i-1]
    i = i - 1
  end
  board[1] = {}
  for i = 1, width do
    board[1][i] = ' '
  end
end

-- goes through each line to check for and wipe out lines that have been filled
function processLines()
  for r = height, 1, -1 do
    while countOnLine(r) == width do
      -- clearLine(r) -- not needed because the line is replaced by moveEverythingDown
      moveEverythingDown(r)
    end
  end
end

-- puts the current piece and rotation onto the board, processes the lines, and gets a new piece
function setPiece()
	for y = 1, 4 do
		for x = 1, 4 do
			if getCurPieceBlock(x, y, rotation) then
				ix = curposx + x - 1
				iy = curposy + y - 1
				board[iy][ix] = tostring(curpiece)
			end
		end
	end
  processLines()
  newPiece()
end

-- updates the game at each frame. Halts at game over and moves the piece down each time duration
function love.update(dt)
  if gameover then
    return
  end
	lastmove = lastmove + dt
	if lastmove >= 1 then
		lastmove = lastmove - 1
		moveDown()
	end
end

-- moves the piece down until it hits something
function dropPiece()
  while not doesCollide(curposx, curposy+1, rotation) do
    moveDown()
  end
end

-- changes the rotation of the piece and makes sure that it doesn't collide first
function rotatePiece()
  newrotation = rotation + 1
  if newrotation > table.getn(pieces[curpiece]) then
    newrotation = 1
  end
  if not doesCollide(curposx, curposy, newrotation) then
    rotation = newrotation
  end
end

-- handles keyboard key presses each frame
function love.keypressed(key)
	if key == "escape" then love.event.push("quit")
	elseif key == "down" then moveDown()
	elseif key == "left" then moveLeft()
	elseif key == "right" then moveRight()
	elseif key == "return" then dropPiece()
	elseif key == "f11" then love.graphics.toggleFullscreen()
  
  -- debugging stop
	-- elseif key == "d" then debug.debug()
  
  elseif key == "r" then newgame()
  elseif key == " " then rotatePiece()
	end
end

-- gets called at the beginning of the game and after setting a piece down to create a new piece at the top of the screen
function newPiece()
  curpiece = math.random(table.getn(pieces))
  rotation = 1
  curposx, curposy = 4, 1
  if doesCollide(curposx, curposy, rotation) then
    gameover = true
  end
end

-- gets called at the beginning of the game and when the game is reset to clear the board and create a new piece
function newgame()
  gameover = false
	board = {}
	for y = 1,height do
		board[y] = {}
		for x = 1,width do
			board[y][x] = ' '
		end
	end
  newPiece()
end

-- sets up debugging when enabled and creats a new game when the program gets loaded
function love.load()
  -- if arg[#arg] == "-debug" then require("mobdebug").start() end
	newgame()
end

-- moves a piece to a new location if it will not collide with something
function moveIfNoCollision(x, y)
	if not doesCollide(x, y, rotation) then
		curposx = x
		curposy = y
	end
end

-- moves piece down and sets the piece if it collides with something
function moveDown()
  if doesCollide(curposx, curposy+1, rotation) then
    setPiece()
  else
    -- moveIfNoCollision(curposx, curposy + 1) - not needed because we already checked for a collision
    curposy = curposy + 1
  end
  -- reset piece lowering timer
  lastmove = 0
end

-- moves piece left if there isn't a collision
function moveLeft()
	moveIfNoCollision(curposx - 1, curposy)
end

-- moves piece right if there isn't a collision
function moveRight()
	moveIfNoCollision(curposx + 1, curposy)
end

-- used for copy a color table so it doesn't modify the original
-- only a simple copy
function copyTable(t)
  newtable = {}
  for key, value in pairs(t) do
    newtable[key] = value
  end
  return newtable
end

-- draws a particular square in the grid
-- handles empty spaces, colored blocks, and game over darkening
function drawSquare(x, y)
  if board[y+1][x+1] == ' ' then
    color = {255, 255, 255}
  elseif board[y+1][x+1] >= '1' and board[y+1][x+1] <= '7' then
    color = copyTable(colors[tonumber(board[y+1][x+1])])
  end
  
  -- dims the color value by 100 (255 being the brightest)
  if gameover then
    for i = 1, 3 do
      color[i] = color[i] - 100
      if color[i] < 0 then
        color[i] = 0
      end
    end
  end
  
  love.graphics.setColor(color)
  love.graphics.rectangle("fill", (blocksize+1)*x+marginleft,
    (blocksize+1)*y+margintop, blocksize, blocksize)
end

-- gets called each frame to draw the board
function drawBoard()
	for y = 0, height - 1 do
		for x = 0, width - 1 do
      drawSquare(x, y)
		end
	end
end

-- checks for a block existing inside of a piece at a particular rotation
function getCurPieceBlock(x, y, _rotation)
	if x < 1 or y < 1 or x > 4 or y > 4 then
		return false
	end
  
  -- index of piece block - piece block is a 16 character string instead of a 4x4 character string
  -- similar to i = 4 * y + x (basically counting each block from left to right and top to bottom)
	i = (y - 1) * 4 + (x - 1) + 1
  
  -- check if indexed location in piece is not equal to a space
	return pieces[curpiece][_rotation]:sub(i, i) ~= ' '
end

-- gets called each frame to draw the current piece at it's current location and rotation
function drawPiece()
	love.graphics.setColor(colors[curpiece])
	for y = 1, 4 do
		for x = 1, 4 do
			if getCurPieceBlock(x, y, rotation) then
				ix = curposx + x - 2
				iy = curposy + y - 2
				love.graphics.rectangle("fill", (blocksize+1)*ix+marginleft,
					(blocksize+1)*iy+margintop, blocksize, blocksize)
			end
		end
	end
end
