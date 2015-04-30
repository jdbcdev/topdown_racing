
Tree = Core.class(Bitmap)

function Tree:init(texture, scene)

	self.scene = scene
	self:setScale(0.8)
	self:setAnchorPoint(0.5, 0.5)
	
	self.width = self:getWidth()
	self.height = self:getHeight() - 10
	
	local world = scene.world
	if (world) then
		local config = {
					type = b2.DYNAMIC_BODY,
					update = false
				   }
		--world:createRectangle(self, config)
		world:createCircle(self, config)
	end
	
	local objects = scene.objects
	table.insert(objects, self)
end