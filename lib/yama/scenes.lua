local yama = require((...):match("(.+)%.[^%.]+$") .. "/table")

local function newEntity()
	local self = {}
	-- entity.batch = {}
	-- entity.drawables = {}
	-- entity.shader = nil -- Should be default shader. Maybe.
	-- entity.samplers = {}
	self.depthmap = yama.assets.loadImage("colors/0.0.0")
	self.normalmap = yama.assets.loadImage("colors/127.127.255")
	self.x = 0
	self.y = 0
	self.z = 0
	self.r = 0
	self.sx = 1
	self.sy = 1
	self.ox = 0
	self.oy = 0

	self.width = 0
	self.height = 0

	self.scale = 1

	function self.newEntity()
		local entity = newEntity()
		if type(self.batch) ~= "table" then
			self.batch = {}
		end
		table.insert(self.batch, entity)
		return entity
	end

	return self
end

local function newLight()
	local self = {}
	self.x = 0
	self.y = 0
	self.z = 0
	self.radius = 0
	self.color = {0, 0, 0, 0}
	return self
end


local function newScene()
	local self = {}

	--BOUNDING VOLUME
	self.boundingbox = {}
	self.boundingbox.x = 0
	self.boundingbox.y = 0
	self.boundingbox.width = 0
	self.boundingbox.height = 0

	-- LIGHTS
	self.lights = {}
	self.lights.position = {{600, 300, 75}, {496, 886, 100}, {624, 886, 100}, {300, 200, 50}, {500, 100, 100}}
	self.lights.color = {{1, 1, 1, 1}, {1, 0.8, 0, 2}, {1, 0.8, 0, 2}, {1, 0, 1, 1}, {0, 0, 10, 1}}

	-- SCENE ENTITIES
	self.entities = {}

	function self.newEntity()
		local entity = newEntity()
		table.insert(self.entities, entity)
		return entity
	end

	function self.removeEntity(entity)
		entity.destroy = true
	end

	-- ENV
	self.env = {}

	self.env.time = 0
	self.env.day = 0
	self.env.timeMultiplier = 0.001

	self.env.fog = {}
	self.env.fog.layers = 4
	self.env.fog.mask = "fog"

	self.env.fog.color = {1, 1, 1, 1}
	self.env.fog.elevation = 0.3
	self.env.fog.height = 0.2
	self.env.fog.speed = {1, 0} -- Pixels/second

	function self.updateEnv(dt)
		self.env.time = self.env.time + dt * self.env.timeMultiplier
		if self.env.time > 1 then
			self.env.day = self.env.day + 1
			self.env.time = self.env.time - 1
		end
	end

	function self.getColor(colors, position)
		local noc = #colors
		local step = 1 / noc
		local a = math.floor(noc * position + 0.5)
		local c = position - a / noc
		if a < 1 then
			a = 1
		end
		local b = a + 1
		if b > noc then
			b = 1
		end

		print(c, "A:", a, colors[a], "B:", b, colors[b])

		--r = math.floor(env.colors[env.hour][1] * (1 - env.counter) + env.colors[env.nexthour][1] * env.counter)
		--g = math.floor(env.colors[env.hour][2] * (1 - env.counter) + env.colors[env.nexthour][2] * env.counter)
		--b = math.floor(env.colors[env.hour][3] * (1 - env.counter) + env.colors[env.nexthour][3] * env.counter)
		--a = math.floor(env.colors[env.hour][4] * (1 - env.counter) + env.colors[env.nexthour][4] * env.counter)
	end

	local tabbe = {"Ett", "Två", "Tre", "Fyra", "Fem", "Sex", "Sju", "Åtta", "Nio", "Tio"}

	self.getColor(tabbe, 0.15)
	self.getColor(tabbe, 0.9)
	self.getColor(tabbe, 0.5234)

	-- MISC

	-- DEPTH SORTING
	--self.depthmode = "z"
	local sorted = false
	local depthsorts = {}

	--function self.setDepthMode(mode)
	--	if self.depthsorts[mode] then
	--		self.depthmode = mode
	--	else
	--		self.depthmode = "z"
	--	end
	--end

	function depthsorts.z(a, b)
		if a.z > b.z then
			return true
		end
		return false
	end

	function depthsorts.y(a, b)
		if a.y > b.y then
			return true
		end
		return false
	end

	function depthsorts.yz(a, b)
		if a.y+a.z < b.y+b.z then
			return true
		end
		if a.z == b.z then
			if a.y < b.y then
				return true
			end
			if a.y == b.y then
				if a.x < b.x then
					return true
				end
			end
		end
		return false
	end

	function self.sort()
		if not sorted then
			table.sort(self.entities, depthsorts.y)
		end
	end


	-- UPDATE
	function self.update(dt)
		self.updateEnv(dt)
	end
	
	return self
end

return {
	new = newScene,
}