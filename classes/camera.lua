
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
	
	local offsetX = 0
	local offsetY = 0
 
	if((scene.worldWidth - player:getX()) < width * 0.5) then
		offsetX = -scene.worldWidth + width
	elseif(player:getX() >= width * 0.5) then
		offsetX = -(player:getX() - width * 0.5)
	end

	map:setX(offsetX)
	
	if((scene.worldHeight - player:getY()) < height * 0.5) then
		offsetY = -scene.worldHeight + height
	elseif(player:getY()>= height * 0.5) then
		offsetY = -(player:getY() - height * 0.5)
	end

	map:setY(offsetY)	
	
	--print(map:getNumChildren())
	--[[
	for i = 1, map:getNumChildren() do
		--get specific sprite
		local sprite = map:getChildAt(i)
		-- check if sprite HAS a body (ie, physical object reference we added)
		if sprite.body then
			--update position to match box2d world object's position
			--get physical body reference
			local body = sprite.body
			--get body coordinates
			
			local bodyX, bodyY = body:getPosition()
			--print(bodyX, bodyY)
			
			--apply coordinates to sprite
			sprite:setPosition(bodyX, bodyY)
			--apply rotation to sprite
			sprite:setRotation(body:getAngle() * 180 / math.pi)
		end
	end
	]]--
	
	-- Update all box2d static objects
	--[[
	local objects = scene.objects
	for a =1, #objects do
		local object = objects[a]
		object.body:setPosition(object:getX() + map:getX(), object:getY() + map:getY())
	end
	]]--
end