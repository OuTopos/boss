local yama = require((...):match("(.+)%.[^%.]+$") .. "/table")

local viewports = {}

local function new()
	local self = {}

	-- DEBUG
	self.debug = {}
	self.debug.drawcalls = 0
	self.debug.worldEntities = 0
	self.debug.sceneEntities = 0
	self.debug.drawCalls = 0

	function self.debug.update()
		if self.world then
			self.debug.worldEntities = #self.world.entities
			if self.world.scene then
				self.debug.sceneEntities = #self.world.scene.entities
			else
				self.debug.sceneEntities = 0
			end
		else
			self.debug.worldEntities = 0
			self.debug.sceneEntities = 0
		end
	end

	-- SHADER ON/OFF
	local shadersEnabled = true

	-- CANVASES
	self.x = 0
	self.y = 0
	self.r = 0
	self.sx = 1
	self.sy = 1
	self.ox = 0
	self.oy = 0
	self.width, self.height = love.window.getDimensions()

	self.canvases = {}

	-- CAMERA
	self.camera = {}
	self.camera.x = 0
	self.camera.y = 0
	self.camera.r = 0

	self.camera.width, self.camera.height = self.width, self.height

	self.camera.sx = 1
	self.camera.sy = 1

	self.camera.cx = 0
	self.camera.cy = 0
	self.camera.radius = 0

	self.camera.round = false

	self.camera.targets = {}

	self.camera.speed = 5
	self.camera.target = nil

	self.camera.vx = 0
	self.camera.vy = 0

	local function setupShaders()
		if shadersEnabled then
			self.shaders = {}
			self.shaders.pre = love.graphics.newShader("shader_pre.glsl", "vert.glsl")
			self.shaders.post = love.graphics.newShader("shader_light.glsl")
		else
			self.shaders = nil
		end
	end

	local function setupCanvases()
		if shadersEnabled then
			self.canvases = {}
			self.canvases.diffuse = love.graphics.newCanvas(self.width, self.height)
			self.canvases.normal = love.graphics.newCanvas(self.width, self.height)
			self.canvases.depth = love.graphics.newCanvas(self.width, self.height)
			self.canvases.final = love.graphics.newCanvas(self.width, self.height)

			--self.shaders.pre:send("canvas_diffuse", self.canvases.diffuse)
			--self.shaders.pre:send("canvas_normal", self.canvases.normal)
			self.shaders.pre:send("canvas_depth", self.canvases.depth)

			self.shaders.post:send("normalmap", self.canvases.normal)
			self.shaders.post:send("depthmap", self.canvases.depth)
			self.shaders.post:send("fogmap", yama.assets.loadImage("fog"))
			self.shaders.post:send("ambientmap", yama.assets.loadImage("ambient"))

		else
			self.canvases = {}
			self.canvases.final = love.graphics.newCanvas(self.width, self.height)
		end
	end

	-- RESIZE & ZOOM
	function self.resize(width, height)
		print("KÖR EN RESIZE")
		self.width = width or love.window.getWidth()
		self.height = height or love.window.getHeight()
		
		setupCanvases()

		self.zoom(self.camera.sx, self.camera.sy)
	end

	function self.zoom(sx, sy)
		self.camera.sx = sx or 1
		self.camera.sy = sy or sx or 1

		self.camera.width = self.width / self.camera.sx
		self.camera.height = self.height / self.camera.sy
		self.camera.radius = yama.tools.getDistance(0, 0, self.camera.width / 2, self.camera.height / 2)
	end

	function self.follow(entity)
		if entity then
			if self.camera.target then
				self.camera.target.vp = nil
			end
			self.camera.target = entity
			entity.vp = self

			self.camera.target = entity
		else
			if self.camera.target then
				self.camera.target.vp = nil
			end

			warning("No entity specified for camera to follow.")
		end
	end

	function self.camera.move(x, y)
		local distance = yama.tools.getDistance(x, y, self.camera.cx, self.camera.cy)
		local direction = math.atan2(y-self.camera.cy, x-self.camera.cx)

		self.camera.vx = math.cos(direction)
		self.camera.vy = math.sin(direction)

		--print(self.camera.vx, distance, self.camera.vx * distance)
		self.camera.cx = self.camera.cx + self.camera.vx * distance/1000 * self.camera.speed
		self.camera.cy = self.camera.cy + self.camera.vy * distance/1000 * self.camera.speed
	end

	function self.camera.update()
		-- SET THE CX, CY or not.
		if self.camera.target then
			--self.camera.cx = self.camera.target.x -- self.camera.width / 2
			--self.camera.cy = self.camera.target.y -- self.camera.height / 2

			-- New smooth camera stuff
			--local x = self.camera.x
			--local y = self.camera.y
			--table.insert(self.camera.targets, 1, {x = x, y = y})
			--table.remove(self.camera.targets, 4)
			--self.camera.move(self.camera.target.x, self.camera.target.y)
			self.camera.cx = self.camera.target.x
			self.camera.cy = self.camera.target.y
			self.camera.z = self.camera.target.z
			--print(self.camera.z+self.camera.y)
			--self.camera.z = self.camera.target.z
		end
		-- GET X, Y from CX, XY
		self.camera.x = math.floor(self.camera.cx - self.camera.width / 2 + 0.5)
		self.camera.y = math.floor(self.camera.cy - self.camera.height / 2 + 0.5)
		
		self.boundaries.apply()

		if self.camera.round then
			self.ox = (self.camera.x - math.floor(self.camera.x + 0.5)) * self.camera.sx
			self.oy = (self.camera.y - math.floor(self.camera.y + 0.5))  * self.camera.sy
			self.camera.x = math.floor(self.camera.x + 0.5)
			self.camera.y = math.floor(self.camera.y + 0.5)
		else
			self.ox = 0
			self.oy = 0
		end
	end

	function self.translate()
		love.graphics.push()
		--love.graphics.translate(viewport.camera.width / 2 * viewport.camera.sx, viewport.camera.height / 2 * viewport.camera.sy)
 		----love.graphics.rotate(- viewport.camera.r)
		--love.graphics.translate(- viewport.camera.width / 2 * viewport.camera.sx, - viewport.camera.height / 2 * viewport.camera.sy)
		--love.graphics.scale(viewport.camera.sx, viewport.camera.sy)
		love.graphics.translate(- self.camera.x, - self.camera.y)
	end

	-- BOUNDARIES
	self.boundaries = {}
	self.boundaries.x = 0
	self.boundaries.y = 0
	self.boundaries.width = 0
	self.boundaries.height = 0

	function self.boundaries.apply()
		if not (self.boundaries.x == 0 and self.boundaries.y == 0 and self.boundaries.width == 0 and self.boundaries.height == 0) then
			if self.camera.width <= self.boundaries.width then
				if self.camera.x < self.boundaries.x then
					self.camera.x = self.boundaries.x
					self.camera.cx = self.camera.x + self.camera.width / 2
				elseif self.camera.x > self.boundaries.width - self.camera.width then
					self.camera.x = self.boundaries.width - self.camera.width
					self.camera.cx = self.camera.x + self.camera.width / 2
				end
			else
				self.camera.x = self.boundaries.x - (self.camera.width - self.boundaries.width) / 2
			end

			if self.camera.height <= self.boundaries.height then
				if self.camera.y < self.boundaries.y then
					self.camera.y = self.boundaries.y
					self.camera.cy = self.camera.y + self.camera.height / 2
				elseif self.camera.y > self.boundaries.height - self.camera.height then
					self.camera.y = self.boundaries.height - self.camera.height
					self.camera.cy = self.camera.y + self.camera.height / 2
				end
			else
				self.camera.y = self.boundaries.y - (self.camera.height - self.boundaries.height) / 2
			end
		end
	end

	-- CURSOR
	self.cursor = {}
	self.cursor.x = 0
	self.cursor.y = 0
	self.cursor.active = false

	function self.cursor.update()
		self.cursor.x = love.mouse.getX() + self.camera.x
		self.cursor.y = love.mouse.getY() + self.camera.y

		if self.cursor.x > self.x and self.cursor.x < self.width * self.sx and self.cursor.y > self.y and self.cursor.y < self.height * self.sy then
			self.cursor.active = true
		else
			self.cursor.active = false
		end
	end





	-- BOUNDING VOLUME CHECK
	function self.isEntityInside(entity)
		if entity.boundingbox then
			if entity.boundingbox.x + entity.boundingbox.width > self.camera.x and entity.boundingbox.x < self.camera.x + self.camera.width and entity.boundingbox.y + entity.boundingbox.height > self.camera.y and entity.boundingbox.y < self.camera.y + self.camera.height then
				return true
			else
				return false
			end
		elseif entity.boundingcircle then
			if yama.tools.getDistance(self.camera.cx, self.camera.cy, entity.boundingcircle.x, entity.boundingcircle.y) < self.camera.radius + entity.boundingcircle.radius then
				return true
			else
				return false
			end
		else
			return true
		end
	end

	-- SCENES

	function self.attach(world, transition)
		if world then
			self.world = world
			if world.scene then
				self.scene = world.scene
				-- Set the sort mode on the viewport.
				-- vp.setDepthMode(depthmode)

				-- Set camera boundaries for the viewport.
				-- if scene == "false" then
				-- 	vp.boundaries.x = 0
				-- 	vp.boundaries.x = 0
				-- 	vp.boundaries.width = 0
				-- 	vp.boundaries.height = 0
				-- else
				-- 	vp.boundaries.x = boundingbox.x
				-- 	vp.boundaries.x = boundingbox.y
				-- 	vp.boundaries.width = boundingbox.width --map.width * map.tilewidth
				-- 	vp.boundaries.height = boundingbox.height --map.height * map.tileheight
				-- end
				-- Do all other things needed for good attachment.

				-- TO DO: Transition
			end

			if transition then
				self.canvases.previous = self.canvases.final
				-- Set transitions to active.
			end
		end
	end

	function self.detach()
		self.world = nil
		self.scene = nil
	end




	local function drawSceneEntityShaders(sceneEntity)
		self.shaders.pre:send("normalmap", sceneEntity.normalmap)
		self.shaders.pre:send("depthmap", sceneEntity.depthmap)
		--self.shaders.pre:send("z", sceneEntity.z / 256)
		self.shaders.pre:sendInt("scale", 1) -- (sceneEntity.sx + sceneEntity.sy) / 2)
		
		love.graphics.draw(sceneEntity.drawable, sceneEntity.x, sceneEntity.y, sceneEntity.r, sceneEntity.sx, sceneEntity.sy, sceneEntity.ox, sceneEntity.oy)
		self.debug.drawcalls = self.debug.drawcalls + 1
	end

	local function drawSceneEntity(sceneEntity)
		love.graphics.draw(sceneEntity.drawable, sceneEntity.x, sceneEntity.y, sceneEntity.r, sceneEntity.sx, sceneEntity.sy, sceneEntity.ox, sceneEntity.oy)
		self.debug.drawcalls = self.debug.drawcalls + 1
	end


	-- UPDATE
	function self.update(dt)
		self.camera.update()
		self.cursor.update()
	end

	function self.draw()
		if self.scene then
			if shadersEnabled then
				local scene = self.scene
				local entities = self.scene.entities
				--scene.sort()

				-- DEBUG
				self.debug.drawcalls = 0
				-- self.debug.sceneEntities = #self.entities
				
				-- SET CAMERA
				self.translate()

				self.translationmatrix2 = {
					{1, 0, 0, self.camera.x},
					{0, 1, 0, -self.camera.y},
					{0, 0, 1, 0},
					{0, 0, 0, 1}
				}
			
				-- SET CANVAS
				self.canvases.diffuse:clear(0, 0, 0, 255)
				self.canvases.normal:clear(127, 127, 255, 255)
				self.canvases.depth:clear(0, 0, 0, 255)
				love.graphics.setCanvas(self.canvases.diffuse, self.canvases.normal, self.canvases.depth)

				-- SET SHADER
				love.graphics.setShader(self.shaders.pre)

				-- Draw static entities

				--table.sort(self.entities, self.depthsorts.yz)

				for k = #entities, 1, -1 do
					local sceneEntity = entities[k]
					-- Check if inside viewport.
					if sceneEntity.destroyed then
						table.remove(entities, k)
					elseif sceneEntity.batch then
						for k = 1, #sceneEntity.batch do
							drawSceneEntityShaders(sceneEntity.batch[k])
						end
					elseif sceneEntity.drawable then
						drawSceneEntityShaders(sceneEntity)
					end
				end

				-- UNSET CAMERA
				love.graphics.pop()

				-- LIGHT PASS
				love.graphics.setCanvas(self.canvases.final)
				love.graphics.setShader(self.shaders.post)

				--viewport.shader_light:send("offset", {viewport.camera.x, viewport.camera.y})

				--viewport.shader_light:send("ambient_color", {0.05, 0.03, 0.1, 0.5})
				--viewport.shader_light:send("ambient_color", {0.02, 0.02, 0.02, 0})
				self.shaders.post:send("light_position", unpack(scene.lights.position))
				self.shaders.post:send("light_color", unpack(scene.lights.color))
				self.shaders.post:send("hour", scene.env.time)
				self.shaders.post:send("screen_to_world", self.translationmatrix2)

				love.graphics.draw(self.canvases.diffuse)
				love.graphics.setShader()

				-- DRAW GUI
				--yama.gui.draw(viewport)

				-- DRAW DEBUG TEXT
				yama.hud.draw(self, self.world)




				-- DRAW MODES
				if self.drawmode == 1 then
					-- DRAWING THE DIFFUSEMAP
					love.graphics.setCanvas()
					love.graphics.setShader()
					love.graphics.draw(self.canvases.diffuse, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
				elseif self.drawmode == 2 then
					-- DRAWING THE NORMALMAP
					love.graphics.setCanvas()
					love.graphics.setShader()
					love.graphics.draw(self.canvases.normal, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
				elseif self.drawmode == 3 then
					-- DRAWING THE DEPTHMAP
					love.graphics.setCanvas()
					love.graphics.setShader()
					love.graphics.draw(self.canvases.depth, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
				else
					-- DRAWING THE FINAL RESULT
					love.graphics.setCanvas()
					love.graphics.setShader()
					love.graphics.draw(self.canvases.final, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
				end
			else
				-- Draw without shaders.
				-- SORT THE SCENE
				self.scene.sort()

				-- SET CANVAS
				love.graphics.setCanvas(self.canvases.final)

				-- SET CAMERA
				self.translate()

				-- ITERATE AND DRAW ENTITIES
				for k = #self.scene.entities, 1, -1 do
					local entity = self.scene.entities[k]
					-- Check if inside viewport.
					if entity.destroyed then
						table.remove(self.scene.entities, k)
					elseif entity.batch then
						for k = 1, #entity.batch do
							drawSceneEntity(entity.batch[k])
						end
					elseif entity.drawable then
						drawSceneEntity(entity)
					end
				end

				-- UNSET CAMERA
				love.graphics.pop()

				-- DRAW HUD
				yama.hud.draw(self, self.world)

				-- UNSET CANVAS
				love.graphics.setCanvas()

				-- DRAWING THE FINAL RESULT
				love.graphics.draw(self.canvases.final, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
			end
		end
	end

	setupShaders()

	table.insert(viewports, self)
	return self
end

local function remove(viewport)
	for k = #viewports, 1, -1 do
		if viewports[k] == viewport
			then table.remove(viewports, k)
		end
	end
end

local function update(dt)
	for k = 1, #viewports do
		viewports[k].update(dt)
	end
end

local function draw()
	for k = 1, #viewports do
		viewports[k].draw()
	end
end

return {
	new = new,
	update = update,
	draw = draw,
}