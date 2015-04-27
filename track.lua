
require "box2d"

TrackScene = Core.class(Sprite)

local MAX_SPEED = 10

local width = application:getContentWidth()
local height = application:getContentHeight()

local half_width = width * 0.5
local half_height = height * 0.5

local bg_width = 4 * width
local bg_height = 6 * height
local maxY = bg_height - half_height

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
						Texture.new("images/tree_short.png", true),
						Texture.new("images/tree_ugly.png", true)
						--Texture.new("images/tree3_00.png", true),
						--Texture.new("images/tree5_00.png", true),
					}
local texture_car = Texture.new("images/blue_car.png", true)

local zoom = 1

local random = math.random
local cos = math.cos
local sin = math.sin
local rad = math.rad
local deg = math.deg

-- Constructor
function TrackScene:init()
	
	application:setBackgroundColor(0x000000)
	
	self.world = b2.World.new(0, 0, true)
	self.world:addEventListener(Event.BEGIN_CONTACT, self.onBeginContact, self)
	
	self.speed = 0.1
	self.velocity = {0, -1} -- Velocity vector
	self.inc = 0
		
	self:drawBackground()
	self:drawCircuit()
	
	--self:setScale(0.5)
	--self.map:setScale(0.5)

	self:addEventListener("enterEnd", self.enterEnd, self)
end


function TrackScene:enterEnd()
		
	self:debugEnabled()
	
	self:drawPlayer()
	
	-- Create box2d camera following car player
	local camera = Camera.new(self)
	self.camera = camera
	camera:update()
	
	-- Body player car
	--local player = self.player
	--local offsetX, offsetY = self.map:getX(), self.map:getY()
	--player.body:setPosition(player:getX() + offsetX, player:getY() + offsetY)
	
	self:drawController()
	
	--self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:addEventListener("exitBegin", self.onExitBegin, self)
end

-- Draw grass background
function TrackScene:drawBackground()
		
	local map = Sprite.new()
	self:addChild(map)
	self.map = map
	
	local bg = Shape.new()
	bg:setFillStyle(Shape.TEXTURE, Texture.new("images/grass.png", true, {wrap = Texture.REPEAT}) )    
	bg:beginPath(Shape.NON_ZERO)
	bg:moveTo(0,0)
	bg:lineTo(bg_width, 0)
	bg:lineTo(bg_width, bg_height)
	bg:lineTo(0, bg_height)
	bg:lineTo(0, 0)
	bg:endPath()
		
	self.map:addChild(bg)
	
	self.worldWidth = map:getWidth()
	self.worldHeight = map:getHeight()
	
	print(bg_width, bg_height)
	print(self.worldWidth, self.worldHeight)
	
	--local screenW = application:getContentWidth()
	--local screenH = application:getContentHeight()
	
	--set world dimensions 
	--x2 for this example
	--self.worldW = screenW * 2
	--self.worldH = screenH * 2
	
	--create bounding walls to surround world
	--and not screen
	self:wall(0,self.worldHeight/2,10,self.worldHeight/2*2)
	self:wall(self.worldWidth/2,0,self.worldWidth,10)
	self:wall(self.worldWidth,self.worldHeight/2,10,self.worldHeight)
	self:wall(self.worldWidth/2,self.worldHeight,self.worldWidth,10)
end

-- Draw tiled circuit
function TrackScene:drawCircuit()
	local dirX, dirY = 1, -1	
	local posX, posY = 400, 2000
	local previous_tile, previous_index
	
	self.objects = {}
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
		self:drawObjects(tile, index)
		
		previous_tile = tile
		previous_index = index
	end
	
	-- Draw objects over track
	for a=1, #self.objects do
		self.map:addChild(self.objects[a])
	end
end

-- Draw car player
function TrackScene:drawPlayer()
	local player = Bitmap.new(texture_car)
	player:setAnchorPoint(0.5, 0.5)
	player:setScale(0.5)
	self.player = player
	
	self.map:addChild(player)
	
	player:setPosition(450, 2200)
	--player:setPosition(100, 100)
		
	-- Physic player body
	local world = self.world
	local config = {
					type = "dynamic",
					update = false
				   }
	world:createRectangle(player, config)

	--player.body:setLinearDamping(0.4)
	player.body:setAngularDamping(0.1)
	player.body:setPosition(player:getX(), player:getY())
	
	print(player.body:getPosition())
end

-- Draw objects near road
function TrackScene:drawObjects(tile, index)
		
	if (index == 1) then
	
		for a=1, 3 do
			local object_left = Tree.new(texture_trees[random(2)], self)
			object_left:setPosition(tile:getX() - 50, tile:getY() + (a-1) * 65)
			
			local object_right = Tree.new(texture_trees[random(2)], self)
			object_right:setPosition(tile:getX() + tile:getWidth() + 50, tile:getY() + (a-1) * 65)
		end
	elseif (index == 4) then
	
		for a=1, 3 do
			local object_up = Tree.new(texture_trees[random(2)], self)
			self.map:addChild(object_up)
			object_up:setPosition(tile:getX() + (a-1) * 65 + 30, tile:getY() - 45)
			
			local object_down = Tree.new(texture_trees[random(2)], self)
			object_down:setPosition( tile:getX() + (a-1) * 65 + 30, tile:getY() + tile:getHeight() + 45)
		end
		
	elseif (index == 2) then
		local object1 = Tree.new(texture_trees[random(2)], self)
		object1:setPosition(tile:getX(), tile:getY())
	elseif (index == 3) then
		local object_up = Tree.new(texture_trees[random(2)], self)
		object_up:setPosition(tile:getX() + tile:getWidth(), tile:getY())
	elseif (index == 5) then
		local object_up = Tree.new(texture_trees[random(2)], self)
		object_up:setPosition(tile:getX() + tile:getWidth(), tile:getY() + tile:getHeight())
	elseif (index == 6) then
		local object1 = Tree.new(texture_trees[random(2)], self)
		object1:setPosition(tile:getX(), tile:getY() + tile:getHeight())
		
		local object2 = Tree.new(texture_trees[random(2)], self)
		object2:setPosition(tile:getX() - 15, tile:getY() + tile:getHeight() - 100)
		
		local object3 = Tree.new(texture_trees[random(2)], self)
		object3:setPosition(tile:getX() + 95, tile:getY() + tile:getHeight() + 20)
		
		local object4 = Tree.new(texture_trees[random(2)], self)
		object4:setPosition(tile:getX() - 45, tile:getY() + tile:getHeight() - 200)
	end
	
