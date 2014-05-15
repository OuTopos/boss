local yama = require((...):match("(.+)%.[^%.]+$") .. "/table")

local worlds = {}

local function new()
	local self = {}

	-- TIME
	local timescale = 1

	-- CALLBACKS
	self.callbacks = {}

	-- LOCATIONS & PATHS
	self.locations = {}
	self.paths = {}

	-- SCENE
	self.scene = yama.scenes.new()
	self.newSceneEntity = self.scene.newSceneEntity  -- for backward compitibality. access it from world.scene instead.
	self.updateViewports = self.scene.updateViewports  -- for backward compitibality. access it from world.scene instead.

	-- MAPS
	function self.loadMap(path, offset)
		return yama.maps.load(self, path, offset)
	end

	-- ENTITIES
	self.entities = {}

	function self.updateEntities(dt)
		for k = #self.entities, 1, -1 do
			local entity = self.entities[k]
			if entity.destroyed then
				table.remove(self.entities, k)
			else
				entity.update(dt)
			end
		end
	end

	function self.newEntity(enitytype, position, properties)
		local x, y, z = 0, 0, 0
		if type(position) == "string" then
			if self.locations[position] then
				x = self.locations[position].x
				y = self.locations[position].y
				z = self.locations[position].z
			end
		elseif type(position) == "table" then
			x = tonumber(position[1]) or 0
			y = tonumber(position[2]) or 0
			z = tonumber(position[3]) or 0
		end
		local entity = yama.entities[enitytype].new(self, x, y, z)
		if entity.initialize then
			entity.initialize(properties)
		end
		table.insert(self.entities, entity)
		return entity
	end

	-- PHYSICS
	function self.enablePhysics()

		function self.callbacks.beginContact(a, b, contact)
			if a:getUserData() then
				if a:getUserData().callbacks then
					if a:getUserData().callbacks.beginContact then
						a:getUserData().callbacks.beginContact(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().callbacks then
					if b:getUserData().callbacks.beginContact then
						b:getUserData().callbacks.beginContact(b, a, contact)
					end
				end
			end
		end

		function self.callbacks.endContact(a, b, contact)
			if a:getUserData() then
				if a:getUserData().callbacks then
					if a:getUserData().callbacks.endContact then
						a:getUserData().callbacks.endContact(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().callbacks then
					if b:getUserData().callbacks.endContact then
						b:getUserData().callbacks.endContact(b, a, contact)
					end
				end
			end
		end

		function self.callbacks.preSolve(a, b, contact)
			if a:getUserData() then
				if a:getUserData().callbacks then
					if a:getUserData().callbacks.preSolve then
						a:getUserData().callbacks.preSolve(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().callbacks then
					if b:getUserData().callbacks.preSolve then
						b:getUserData().callbacks.preSolve(b, a, contact)
					end
				end
			end
		end

		function self.callbacks.postSolve(a, b, contact)
			if a:getUserData() then
				if a:getUserData().callbacks then
					if a:getUserData().callbacks.postSolve then
						a:getUserData().callbacks.postSolve(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().callbacks then
					if b:getUserData().callbacks.postSolve then
						b:getUserData().callbacks.postSolve(b, a, contact)
					end
				end
			end
		end

		self.physics = love.physics.newWorld()
		self.physics:setCallbacks(self.callbacks.beginContact, self.callbacks.endContact, self.callbacks.preSolve, self.callbacks.postSolve)

		self.world = self.physics
	end

	-- UPDATE
	function self.update(dt)
		dt = dt * timescale
		if self.world then
			self.world:update(dt)
		end
		self.updateEntities(dt)
		self.scene.update(dt)
	end

	table.insert(worlds, self)
	return self
end

local function remove(world)
	for k = #worlds, 1, -1 do
		if worlds[k] == world
			then table.remove(worlds, k)
		end
	end
end

local function update(dt)
	for k = 1, #worlds do
		worlds[k].update(dt)
	end
end

local function draw()
	for k = 1, #worlds do
		worlds[k].draw()
	end
end

return {
	new = new,
	update = update,
	draw = draw,
}