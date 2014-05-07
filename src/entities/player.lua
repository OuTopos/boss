local yama = require("lib.yama")
local player = {}

function player.new(map, x, y, z)
	local self = {}
	local scene = map

	self.world = scene.world

	self.name = ""
	self.type = "player"

	self.health = 100

	self.properties = {}

	self.projectileSpawnCooldown = 0

	-- ANCHOR/POSITION/SPRITE VARIABLES
	self.radius = 10
	self.mass = 1

	self.x, self.y, self.z = x, y, z
	self.r = 0
	self.width, self.height = 64, 64
	self.sx, self.sy = 1, 1
	self.ox, self.oy = 32, 0
	self.aox, self.aoy = 0, self.radius
	self.sprite = nil

	self.boundingbox = {}

	self.scale = (self.sx + self.sy) / 2

	self.buttonStates = {}

	function self.setJoystick(joystick)
		self.joystick = joystick
	end

	function self.setMask(mask)
		self.mask = mask		
	end

	self.skills = {}

	function self.setSkill(slot, skill)
		self.skills[slot] = skill
	end

	-- Movement variables
	self.velocity = 700 * self.scale
	self.direction = 0
	self.aim = 0
	self.move = false
	self.state = "stand"

	local cooldown = 0

	-- BUFFER BATCH
	-- local bufferBatch = yama.buffers.newBatch(self.x, self.y, self.z)

	-- ANIMATION
	local animation = yama.newAnimation()

	local tileset = yama.assets.tilesets["body"]
	local sprite = scene.newSceneEntity()

	sprite.drawable = tileset.tiles[1]
	sprite.normalmap = yama.assets.loadImage("lightingtest/body_normal")
	sprite.depthmap = yama.assets.loadImage("lightingtest/body_depth")

	-- local tilesetArrow = "directionarrow"
	--images.load(tilesetArrow):setFilter("linear", "linear")
	-- local spriteArrow = yama.buffers.newDrawable(yama.assets.loadImage(tilesetArrow), self.x, self.y-16, 640, 1, self.sx, self.sy, -24, 12)
	--sprite.shader = glow_effect

	-- table.insert(bufferBatch.data, sprite)

	function self.updateInput(dt)
					
		local nx, ny = 0, 0
		local fx, fy = 0, 0
		local vmultiplier = 1

		animation.timescale = 1

		self.state = "stand"
		self.fixtures.weapon:setMask(16)

		if self.state == "stand" or self.state == "walk" then

			if yama.tools.getDistance(0, 0, self.joystick:getAxis(1), self.joystick:getAxis(2)) > 0.2 then
				self.state = "walk"
				nx = self.joystick:getAxis(1)
				ny = self.joystick:getAxis(2)
				
				self.direction = math.atan2(ny, nx)

				vmultiplier = yama.tools.getDistance(0, 0, self.joystick:getAxis(1), self.joystick:getAxis(2))
				if vmultiplier >  1 then
					vmultiplier = 1
				end			
			end
			
			if yama.tools.getDistance(0, 0, self.joystick:getAxis(3), self.joystick:getAxis(4)) > 0.2 then
				nx = self.joystick:getAxis(3)
				ny = self.joystick:getAxis(4)

				self.aim = math.atan2(ny, nx)
			end

		end

		if self.state == "walk" then
			if love.keyboard.isDown("lshift") or self.joystick:isDown(5) then
				vmultiplier = vmultiplier * 3
			end
			fx = self.velocity * vmultiplier * math.cos(self.direction)
			fy = self.velocity * vmultiplier * math.sin(self.direction)
			self.fixtures.anchor:getBody():applyForce(fx, fy)
			animation.timescale = vmultiplier
		end

		self.fixtures.anchor:getBody():setAngle(self.aim)

		if self.state == "sword" then
			animation.timescale = 0.1
		end

		--if yama.tools.getDistance(0, 0, love.joystick.getAxis(self.joystick, 4), love.joystick.getAxis(self.joystick, 5)) > 0.2 then
		if false then
			local nx = love.joystick.getAxis(self.joystick, 4)
			local ny = love.joystick.getAxis(self.joystick, 5)
			self.aim = math.atan2(ny, nx)
		end

		nx, ny = nil, nil
		fx, fy = nil, nil
		vmultiplier = nil
	end

	function self.gamepaddown( button )
		if self.skills[button] then
			self.skills[button].execute()
		end
	end

	function self.gamepadpressed( button )
		if self.skills[button] then
			print('gamepadpressed', button)
			self.skills[button].execute()
		end
	end
	function self.gamepadreleased( button )
		if self.skills[button] then
			print('gamepadpressed', button)
			if button == 'lefttrigger' then
				self.skills[button].execute()
			end
		end
	end

	function self.updatePosition()

		-- Position updates
		--self.x, self.y = map.translatePosition(self.fixtures.anchor:getBody():getX(), self.fixtures.anchor:getBody():getY())
		self.x, self.y = self.fixtures.anchor:getBody():getX(), self.fixtures.anchor:getBody():getY()
		--self.x, self.y = math.floor(self.x + 0.5), math.floor(self.y + 0.5)
		--self.fixtures.anchor:getBody():setAngle(self.direction)

		-- yama.buffers.setBatchPosition(bufferBatch, self.x + self.aox, self.y + self.aoy)

		sprite.x = self.x + self.aox
		sprite.y = self.y + self.aoy

		-- spriteArrow.x = self.x --math.floor(x + 0.5)
		-- spriteArrow.y = self.y-16 --math.floor(y-16 + 0.5)
		-- spriteArrow.r = self.aim


		--particle:setPosition(self.getX(), self.getY()-oy/2)
	end

	-- CONTACT
	function self.beginContact(a, b, contact)
		local userdata = b:getUserData()
		if userdata then
		--	print("Player Begin Contact: "..userdata.type)
			if userdata.type == "portal" then
				self.teleport(userdata.properties.map, userdata.properties.spawn)
			end
		end

		userdata = nil
	end

	function self.endContact(a, b, contact)
	end

	function self.attack()
	end

	-- Basic functions
	function self.setPosition(x, y)
		self.fixtures.anchor.body:setPosition(x, y)
		self.fixtures.anchor.body:setLinearVelocity(0, 0)
	end
	
	function self.getPosition()
		return x, y
	end

	function self.getXvel()
		return xvel
	end
	function self.getYvel()
		return yvel
	end 

	function self.teleport(mapname, spawn)
		local newMap = yama.maps.load(mapname)
		local newEntity = newMap.spawn(self.type, spawn)
		if self.vp then
			self.vp.connect(newMap, newEntity)
		end
		self.destroy()
	end

	-- DEFAULT FUNCTIONS
	function self.initialize(properties)
		if properties then
			self.name = properties.name
		end

		-- PHYSICS OBJECTS
		self.fixtures = {}

		self.fixtures.anchor = love.physics.newFixture(love.physics.newBody(self.world, self.x, self.y, "dynamic"), love.physics.newCircleShape(self.radius * self.scale), self.mass)
		self.fixtures.anchor:setRestitution(0)
		self.fixtures.anchor:getBody():setLinearDamping(10)
		self.fixtures.anchor:getBody():setFixedRotation(true)
		self.fixtures.anchor:setUserData({type = "pawn", callbacks = self, name = properties.name })
		self.fixtures.anchor:setGroupIndex( 1 )
		self.fixtures.anchor:setCategory( 1 )
		--self.fixtures.anchor:setMask( 2 )

		self.weapon = {}
		self.weapon.data = {}
		self.weapon.data.callbacks = self.test
		self.weapon.data.type = "damage"
		self.weapon.data.properties = {}
		self.weapon.data.properties.physical = 3

		self.fixtures.weapon = love.physics.newFixture(self.fixtures.anchor:getBody(), love.physics.newPolygonShape(0, 0, 16, -16, 32, -16, 32, 16, 16, 16), 0)
		-- self.fixtures.weapon:setUserData(self.weapon.data)
		self.fixtures.weapon:setSensor(true)
		self.fixtures.weapon:setMask(16)		
		
		print("zUG ZUG ZU GU ZUUSUZG ".. properties.name)

		print("PLAYER INITAD", self.fixtures.anchor.type())

	end

	function self.update(dt)
		for k,v in pairs(self.skills) do
			v.update(dt)
		end

		cooldown = cooldown - dt
		self.updateInput(dt)
		self.updatePosition()

		local a = nil

		if self.move then
			a = "walk"
		else
			a = "stand"
		end
		if self.state == "walk" or self.state == "stand" or self.state == "sword" then
			animation.update(dt, "humanoid_"..self.state.."_"..yama.tools.getRelativeDirection(self.aim))
		else
			animation.update(dt, "humanoid_die")
		end
		sprite.drawable = tileset.tiles[animation.frame]

		self.setBoundingBox()

		a = nil

		scene.lights.position[1] = {math.floor(self.x + 0.5), math.floor(self.y + 0.5), 64}

	end

	function self.addToBuffer(vp)
		vp.addToBuffer(bufferBatch)
		vp.addToBuffer(spriteArrow)
		--vp.getBuffer().add(fx)
	end

	function self.destroy()
		print("Destroying player")
		self.fixtures.anchor:getBody():destroy()
		self.fixtures.weapon:getBody():destroy()
		self.destroyed = true
	end

	-- GET
	--function self.getType()
	--	return self.type
	--end
	--function self.getPosition()
	--	return self.x, self.y, self.z
	----end
	function self.setBoundingBox()
		self.boundingbox.x = self.x - (self.ox - self.aox) * self.sx
		self.boundingbox.y = (self.y - (self.oy - self.aoy) * self.sy) - self.height
		self.boundingbox.width = self.width * self.sx
		self.boundingbox.height = self.height * self.sy

	--	--return x, y, width, height
	end

	function self.damage(damage)
		self.health = self.health - damage
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

return player