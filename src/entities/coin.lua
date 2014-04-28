local coin = {}

function coin.new(scene, x, y, z)
	local self = {}

	self.name = "Coin"
	self.type = "pickup"
	self.properties = {}

	-- ANCHOR/POSITION/SPRITE VARIABLES
	self.radius = 8
	self.mass = 0.1

	self.x, self.y, self.z = x, y, z
	self.r = 0
	self.width, self.height = 64, 64
	self.sx, self.sy = 1, 1
	self.ox, self.oy = 0, 0
	self.aox, self.aoy = 0, self.radius

	self.boundingbox = {}

	self.scale = (self.sx + self.sy) / 2

	-- PHYSICS OBJECTS
	self.fixtures = {}

	self.fixtures.anchor = love.physics.newFixture(love.physics.newBody(scene.world, self.x, self.y, "dynamic"), love.physics.newCircleShape(self.radius * self.scale), self.mass)
	self.fixtures.anchor:setRestitution(0)
	self.fixtures.anchor:getBody():setLinearDamping(10)
	self.fixtures.anchor:getBody():setFixedRotation(true)
	self.fixtures.anchor:setUserData({type = "player", callbacks = self})


	self.test = {}

	function self.test.beginContact(a, b, contact)
		print("JADÅ!!!")
	end


	function self.setJoystick(joystick)
		self.joystick = joystick
	end



	-- Movement variables
	self.velocity = 700 * self.scale
	self.direction = 0
	self.aim = 0
	self.move = false
	self.state = "stand"

	local cooldown = 0

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(self.x, self.y, self.z)

	-- ANIMATION
	local animation = yama.animations.new()

	-- SPRITE
	--local tileset = "LPC/body/male/light"
	--images.quads.add(tileset, self.width, self.height)

	local tileset = yama.assets.tilesets["coin_1"]
	local se = scene.newSceneEntity()
	se.drawable = tileset.tiles[1]
	se.normalmap = yama.assets.loadImage("coin_1_normalmap")
	se.depthmap = yama.assets.loadImage("coin_1_heightmap")
	

	function self.updatePosition()
	end

	-- DEFAULT FUNCTIONS
	function self.initialize(object)
		info("Coin initialized.")
	end

	function self.update(dt)
		self.x, self.y = self.fixtures.anchor:getBody():getX(), self.fixtures.anchor:getBody():getY()

		se.x = self.x + self.aox
		se.y = self.y + self.aoy
		animation.update(dt, "coin")
		se.drawable = tileset.tiles[animation.frame]
	end

	function self.destroy()
		self.fixtures.anchor:getBody():destroy()
		self.destroyed = true
	end

	function self.setBoundingBox()
		self.boundingbox.x = self.x - (self.ox - self.aox) * self.sx
		self.boundingbox.y = (self.y - (self.oy - self.aoy) * self.sy) - self.height
		self.boundingbox.width = self.width * self.sx
		self.boundingbox.height = self.height * self.sy
	end
	--function self.getBoundingCircle()
	--	local x, y, width, height = self.getBoundingBox()
	--	local cx, cy = x + width / 2, y + height / 2
	--	local radius = yama.tools.getDistance(x, y, cx, cy)

	--	return cx, cy, radius
	--end


	self.setBoundingBox()

	return self
end

return coin