end

-- Draw left and right arrows to handle the car player
function TrackScene:drawController()
		
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
function TrackScene:onEnterFrame()
			
	self:updatePlayer()	
	
	-- Update player sprite
	--[[
	local player = self.player
	local offsetX, offsetY = self.map:getPosition()
	local worldX, worldY = player.body:getPosition()
		
	player:setRotation(deg(player.body:getAngle()))
	
	local velocity = self.velocity
	if (player:getX() > 400) then
		player:setX(player:getX() + velocity[1])
	end
	
	if (player:getY() > 200) then
		player:setY(player:getY() + velocity[2])
	end
	]]--
	
	self.camera:update()
	
end

-- Update car player position and rotation
function TrackScene:updatePlayer()
	
	local player = self.player
		
	self.speed = self.speed + 0.1
	if (self.speed > MAX_SPEED) then
		self.speed = MAX_SPEED
	end
		
	local speed = self.speed
	
	local angle = player.body:getAngle() + rad(self.inc * 2)
	player.body:setAngle(angle)
	
	local velocity = self.velocity
	velocity[1] = speed * sin(angle)
	velocity[2] = -speed * cos(angle)
	player.body:setLinearVelocity(velocity[1], velocity[2])
	
	--local forwardX, forwardY = player.body:getWorldVector(0, -1)
	--player.body:setLinearVelocity(forwardX, 0) --forwardY * 0.01)
	--player.body:setLinearVelocity(forwardX, forwardY * 0.1) --forwardY * 0.01)
	
	--[[
	local posX, posY = player.body:getPosition()
	if (posX < width * 0.5) then
		player.body:setPosition(posX + velocity[1], posY)
	end
	]]--
		
	--[[
	if (angle > -math.pi and angle < math.pi) then
		print("hacia arriba")
		player.body:setPosition(posX + velocity[1], posY)
	elseif (angle >= math.pi and angle < 2 * math.pi) then
		player.body:setPosition(posX, posY + velocity[2])
	end
	]]--
	
	--player.body:setPosition(posX + velocity[1], posY + velocity[2])
	
	--print("angle", angle, velocity[1], velocity[2])
	
	self.world:step(1/30, 8, 3)
	
	--if (not self.collision) then
		player:setRotation(deg(angle))
		--player.body:setLinearVelocity(velocity[1], velocity[2])
		--player:setPosition(player:getX() + velocity[1], player:getY() + velocity[2])
				
		local bodyX, bodyY = player.body:getPosition()
		player:setPosition(bodyX, bodyY)
	--end
	
	--self.collision = false
end

-- Update collision objects position
--[[
function TrackScene:updateObjects()

	local player = self.player
	
	-- Update all objects
	local objects = self.objects
	for a =1, #objects do
		local object = objects[a]
		--object.body:setPosition(object:getX() + half_width - player:getX(), object:getY() + half_height - player:getY())
		object.body:setPosition(object:getX() - player:getX(), object:getY() - player:getY())
	end
end
]]--

function TrackScene:onBeginContact(event)
	--print("begin contact", event)
	--self.speed = 0
		
	self.collision = true
end

-- Debug box2d
function TrackScene:debugEnabled()
	local debugDraw = b2.DebugDraw.new()
	self.world:setDebugDraw(debugDraw)
	self.map:addChild(debugDraw)
end

-- for creating objects using shape
-- as example - bounding walls
function TrackScene:wall(x, y, width, height)
	local wall = Shape.new()
	--define wall shape
	wall:beginPath()
	wall:setFillStyle(Shape.SOLID, 0x0000ff)
	--we make use (0;0) as center of shape,
	--thus we have half of width and half of height in each direction
	wall:moveTo(-width/2,-height/2)
	wall:lineTo(width/2, -height/2)
	wall:lineTo(width/2, height/2)
	wall:lineTo(-width/2, height/2)
	wall:closePath()
	wall:endPath()
	wall:setPosition(x,y)
	
	--create box2d physical object
	local body = self.world:createBody{type = b2.STATIC_BODY}
	body:setPosition(wall:getX(), wall:getY())
	body:setAngle(wall:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(wall:getWidth()/2, wall:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0.8}
	wall.body = body
	wall.body.type = "wall"
	
	--add to scene
	self.map:addChild(wall)
	
	--return created object
	return wall
end

--[[
function TrackScene:onMouseDown(event)
	if self:hitTestPoint(event.x, event.y) then
		local x, y = self.player:getPosition()
		local xVect = (math.random(0,200)-100)*100
		local yVect = (math.random(0,200)-100)*100
		self.player.body:applyForce(xVect, yVect, x, y)
	end
end
]]--

function TrackScene:onExitBegin()
  self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end