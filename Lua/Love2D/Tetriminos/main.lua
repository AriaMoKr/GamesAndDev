-- initial global variable values
blocksize = 38
marginleft, margintop = 200, 6
width, height = 10, 15
curpiece = 1
lastmove = 0
rotation = 1
gameover = false

-- color table used by pieces - red, gree, and blue ( 0 to 255 )
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

-- draws each frame
function love.draw()
	drawBoard()
	drawPiece()
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

function dropPiece()
  while not doesCollide(curposx, curposy+1, rotation) do
    moveDown()
  end
end

function rotatePiece()
  newrotation = rotation + 1
  if newrotation > table.getn(pieces[curpiece]) then
    newrotation = 1
  end
  if not doesCollide(curposx, curposy, newrotation) then
    rotation = newrotation
  end
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit")
	elseif key == "down" then moveDown()
	elseif key == "left" then moveLeft()
	elseif key == "right" then moveRight()
	elseif key == "return" then dropPiece()
	elseif key == "f11" then love.graphics.toggleFullscreen()
	elseif key == "d" then debug.debug()
  elseif key == "r" then newgame()
  elseif key == " " then rotatePiece()
	end
end

function newPiece()
  curpiece = math.random(table.getn(pieces))
  rotation = 1
  curposx, curposy = 4, 1
  if doesCollide(curposx, curposy, rotation) then
    gameover = true
  end
end

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

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end
	newgame()
end

function moveIfNoCollision(x, y)
	if not doesCollide(x, y, rotation) then
		curposx = x
		curposy = y
	end
end

function moveDown()
  if doesCollide(curposx, curposy+1, rotation) then
    setPiece()
  else
    moveIfNoCollision(curposx, curposy + 1)
  end
  lastmove = 0
end

function moveLeft()
	moveIfNoCollision(curposx - 1, curposy)
end

function moveRight()
	moveIfNoCollision(curposx + 1, curposy)
end

function copyTable(t)
  newtable = {}
  for key, value in pairs(t) do
    newtable[key] = value
  end
  return newtable
end

function drawSquare(x, y)
  if board[y+1][x+1] == ' ' then
    color = copyTable({255, 255, 255})
  elseif board[y+1][x+1] >= '1' and board[y+1][x+1] <= '7' then
    color = copyTable(colors[tonumber(board[y+1][x+1])])
  else
    return
  end
  
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

function drawBoard()
	for y = 0, height - 1 do
		for x = 0, width - 1 do
      drawSquare(x, y)
		end
	end
end

function getCurPieceBlock(x, y, _rotation)
	if x < 1 or y < 1 or x > 4 or y > 4 then
		return false
	end
	i = (y - 1) * 4 + (x - 1) + 1
	return pieces[curpiece][_rotation]:sub(i, i) ~= ' '
end

function drawPiece()
  if gameover then
    return
  end
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
