shield = {}

function shield.new(game, origin)
	local self = {}

	self.range = 64
	self.arc = 3.14/4
	self.active = false

	self.state = "idle" -- idle or active
	self.userdata = { callbacks = {} }


	-- public functions
	function self.update(dt)
		if self.state == "active" then
			self.body:setPosition(origin.x, origin.y)
		end
	end

	function self.execute()
		print('execshield')
		if self.state == "idle" then
			print('execshield not active')

			self.state = "active"

			self.body = love.physics.newBody(game.world.physics, self.x, self.y, "dynamic")

			self.shape = love.physics.newCircleShape(self.range)

			self.fixture = love.physics.newFixture(self.body, self.shape)
			self.fixture:setUserData(self.userdata)
			self.fixture:setGroupIndex( -2 )
			--self.fixtures.shield:setCategory( 2 )
			self.fixture:setMask( 1 )
			--self.fixture:setSensor(true)
			-- self.fixture:setMask(player.mask)

			self.body:setPosition(origin.x, origin.y)
			self.body:setActive(true)
		elseif self.state == "active" then
			self.state = 'idle'
			self.fixture:destroy()
		end
	end

	function self.initialize(properties)
		self.userdata.name =  "Shield of "..origin.name
		self.userdata.owner = origin.name		
	end

	function self.setRange(range)
		self.range = range
	end

	function self.setArc(arc)
		self.arc = arc
	end

	-- private functions	
	function self.userdata.callbacks.beginContact(a, b, contact)				
		local userdataA, userdataB = a:getUserData(), b:getUserData()
	end

	function self.userdata.callbacks.endContact(a, b, contact)
	end

	return self
end

return shield