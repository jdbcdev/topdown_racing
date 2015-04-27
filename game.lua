
GameScene = Core.class(Sprite)

local MAX_SPEED = 10

local width = application:getContentWidth()
local height = application:getContentHeight()

local half_width = width * 0.5
local half_height = height * 0.5

local bg_height = 6 * height
local maxY = bg_height - half_height

local senseX = 1
local senseY = -1

--[[
local track = {
				--1, 1, 1, 2, 4, 
				--5, 1, 1
				1, 2, 4, 4, 5, 1, 1, 2, 4, 4, 5, 1, 3, 4, 4, 6,
				1, 1, 1
				}
]]--

local track = {
				1, 1, 1, 1, 1, 1, 1, 1, 2,
				4, 4, 4, 4, 4, 4, 4, 4, 3,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 5,
				4, 4, 4, 4, 4, 4, 4, 4, 6, 1
				
				}
local textures = {
					Texture.new("images/tile1.png", true),
					Texture.new("images/tile2.png", true),
					Texture.new("images/tile3.png", true),
					Texture.new("images/tile4.png", true),
					Texture.new("images/tile5.png", true),
					Texture.new("images/tile6.png", true),
				}	

local texture_left = Texture.new("images/left.png", true)
local texture_right = Texture.new("images/right.png", true)
local texture_goal = Texture.new("images/goal.png", true)
local texture_trees = {
						--Texture.new("images/block_grass.png", true),
						Texture.new("images/tree_short.png", true),
						Texture.new("images/tree_ugly.png", true)
						
						--Texture.new("images/tree3_00.png", true),
						--Texture.new("images/tree5_00.png", true),
					}
local texture_car = Texture.new("images/orange_car.png", true)

local zoom = 1

local random = math.random
local cos = math.cos
local sin = math.sin
local rad = math.rad
local deg = math.deg

--local oBoxToObox = tntCollision.oBoxToObox
--local setCollisionAnchorPoint = tntCollision.setCollisionAnchorPoint
--local pointToBox = tntCollision.pointToBox
--local circleToCircle = tntCollision.circleToCircle

local function checkForIntersection(rectangle1, rectangle2)
 
   local function chkForRotated(r1, r2)
   
      local x1 = r2:getX()-r1:getX()
      local y1 = r2:getY()-r1:getY()
 
      local x2 = x1*math.cos(math.rad(r1:getRotation())) + y1*math.sin(math.rad(r1:getRotation()))
      local y2 = y1*math.cos(math.rad(r1:getRotation())) - x1*math.sin(math.rad(r1:getRotation()))
 
      local angle1 = math.cos(math.rad(r2:getRotation() - r1:getRotation()))
      local angle2 = math.sin(math.rad(r2:getRotation() - r1:getRotation()))
      local arr1 = { r2.width*angle1, -r2.height*angle2, r2.width*angle1 - r2.height*angle2}
      local arr2 = { r2.width*angle2, r2.height*angle1, r2.width*angle2 + r2.height*angle1}
 
      local minX = 0 
      local maxX = 0
      local minY = 0
      local maxY = 0
      for i=1,3 do
                if minX > arr1[i] then
                        minX = arr1[i]
                end
                if maxX <  arr1[i] then
                         maxX = arr1[i]
                end
                if minY > arr2[i] then
                        minY = arr2[i]
                end
                if maxY <  arr2[i] then
                         maxY = arr2[i]
                end
      end
 
      return x2 + maxX < 0 or x2 + minX > r1.width or y2 + maxY < 0 or y2 + minY > r1.height
   end
   return not (chkForRotated(rectangle1,rectangle2) or chkForRotated(rectangle2,rectangle1))
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- Constructor
function GameScene:init()
	
	application:setBackgroundColor(0x000000)
	
	--setCollisionAnchorPoint(0.5, 0.5)
	
	--self.world = b2.World.new(0, 0, true)
	--self.world:addEventListener(Event.BEGIN_CONTACT, self.onBeginContact, self)
	
	self.speed = 1
	self.velocity = {0, -1} -- Velocity vector
	self.inc = 0
		
	self:drawBackground()
	self:drawCircuit()
	
	--self:setScale(0.5)
	--self.map:setScale(0.5)

	self:addEventListener("enterEnd", self.enterEnd, self)
end


