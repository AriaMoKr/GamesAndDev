blocksize = 38
marginleft, margintop = 200, 6
width, height = 10, 15
curpiece = 1
lastmove = 0

pieces = { 
	"****" ..
	"****",

	"****" ..
	"    ", 

	"  * " ..
	" ***",

	"  **" ..
	" ** ",

	" ** " ..
	"  **",

	" ** " ..
	" ** ",

	" *  " ..
	" ***",

	"   *" ..
	" ***"
}

function isBlockOutOfRange(x, y)
	return x < 1 or x > width or y < 1 or y > height
end

function doesCollide(px, py)
	collide = false
	
	for y = 0, 1 do
		for x = 0, 3 do
			if getCurPieceBlock(x, y) then
				ix = curposx + x
				iy = curposy + y
				if isBlockOutOfRange(ix, iy) then
					collide = true
				end
			end
		end
	end

	-- return isBlockOutOfRange(x, y)
	return collide
end

function love.draw()
	drawBoard()
	drawPiece()
end

function love.update(dt)
	lastmove = lastmove + dt
	if lastmove >= 1 then
		lastmove = lastmove - 1
		moveDown()
	end
end

function nextPiece()
	curpiece = curpiece + 1
	if curpiece >= table.getn(pieces) then
		curpiece = 1
	end
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit")
	elseif key == "down" then moveDown()
	elseif key == "left" then moveLeft()
	elseif key == "right" then moveRight()
	elseif key == "return" then nextPiece()
	elseif key == "f11" then love.graphics.toggleFullscreen()
	elseif key == "d" then debug.debug()
	end
end

function love.load()
	curposx, curposy = 1, 1
end

function moveIfNoCollision(x, y)
	if not doesCollide(x, y) then
		curposx = x
		curposy = y
	end
end

function moveDown()
	moveIfNoCollision(curposx, curposy + 1)
end

function moveLeft()
	moveIfNoCollision(curposx - 1, curposy)
end

function moveRight()
	moveIfNoCollision(curposx + 1, curposy)
end

function drawBoard()
	love.graphics.setColor(255, 255, 255)
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			love.graphics.rectangle("fill", (blocksize+1)*x+marginleft,
				(blocksize+1)*y+margintop, blocksize, blocksize)
		end
	end
end

function getCurPieceBlock(x, y)
	if x < 1 or y < 1 or x > 4 or y > 2 then
		return false
	end
	i = (y - 1) * 4 + (x - 1) + 1
	return pieces[curpiece]:sub(i, i) == "*"
end

function drawPiece()
	love.graphics.setColor(0, 0, 255)
	for y = 1, 2 do
		for x = 1, 4 do
			if getCurPieceBlock(x, y) then
				ix = curposx + x - 2
				iy = curposy + y - 2
				love.graphics.rectangle("fill", (blocksize+1)*ix+marginleft,
					(blocksize+1)*iy+margintop, blocksize, blocksize)
			end
		end
	end
end
