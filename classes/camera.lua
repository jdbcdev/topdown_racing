
Camera = Core.class(Sprite)

local width = application:getContentWidth()
local height = application:getContentHeight()

function Camera:init(scene)
 
	self.scene = scene
 
	-- Get screen dimensions
	--self.screenWidth = application:getContentWidth()
	--self.screenHeight = application:getContentHeight()
 
end
 
function Camera:update()
	
	local scene = self.scene
	local map = scene.map
	local player = scene.player
	
	--define offsets
 
	local offsetX = 0
	local offsetY = 0
 
	if((scene.worldWidth - player:getX()) < width * 0.5) then
		offsetX = -scene.worldWidth + width
	elseif(player:getX() >= width * 0.5) then
		offsetX = -(player:getX() - width * 0.5)
	end
 
	--apply offset so scene
	scene.map:setX(offsetX)
	
	--print("offsetX", offsetY)
	--check if we are not too close to upper or bottom wall
	--so we won't go further that wall
 
	if((scene.worldHeight - player:getY()) < height * 0.5) then
		offsetY = -scene.worldHeight + height
	elseif(player:getY()>= height * 0.5) then
		offsetY = -(player:getY() - height * 0.5)
	end
	
	scene.map:setY(offsetY)
		
	-- Update all box2d static objects
	local objects = scene.objects
	for a =1, #objects do
		local object = objects[a]
		object.body:setPosition(object:getX() + map:getX(), object:getY() + map:getY())
	end
	
	player.body:setPosition(player:getX() + offsetX, player:getY() + offsetY)
	
	--local worldX, worldY = player.body:getPosition()
	--player:setPosition(player.body:get
	
	--map:setPosition(-player:getX() + width * 0.5, -player:getY() + height * 0.5)
end