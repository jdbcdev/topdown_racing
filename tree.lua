
Tree = Core.class(Bitmap)

function Tree:init(texture, scene)

	self.scene = scene
	self:setScale(0.8)
	self:setAnchorPoint(0.5, 0.5)
	
	local world = scene.world
	local config = {
					type = b2.DYNAMIC_BODY,
					update = false
				   }
	world:createRectangle(self, config)
	
	local objects = scene.objects
	table.insert(objects, self)
	
	local points = scene.points
	--table.insert(points, 
end

-- Update position
function Tree:updatePosition(x, y)
	self:setPosition(x, y)
	
	--local worldX, worldY = self.scene.camera:translate(x,y)
	--self.body:setPosition(worldX, worldY)
end