function GameScene:enterEnd()
			
	self:drawPlayer()
	
	-- Create box2d camera following car player
	local camera = Camera.new(self)
	self.camera = camera
	camera:update()
	
	self:drawController()
	
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- Draw grass background
function GameScene:drawBackground()
	
	local map = Sprite.new()
	self:addChild(map)
	self.map = map
	
	local bg = Shape.new()
	bg:setFillStyle(Shape.TEXTURE, Texture.new("images/grass.png", true, {wrap = Texture.REPEAT}) )    
	bg:beginPath(Shape.NON_ZERO)
	bg:moveTo(0,0)
	bg:lineTo(4 * width, 0)
	bg:lineTo(4 * width, bg_height)
	bg:lineTo(0, bg_height)
	bg:lineTo(0, 0)
	bg:endPath()
		
	self.map:addChild(bg)
	
	self.worldWidth = map:getWidth()
	self.worldHeight = map:getHeight()
	
	print(self.worldWidth, self.worldHeight)
	
end

-- Draw tiled circuit
function GameScene:drawCircuit()
	local dirX, dirY = 1, -1	
	local posX, posY = 270, 2000
	local previous_tile, previous_index
	
	self.objects = {}
	self.limits = {}
	self.points = {} -- Polygon shape
	
	local map = self.map
	
	for a=1, #track do
		local index = track[a]
		local tile = Bitmap.new(textures[index])
		map:addChild(tile)
		
		if (a > 1) then
			if (index == 1) then
				
				if (previous_index == 5) then
					posY = posY - tile:getHeight() 
					posX = posX + 16
					dir = -1
				elseif (previous_index == 3) then
					posX = posX + 16
					posY = posY + previous_tile:getHeight()
					dir = 1
				else
					posY = posY + dirY * tile:getHeight()
				end
			elseif (index == 2) then
				posY = posY - tile:getHeight() 
			elseif (index == 3) then
			
				if (previous_index == 1) then
					posX = posX - 16 * scale
					posY = posY - tile:getHeight()
				else
					posX = posX + previous_tile:getWidth()
					dirY = 1
				end
				
			elseif (index == 4) then
				if (previous_index == 2) then
					posX = posX + previous_tile:getWidth() * dirX
				elseif (previous_index == 5) then
					posX = posX - tile:getWidth()
					posY = posY + 16
				else
					posX = posX + previous_tile:getWidth() * dirX
				end
			elseif (index == 5) then
			
				if (previous_index == 1) then
					posX = posX - 16
					posY = posY + previous_tile:getHeight()
					dirX = -1
				else
					posX = posX + previous_tile:getWidth()
					posY = posY - 16
				end
			elseif (index == 6) then
				posX = posX + tile:getWidth() * dirX
				posY = posY - 16
				
				dirY = -1
			end
		else		
			-- Draw goal
			local goal = Bitmap.new(texture_goal)
			goal:setPosition(posX + 25, posY)
			
			map:addChild(goal)
		end
		
		tile:setPosition(posX, posY)
		
		-- Draw trees and other collision objects
		self:drawObjects(tile, index, a)
		
		previous_tile = tile
		previous_index = index
	end
	
	-- Draw objects over track
	for a=1, #self.objects do
		self.map:addChild(self.objects[a])
	end
	
	self:drawLimits()
end

-- Draw car player
function GameScene:drawPlayer()
	local player = Bitmap.new(texture_car)
	player:setAnchorPoint(0.5, 0.5)
	player:setScale(0.5)
	self.player = player
	
	self.map:addChild(player)
	
	player:setPosition(340, 2200)
	player.width = player:getWidth() - 5
	player.height = player:getHeight() - 10
end

