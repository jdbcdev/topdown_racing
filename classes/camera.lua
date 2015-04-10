
Camera = Core.class(Sprite)
 
function Camera:init(scene)
 
	self.scene = scene
 
	-- Get screen dimensions
	self.screenWidth = application:getContentWidth()
	self.screenHeight = application:getContentHeight()
 
end
 
function Camera:update()
 
	-- Define offsets
	local offsetX = 0
	local offsetY = 0
	
	local player = self.scene.player
	
	if((self.scene.worldWidth - player:getX()) < self.screenWidth/2) then
		offsetX = -self.scene.worldWidth + self.screenWidth
	elseif(player:getX() >= self.screenWidth/2) then
		offsetX = -(player:getX() - self.screenWidth/2)
	end
 
	--apply offset so scene
	self.scene.map:setX(offsetX)
 
	--check if we are not too close to upper or bottom wall
	--so we won't go further that wall
 
	if((self.scene.worldHeight - player:getY()) < self.screenHeight/2) then
		offsetY = -self.scene.worldHeight + self.screenHeight
	elseif(player:getY()>= self.screenHeight/2) then
		offsetY = -(player:getY() - self.screenHeight/2)
	end
 
	--apply offset so scene
	self.scene.map:setY(offsetY)
 
end