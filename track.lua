
require "box2d"

TrackScene = Core.class(Sprite)

local MAX_SPEED = 10

local width = application:getContentWidth()
local height = application:getContentHeight()

local half_width = width * 0.5
local half_height = height * 0.5

local bg_height = 4 * height + height * 0.5
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
						--Texture.new("images/tree3_00.png", true),
						--Texture.new("images/tree5_00.png", true),
					}
local texture_car = Texture.new("images/orange_car.png", true)

local zoom = 1

local random = math.random
local cos = math.cos
local sin = math.sin
local rad = math.rad

-- Constructor
function TrackScene:init()
	
	application:setBackgroundColor(0x000000)
	
	self.world = b2.World.new(0, 0, true)
	--self.world:addEventListener(Event.BEGIN_CONTACT, self.onBeginContact, self)
	
	self.speed = 0
	self.velocity = {0, -1} -- Velocity vector
	self.inc = 0
	
	local map = Sprite.new()
	self:addChild(map)
	self.map = map
	
	--local camera = Camera.new(map)
	--camera:setDragMode()
	--camera:setFollowMode()
	--camera:setZoom(zoom)
	--self.camera = camera
	
	self:drawBackground()
	
	local dirX, dirY = 1, -1	
	--local posX, posY = -100, -100
	local posX, posY = 270, 200
	local previous_tile, previous_index
	
	self.objects = {}
	self.points = {} -- Polygon shape
	
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
	
	self:addEventListener("enterEnd", self.enterEnd, self)
end

function TrackScene:enterEnd()
	
	-- Create box2d camera
	local camera = Camera.new(self)
	self.camera = camera
	
	self:debugEnabled()
	
	self:drawPlayer()
	self:drawController()
	
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

-- Draw grass background
function TrackScene:drawBackground()
	
	local bg = Shape.new()
	bg:setFillStyle(Shape.TEXTURE, Texture.new("images/grass.png", true, {wrap = Texture.REPEAT}) )    
	bg:beginPath(Shape.NON_ZERO)
	bg:moveTo(-half_width, -bg_height)
	bg:lineTo(3 * width, -bg_height)
	bg:lineTo(3 * width, 2 * height)
	bg:lineTo(-half_width, 2* height)
	bg:lineTo(-half_width, -bg_height)
	bg:endPath()
	
	self.map:addChild(bg)
	
	local  map = self.map
	self.worldWidth = map:getWidth()
	self.worldHeight = map:getHeight()
	
	--print(map:getWidth(), map:getHeight())
	
	
	--[[
	local vertices = {0, 0,
					  0, 400,
					  400, 400,
					  400, 0}
	
	local vertices = {
						-width, -5 * height,
						5 * width, -5 * height,
						5 * width, height,
						-width, height,
						-width, -5 * height
						} ]]--
	--self.world:createTerrain(bg, vertices)
end

-- Draw car player
function TrackScene:drawPlayer()
	local player = Bitmap.new(texture_car)
	player:setAnchorPoint(0.5, 0.5)
	player:setScale(0.5)
	self.player = player
	
	self.map:addChild(player)
	
	player:setPosition(340, 300)
	
	--local camera = self.camera
	--camera:setTarget(player:getPosition())
	--camera:update()
	
	-- Physic player body
	local world = self.world
	local config = {
					type = "dynamic",
					--update = false
				   }
	world:createRectangle(player, config)
	player.body:setPosition(player:getX(), player:getY())
end

-- Draw objects near road
function TrackScene:drawObjects(tile, index)
		
	if (index == 1) then
	
		for a=1, 3 do
			local object_left = Tree.new(texture_trees[1], self)
			object_left:updatePosition(tile:getX() - 50, tile:getY() + (a-1) * 65)
			
			local object_right = Tree.new(texture_trees[1], self)
			object_right:updatePosition(tile:getX() + tile:getWidth() + 50, tile:getY() + (a-1) * 65)
		end
	elseif (index == 4) then
	
		for a=1, 3 do
			local object_up = Tree.new(texture_trees[1], self)
			self.map:addChild(object_up)
			object_up:updatePosition(tile:getX() + (a-1) * 65 + 30, tile:getY() - 45)
			
			local object_down = Tree.new(texture_trees[1], self)
			object_down:updatePosition( tile:getX() + (a-1) * 65 + 30, tile:getY() + tile:getHeight() + 45)
		end
		
	elseif (index == 2) then
		local object1 = Tree.new(texture_trees[1], self)
		object1:updatePosition(tile:getX(), tile:getY())
	elseif (index == 3) then
		local object_up = Tree.new(texture_trees[1], self)
		object_up:updatePosition(tile:getX() + tile:getWidth(), tile:getY())
	elseif (index == 5) then
		local object_up = Tree.new(texture_trees[1], self)
		object_up:updatePosition(tile:getX() + tile:getWidth(), tile:getY() + tile:getHeight())
	elseif (index == 6) then
		local object1 = Tree.new(texture_trees[1], self)
		object1:updatePosition(tile:getX(), tile:getY() + tile:getHeight())
		
		local object2 = Tree.new(texture_trees[1], self)
		object2:updatePosition(tile:getX() - 15, tile:getY() + tile:getHeight() - 100)
		
		local object3 = Tree.new(texture_trees[1], self)
		object3:updatePosition(tile:getX() + 95, tile:getY() + tile:getHeight() + 20)
		
		local object4 = Tree.new(texture_trees[1], self)
		object4:updatePosition(tile:getX() - 45, tile:getY() + tile:getHeight() - 200)
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
	
	--self.world:step(1/30, 8, 3)
	--self.world:update()
		
	self:updatePlayer()
	--self:updateObjects()
	
	self.camera:update()
end

-- Update car player position and rotation
function TrackScene:updatePlayer()
	
	--local camera = self.camera
	local player = self.player
		
	self.speed = self.speed + 0.1
	if (self.speed > MAX_SPEED) then
		self.speed = MAX_SPEED
	end
	
	local speed = self.speed
	
	-- Update player
	--[[
	local rotation = player:getRotation() + self.inc
	if (math.abs(self.inc) > 0 ) then
		rotation = rotation + speed * 0.15 * self.inc
	end
	player:setRotation(rotation)
	]]--
	
	local angle = player.body:getAngle() + rad(self.inc)
	player.body:setAngle(angle)
	--player:setRotation(math.deg(angle))
	
	--rotation = rad(rotation)
	--velocity[1] = speed * sin(rotation)
	--velocity[2] = -speed * cos(rotation)
	
	local velocity = self.velocity
	velocity[1] = speed * sin(angle)
	velocity[2] = -speed * cos(angle)
	
	--player:setX(player:getX() + velocity[1])
	--player:setY(player:getY() +  velocity[2])
	
	--local map = self.map
	--map:setX(map:getX() - velocity[1])
	--map:setY(map:getY() - velocity[2])
		
	player.body:setLinearVelocity(velocity[1], velocity[2])
	
	--self.world:step(1/30, 8, 3)
	self.world:update()
	
	-- Update sprite position and rotation	
	--player:setPosition(player.body:getPosition())
end

-- Update collision objects position
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

function TrackScene:onBeginContact(event)
	--print("begin contact", event)
end

-- Debug box2d
function TrackScene:debugEnabled()
	local debugDraw = b2.DebugDraw.new()
	self.world:setDebugDraw(debugDraw)
	self:addChild(debugDraw)
end