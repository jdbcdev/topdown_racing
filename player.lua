
Player = Core.class(Bitmap)

local MAX_SPEED = 10

-- Constructor
function Player:init(texture, scene)
	
	self.speed = 0
	self.angle = 0
	self.velocity = Vector.new(0, -1) -- Velocity vector
	
	self.index = 1 -- Near point
	self.computer = false
	
	self:setScale(0.5)
	
	-- Physic player body
	local world = scene.world
	if (world) then
		local config = {
					type = "dynamic",
					update = true
					}
		world:createRectangle(self, config)
	end
	
	--self.body:setLinearDamping(0.4)
	self.body:setAngularDamping(0.1)
	
end

function Player:updatePosition(x, y)

	self:setPosition(x, y)
	self.body:setPosition(self:getX(), self:getY())
end

function Player:increaseSpeed()
	self.speed = self.speed + 0.1
	
	if (self.speed > MAX_SPEED) then
		self.speed = MAX_SPEED
	end
	
	return self.speed
end	