-- Draw objects near road
function GameScene:drawObjects(tile, tile_index, track_index)
	
	local next_index, next_tile
	
	if (track_index < #track) then
	
		--print(textures)
		next_index = track[track_index + 1]
		next_tile = Bitmap.new(textures[next_index])
	else
		next_index = track[1]
		next_tile = Bitmap.new(textures[1])
	end
	
	local points = {}
	local offset = 15
	
	if (tile_index == 1) then
	
		for a=1, 3 do
			--if (next_index == 1) then
			
				local object_left = Tree.new(texture_trees[random(2)], self)
				object_left:setPosition(tile:getX() - 60, tile:getY() + (a-1) * 65)
			
				local object_right = Tree.new(texture_trees[random(2)], self)
				object_right:setPosition(tile:getX() + tile:getWidth() + 60, tile:getY() + (a-1) * 65)
			--end
		end
		
		points[1] = { tile:getX() - offset, tile:getY() }
		points[2] = { tile:getX() - offset, tile:getY() + tile:getHeight() }
		points[3] = { tile:getX() + tile:getWidth() + offset, tile:getY()}
		points[4] = { tile:getX() + tile:getWidth() + offset, tile:getY() + tile:getHeight() }
		
	elseif (tile_index == 4) then
	
		for a=1, 3 do
			
			--if (next_index == 4) then
				local object_up = Tree.new(texture_trees[random(2)], self)
				self.map:addChild(object_up)
				object_up:setPosition(tile:getX() + (a-1) * 65 + 50, tile:getY() - 45)			
			
				local object_down = Tree.new(texture_trees[random(2)], self)
				object_down:setPosition( tile:getX() + (a-1) * 65 + 30, tile:getY() + tile:getHeight() + 60)
			--end
		end
		
		points[1] = { tile:getX(), tile:getY() - offset }
		points[2] = { tile:getX() + tile:getWidth(), tile:getY() - offset }
		points[3] = { tile:getX(), tile:getY() + tile:getHeight() + offset }
		points[4] = { tile:getX() + tile:getWidth(), tile:getY() + tile:getHeight() + offset }
		
	elseif (tile_index == 2) then
		local object1 = Tree.new(texture_trees[1], self)
		object1:setPosition(tile:getX(), tile:getY())
		
		points[1] = { tile:getX() - offset, tile:getY() + tile:getHeight() }
		points[2] = { tile:getX() + 40, tile:getY() - 20 }
		points[3] = { tile:getX() + tile:getWidth(), tile:getY() - offset }
		
	elseif (tile_index == 3) then
		local object_up = Tree.new(texture_trees[1], self)
		object_up:setPosition(tile:getX() + tile:getWidth(), tile:getY())
		
		points[1] = { tile:getX(), tile:getY() - offset}
		points[2] = { tile:getX() + tile:getWidth() - 40, tile:getY() + 20}
		points[3] = { tile:getX() + tile:getWidth() + offset, tile:getY() + tile:getHeight()}
		
	elseif (tile_index == 5) then
		local object_up = Tree.new(texture_trees[1], self)
		object_up:setPosition(tile:getX() + tile:getWidth(), tile:getY() + tile:getHeight())
		
		points[1] = { tile:getX() + tile:getWidth() + offset, tile:getY()}
		points[2] = { tile:getX() + tile:getWidth() - 40, tile:getY() + tile:getHeight() - 20}
		points[3] = { tile:getX(), tile:getY() + tile:getHeight() + offset}
		--points[4] = { tile:getX(), tile:getY() + tile:getHeight() + offset}
		
	elseif (tile_index == 6) then
		local object1 = Tree.new(texture_trees[1], self)
		object1:setPosition(tile:getX(), tile:getY() + tile:getHeight())
		
		local object2 = Tree.new(texture_trees[1], self)
		object2:setPosition(tile:getX() - 15, tile:getY() + tile:getHeight() - 100)
		
		local object3 = Tree.new(texture_trees[1], self)
		object3:setPosition(tile:getX() + 95, tile:getY() + tile:getHeight() + 20)
		
		local object4 = Tree.new(texture_trees[1], self)
		object4:setPosition(tile:getX() - 45, tile:getY() + tile:getHeight() - 200)
		
		points[1] = { tile:getX() + tile:getWidth(), tile:getY() + tile:getHeight() + offset }
		points[2] = { tile:getX() + 40, tile:getY() + tile:getHeight() - 20}
		points[3] = { tile:getX() - offset, tile:getY()}
	end
	
	-- Insert points into the limits shape
	for a=1, #points do
		local point = points[a]
		if (not table.contains(self.limits, point)) then
			table.insert(self.limits, points[a])
		end
	end
	
end

-- Draw limits of the track
function GameScene:drawLimits()
	
	local limits = self.limits
	print("#self.limits", limits)
	
	for a=1, #limits do
		print(limits[a][1], limits[a][2])
	end
	
	local shape = Shape.new()
	--shape:setFillStyle(Shape.SOLID, 0xff0000)
	shape:setLineStyle(2, 0xff0000, 1)
	shape:drawPoly(limits)
	self.map:addChild(shape)
end

-- Draw left and right arrows to handle the car player
function GameScene:drawController()
		
	local icon_left = Bitmap.new(texture_left)
	icon_left:setPosition(20, 360)
	icon_left:addEventListener(Event.MOUSE_DOWN,
						function(event)
							if (icon_left:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.inc = -1
								self.speed = self.speed - 1
								
								if (self.speed < 0) then
									self.speed = 0
								end
							end
						end)
							
	icon_left:addEventListener(Event.MOUSE_UP,
						function(event)
							if (icon_left:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.inc = 0
							end
						end)
							
	self:addChild(icon_left)
	
	local icon_right = Bitmap.new(texture_right)
	icon_right:setPosition(700, 360)
	icon_right:addEventListener(Event.MOUSE_DOWN,
						function(event)
							if (icon_right:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.inc = 1
								self.speed = self.speed - 1
								
								if (self.speed < 0) then
									self.speed = 0
								end
							end
						end)
							
	icon_right:addEventListener(Event.MOUSE_UP,
						function(event)
							if (icon_right:hitTestPoint(event.x, event.y)) then
								event:stopPropagation()
								self.inc = 0
							end
						end)
							
	self:addChild(icon_right)
end

-- Update camera and car player
function GameScene:onEnterFrame()
			
	self:updatePlayer()
	self.camera:update()
end

-- Update car player position and rotation
function GameScene:updatePlayer()
	
	local player = self.player
	
	self.speed = self.speed + 0.1
	if (self.speed > MAX_SPEED) then
		self.speed = MAX_SPEED
	end
		
	local speed = self.speed
	
	local angle = rad(player:getRotation() + self.inc * 2)
	local velocity = self.velocity
	velocity[1] = speed * sin(angle)
	velocity[2] = -speed * cos(angle)
		
	local newX, newY = player:getX() + velocity[1], player:getY() + velocity[2]
	local collision = self:checkCollision(newX, newY, deg(angle))
	if (not collision) then 
		-- Update angle and player position
		player:setRotation(deg(angle))
		player:setPosition(newX, newY)
	end
		
end

-- Check car player and objects collision
function GameScene:checkCollision(boxAx, boxAy, boxAangle)
	
	local player = self.player
	--local boxAx, boxAy = player:getPosition()
	local boxAw, boxAh = player:getWidth(), player:getHeight()
	--local boxAangle = player:getRotation()
	
	local objects = self.objects
	--print("#objects", #objects)
	
	for a=1, #objects do
		
		local object = objects[a]
		
		local boxBx, boxBy = object:getPosition()
		local boxBw, boxBh = object:getWidth(), object:getHeight()
		local boxBangle = object:getRotation()

		--local collision = oBoxToObox(boxAx, boxAy, boxAw, boxAh, boxAangle, 
		--						boxBx, boxBy, boxBw, boxBh, boxBangle)
		
		--local collision = checkForIntersection(player, object)
		local collision = false
		
		local pointX = boxAx + boxAw * 0.5
		local pointY = boxAy + boxAw * 0.5
		--local collision = pointToBox(pointX, pointY, boxBx, boxBy, boxBw, boxBh)
		--local collision = circleToCircle(boxAx, boxAy, boxAh * 0.5, boxBx, boxBy, boxBw * 0.5)

		-- Collision response
		if (collision) then
		
			-- Response collision	
			local angle = rad(boxAangle)
			--if (angle > - math.pi and angle < math.pi) then
				
				--[[
				if (boxAx < boxBx) then
					-- Move to the left
					player:setX(player:getX() - 1)
					--player:setRotation(-player:getRotation() * 0.05)
				elseif (boxAx > boxBx) then
					player:setX(player:getX() + 1)
					--player:setRotation(-player:getRotation() * 0.05)
				end
				
				if (boxAy < boxBy) then
					-- Move to the down
					
					player:setY(player:getY() + 1)
				elseif (boxAy > boxBy) then
					player:setY(player:getY() - 1)
					--player:setRotation(-player:getRotation() * 0.1)
				end
				]]--
				
				if (boxAx < boxBx) then	
					player:setX(player:getX() - 1)
				else
					player:setX(player:getX() + 1)
				end
				
				if (boxAy < boxBy) then
					player:setY(player:getY() - 1)
				else
					player:setY(player:getY() + 1)
				end
				
				
			--end
			
			return true
		end
	end
	
	return false
end