local boss = {}

function boss.new(map, x, y, z)
	local self = {}
	local scene = map

	self.world = map.world

	self.name = "The Boss Name"
	self.type = "boss"
	self.properties = {}

	self.health = 50

	-- ANCHOR/POSITION/SPRITE VARIABLES
	self.radius = 10
	self.mass = 1

	self.x, self.y, self.z = x, y, z
	self.r = 0
	self.width, self.height = 64, 64
	self.sx, self.sy = 5, 5
	self.ox, self.oy = 32, 0
	self.aox, self.aoy = 0, self.radius
	self.sprite = nil

	self.boundingbox = {}

	self.scale = (self.sx + self.sy) / 2

	-- PHYSICS OBJECTS
	self.fixtures = {}

	self.fixtures.anchor = love.physics.newFixture(love.physics.newBody(self.world, self.x, self.y, "dynamic"), love.physics.newCircleShape(self.radius * self.scale), self.mass)
	self.fixtures.anchor:setRestitution(0)
	self.fixtures.anchor:getBody():setLinearDamping(10)
	self.fixtures.anchor:getBody():setFixedRotation(true)
	self.fixtures.anchor:setUserData({type = "pawn", callbacks = self, name = "i am the boss"})


	self.test = {}
	self.projectileSpawnCooldown = 0

	function self.test.beginContact(a, b, contact)
		print("JADÅ!!!")
	end


	function self.setJoystick(joystick)
		self.joystick = joystick
	end



	self.weapon = {}
	self.weapon.data = {}
	self.weapon.data.callbacks = self.test
	self.weapon.data.type = "damage"
	self.weapon.data.properties = {}
	self.weapon.data.properties.physical = 3

	self.fixtures.weapon = love.physics.newFixture(self.fixtures.anchor:getBody(), love.physics.newPolygonShape(0, 0, 16, -16, 32, -16, 32, 16, 16, 16), 0)
	self.fixtures.weapon:setUserData(self.weapon.data)
	self.fixtures.weapon:setSensor(true)
	self.fixtures.weapon:setMask(1)



	-- Movement variables
	self.velocity = 250 * self.scale
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

	local tileset = yama.assets.tilesets["body"]
	local sprite = scene.newSceneEntity()
	sprite.sx, sprite.sy = self.sx, self.sy
	sprite.drawable = tileset.tiles[1]
	sprite.normalmap = yama.assets.loadImage("lightingtest/body_normal")
	sprite.depthmap = yama.assets.loadImage("lightingtest/body_depth")


	-- local tilesetArrow = "directionarrow"
	-- local spriteArrow = yama.buffers.newDrawable(yama.assets.loadImage(tilesetArrow), self.x, self.y-16, 640, 1, self.sx, self.sy, -24, 12)
	table.insert(bufferBatch.data, sprite)

	


	function self.updateInput(dt)
		if not self.joystick then return end

		local nx, ny = 0, 0
		local fx, fy = 0, 0
		local vmultiplier = 1
		animation.timescale = 1
		self.state = "stand"
		self.fixtures.weapon:setMask(1)

		if self.state == "stand" or self.state == "walk" then

			if love.keyboard.isDown("lctrl") or self.joystick:isDown(1) then
				self.state = "sword"
				wvx = 500 * math.cos(self.direction)
				wvy = 500 * math.sin(self.direction)
				self.fixtures.weapon:setMask()
				vmultiplier = 1
				--self.fixtures.weapon:getBody():setPosition(x, y)
				--self.fixtures.weapon:getBody():setLinearVelocity(wvx, wvy)
			elseif yama.tools.getDistance(0, 0, self.joystick:getAxis(1), self.joystick:getAxis(2)) > 0.2 then
				self.state = "walk"
				nx = self.joystick:getAxis(1)
				ny = self.joystick:getAxis(2)
				self.direction = math.atan2(ny, nx)
				self.aim = self.direction
				vmultiplier = yama.tools.getDistance(0, 0, self.joystick:getAxis(1), self.joystick:getAxis(2))
				if vmultiplier >  1 then
					vmultiplier = 1
				end

			elseif love.keyboard.isDown("right") or love.keyboard.isDown("left") or love.keyboard.isDown("down") or love.keyboard.isDown("up") then
				self.state = "walk"
				if love.keyboard.isDown("right") then
					nx = nx+1
				end
				if love.keyboard.isDown("left") then
					nx = nx-1
				end
				if love.keyboard.isDown("up") then
					ny = ny-1
				end
				if love.keyboard.isDown("down") then
					ny = ny+1
				end
				self.direction = math.atan2(ny, nx)
				self.aim = self.direction
			elseif love.keyboard.isDown(" ") then
				patrol.update(self.fixtures.anchor:getBody():getX(), self.fixtures.anchor:getBody():getY())
				if patrol.isActive() then
					self.state = "walk"
					nx, ny = patrol.getPoint()
					self.direction = math.atan2(ny, nx)
					self.aim = self.direction
				else
					self.state = "stand"
				end
			end
		end

		

		if self.state == "walk" then
			if love.keyboard.isDown("lshift") or self.joystick:isDown(5) then
				vmultiplier = vmultiplier * 3
			end
			fx = self.velocity * vmultiplier * math.cos(self.direction)
			fy = self.velocity * vmultiplier * math.sin(self.direction)
			self.fixtures.anchor:getBody():setAngle(self.direction)
			self.fixtures.anchor:getBody():applyForce(fx, fy)
			animation.timescale = vmultiplier
		end

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

	function self.updatePosition()

		-- Position updates
		--self.x, self.y = map.translatePosition(self.fixtures.anchor:getBody():getX(), self.fixtures.anchor:getBody():getY())
		self.x, self.y = self.fixtures.anchor:getBody():getX(), self.fixtures.anchor:getBody():getY()
		--self.x, self.y = math.floor(self.x + 0.5), math.floor(self.y + 0.5)
		self.fixtures.anchor:getBody():setAngle(self.direction)

		yama.buffers.setBatchPosition(bufferBatch, self.x + self.aox, self.y + self.aoy)

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
		--	print("boss Begin Contact: "..userdata.type)
			if userdata.type == "portal" then
				self.teleport(userdata.properties.map, userdata.properties.spawn)
			end
		end

				--if entity.isTree then
					--print("adding entity to triggers")
					--local d, x1, y1, x2, y2 = love.physics.getDistance(b, anchor.fixture)
					--d = getDistance(a:getBody():getX(), a:getBody():getY(), b:getBody():getX(), b:getBody():getY())
					--print(d)
					--triggers.add(entity)
				--end
		--end
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
	--function self.getDirection()
	--	return self.direction
	--end




	function self.teleport(mapname, spawn)
		local newMap = yama.maps.load(mapname)
		local newEntity = newMap.spawn(self.type, spawn)
		if self.vp then
			self.vp.connect(newMap, newEntity)
		end
		self.destroy()
	end

	-- DEFAULT FUNCTIONS
	function self.initialize(object)
		print("boss INITAD", self.fixtures.anchor.type())
		self.weaponSetup()
	end

	function self.update(dt)
		cooldown = cooldown - dt

		if cooldown < 0 then 
			-- self.shoot(dt)
			cooldown = 1
		end

		self.updateInput(dt)
		self.updatePosition()

		if self.state == "walk" or self.state == "stand" or self.state == "sword" then
			animation.update(dt, "humanoid_"..self.state.."_"..yama.tools.getRelativeDirection(self.direction))
		else
			animation.update(dt, "humanoid_die")
		end
		sprite.drawable = tileset.tiles[animation.frame]

		self.setBoundingBox()

		scene.lights.position[1] = {math.floor(self.x + 0.5), math.floor(self.y + 0.5), 64}
	end

	function self.addToBuffer(vp)
		vp.addToBuffer(bufferBatch)
		vp.addToBuffer(spriteArrow)
		--vp.getBuffer().add(fx)
	end

	function self.destroy()
		print("Destroying boss")
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
	--function self.getBoundingCircle()
	--	local x, y, width, height = self.getBoundingBox()
	--	local cx, cy = x + width / 2, y + height / 2
	--	local radius = yama.tools.getDistance(x, y, cx, cy)

	--	return cx, cy, radius
	--end

	function self.weaponSetup()
			-- WEAPON STUFF 
		self.weapon.properties = {}
		self.weapon.properties.name = 'bouncer'
		self.weapon.properties.rps = 0.2
		self.weapon.properties.damageBody = 6
		self.weapon.properties.damageShield = 17
		self.weapon.properties.impulseForce = 900
		self.weapon.properties.nrBulletsPerShot = 1
		self.weapon.properties.magCapacity = 50
		self.weapon.properties.spread = 1
		self.weapon.properties.nrBounces = 10
		self.weapon.properties.blastRadius = 0
		self.weapon.properties.lifetime = 5
		self.weapon.properties.bulletWeight = 0.4
		self.weapon.properties.sizeX = 1
		self.weapon.properties.linearDamping = 0.5
		self.weapon.properties.inertia = 0.2
		self.weapon.properties.gravityScale = 0.01
	end

	function self.shoot( dt )
		-- projectiles --

		self.projectileSpawnCooldown = self.projectileSpawnCooldown - dt
		if self.projectileSpawnCooldown <= 0 then
			local leftover = math.abs( self.projectileSpawnCooldown )
			self.projectileSpawnCooldown = self.weapon.properties.rps - leftover

			-- calculate projectile spawn position and offset
			local projectileSpawnPosX = self.x + 29*math.cos( self.aim )
			local projectileSpawnPosY = self.y + 29*math.sin( self.aim )

			-- create projectile
			local projectile = scene.newEntity( "projectile", {projectileSpawnPosX, projectileSpawnPosY, 0}, self.weapon.properties )

			-- calculate spread 
			local spread = love.math.random(0,self.weapon.properties.spread)
			spread = spread/100	
			if spread > self.weapon.properties.spread then
				spread = self.weapon.properties.spread
			end
			if love.math.random(0,1) == 1 then
				spread = - spread
			end
			local aimSpread =  self.aim + spread
			local vectorSpreadX = math.cos( aimSpread )
			local vectorSpreadY = math.sin( aimSpread )

			
			local fxprojectile = self.weapon.properties.impulseForce * vectorSpreadX
			local fyprojectile = self.weapon.properties.impulseForce * vectorSpreadY

			projectile.shoot( projectileSpawnPosX, projectileSpawnPosY, fxprojectile, fyprojectile, self.weapon.properties )
			projectile = nil
		end
	end

	function self.damage(damage)
		self.health = self.health - damage
		if self.health <= 0 then
			self.destroy()
		end
	end

	self.setBoundingBox()
	
	return self
end

return boss