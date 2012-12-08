blocksize = 38
marginleft, margintop = 200, 6
width, height = 10, 15
curpiece = 1
lastmove = 0
rotation = 1

pieceI = {
  "    "..
	"    "..
	"****"..
  "    ",
  
  " *  "..
	" *  "..
	" *  "..
  " *  ",
}

pieceT = {
  "    "..
  " ***"..
  "  * "..
  "    ",

  "  * "..
  " ** "..
  "  * "..
  "    ",

  "  * "..
  " ***"..
  "    "..
  "    ",
  
  "  * "..
  "  **"..
  "  * "..
  "    ",  
}

pieceS = {
  "    "..
  "  **"..
  " ** "..
  "    ",

  " *  "..
  " ** "..
  "  * "..
  "    "
}

pieceZ = {
  "    "..
  " ** "..
  "  **"..
  "    ",
  
  "  * "..
  " ** "..
  " *  "..
  "    "
}

pieceO = {
  "    "..
  " ** "..
  " ** "..
  "    "
}

pieceJ = {
  "    "..
  " *  "..
  " ***"..
  "    ",
  
  "    "..
  " ** "..
  " *  "..
  " *  "..
  
  "    "..
  "  * "..
  "*** "..
  "    ",
  
  "  * "..
  "  * "..
  " ** "..
  "    "
}

pieceL = {
  "    "..
  "  * "..
  "*** "..
  "    ",
  
  " *  "..
  " *  "..
  " ** "..
  "    ",
  
  "    "..
  " ***"..
  " *  "..
  "    ",
  
  "    "..
  " ** "..
  "  * "..
  "  * "
}

pieces = {
  pieceI,
  pieceT,
  pieceS,
  pieceZ,
  pieceO,
  pieceJ,
  pieceL
}

function doesCollide(px, py, _rotation)
	collide = false
	
	for y = 1, 4 do
		for x = 1, 4 do
			if getCurPieceBlock(x, y, _rotation) then
				ix = px + x - 1
				iy = py + y - 1
				if ix < 1 or ix > width or iy < 1 or iy > height then
					collide = true
        elseif board[iy][ix] == '*' then
          collide = true
				end
			end
		end
	end

	return collide
end

function love.draw()
	drawBoard()
	drawPiece()
end

function countOnLine(y)
  c = 0
  for x = 1, width do
    if board[y][x] == '*' then
      c = c + 1
    end
  end
  return c
end

function clearLine(y)
  for x = 1, width do
    board[y][x] = ' '
  end
end

function moveEverythingDown(y)
  i = y
  while i > 1 do
    board[i] = board[i-1]
    i = i - 1
  end
end

function processLines()
  for r = height, 1, -1 do
    if countOnLine(r) == width then
      clearLine(r)
      moveEverythingDown(r)
    end
  end
end

function setPiece()
	for y = 1, 4 do
		for x = 1, 4 do
			if getCurPieceBlock(x, y, rotation) then
				ix = curposx + x - 1
				iy = curposy + y - 1
				board[iy][ix] = '*'
			end
		end
	end
  resetPiece()
  processLines()
end

function love.update(dt)
	lastmove = lastmove + dt
	if lastmove >= 1 then
		lastmove = lastmove - 1
		moveDown()
	end
end

function nextPiece()
  curpiece = math.random(table.getn(pieces))
  rotation = 1
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
  elseif key == " " then rotatePiece()
	end
end

function resetPiece()
  nextPiece()
  curposx, curposy = 4, 1
end

function newgame()
  resetPiece()
	board = {}
	for y = 1,height do
		board[y] = {}
		for x = 1,width do
			board[y][x] = ' '
		end
	end
end

function love.load()
  -- if arg[#arg] == "-debug" then require("mobdebug").start() end
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

function drawBoard()
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			if board[y+1][x+1] == '*' then
				love.graphics.setColor(0, 255, 0)
			else
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.rectangle("fill", (blocksize+1)*x+marginleft,
				(blocksize+1)*y+margintop, blocksize, blocksize)
		end
	end
end

function getCurPieceBlock(x, y, _rotation)
	if x < 1 or y < 1 or x > 4 or y > 4 then
		return false
	end
	i = (y - 1) * 4 + (x - 1) + 1
	return pieces[curpiece][_rotation]:sub(i, i) == "*"
end

function drawPiece()
	love.graphics.setColor(0, 0, 255)
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
