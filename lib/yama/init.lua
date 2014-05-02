local yama = {}

-- CONFIG

-- Paths
P = {}
P.LIB = "lib"
P.SRC = "src"
P.ASSETS = "assets"

P.ENTITIES = P.SRC .. "/entities"

P.TILESETS = P.ASSETS .. "/tilesets"
P.IMAGES = P.ASSETS .. "/images"
P.ANIMATIONS = P.ASSETS .. "/animations"
P.MAPS = P.ASSETS .. "/maps"

-- MODULES
--yama.assets         = require(P.LIB .. "/yama.assets")
yama.animations     = require(P.LIB .. "/yama.animations")
yama.newAnimation = yama.animations.new

yama.scenes         = require(P.LIB .. "/yama.scenes")
yama.newScene = yama.scenes.new

yama.viewports      = require(P.LIB .. "/yama.viewports")
yama.gui            = require(P.LIB .. "/yama.gui")
yama.hud            = require(P.LIB .. "/yama.hud")
yama.physics        = require(P.LIB .. "/yama.physics")

yama.tools		    = require(P.LIB .. "/yama.tools")

-- Phase these out

yama.buffers      	= require(P.LIB .. "/yama.buffers")
yama.ai             = require(P.LIB .. "/yama.ai")
yama.ai.patrols     = require(P.LIB .. "/yama.ai_patrols")

-- VARIABLES
yama.v = {}
yama.v.paused = false
yama.v.timescale = 1
yama.v.gcInterval = 10
yama.v.gcTimer = 10


-- ######## ASSETS ########

yama.assets = {}
yama.assets.images = {}
yama.assets.tilesets = {}
yama.assets.animations = {}

yama.assets.padTilesets = true
yama.assets.generateMesh = true

function yama.assets.load()
	-- LOADING TILESETS
	if love.filesystem.exists(P.TILESETS) then
		local files = love.filesystem.getDirectoryItems(P.TILESETS)
		for k, file in ipairs(files) do
			--info("Autoloading file #" .. k .. ": " .. file)
			local chunk = love.filesystem.load(P.TILESETS .. "/" .. file)
			local tilesets = chunk()
			for i = 1, #tilesets do
				yama.assets.loadTileset(tilesets[i].name, tilesets[i].imagepath, tilesets[i].tilewidth, tilesets[i].tileheight, tilesets[i].spacing, tilesets[i].margin, tilesets[i].margin)
				info("Autoloaded tileset (" .. file .. ") " .. tilesets[i].name)
			end
		end
	end

	-- LOADING ANIMATIONS
	if love.filesystem.exists(P.ANIMATIONS) then
		print("Animations eh?")
		--[[
		local files = love.filesystem.enumerate("animations")
		for k, file in ipairs(files) do
			print("Autoloading tileset #" .. k .. ": " .. file)
			local animations = dofile("tilesets/" .. file)
			for i = 1, #animations do


				yama.assets.loadTileset(tilesets[i].name, tilesets[i].imagepath, tilesets[i].tilewidth, tilesets[i].tileheight, tilesets[i].spacing, tilesets[i].margin)

			end
		end
		--]]
	end
end

-- IMAGE
function yama.assets.loadImage(imagepath)
	if yama.assets.images[imagepath] then
		info("Image " .. imagepath .. " was already loaded.", 3)
		return yama.assets.images[imagepath]
	else
		if love.filesystem.exists(P.IMAGES .. "/" .. imagepath .. ".png") then
			yama.assets.images[imagepath] = love.graphics.newImage(P.IMAGES .. "/".. imagepath .. ".png")
			info("Successfully loaded image: " .. imagepath, 3)
			return yama.assets.images[imagepath]
		else
			warning("Couldn't load image: " .. imagepath .. ". File not found.", 3)
			return false
		end
	end
end


-- TILESET
function yama.assets.loadTileset(name, imagepath, tilewidth, tileheight, spacing, margin, pad)
	if yama.assets.tilesets[name] then
		return yama.assets.tilesets[name]
	elseif imagepath and tilewidth and tileheight then
		local self = {}
		self.image = yama.assets.loadImage(imagepath)
		self.imagepath = imagepath

		if self.image then
			self.imagewidth = self.image:getWidth()
			self.imageheight = self.image:getHeight()

			self.tilewidth = tilewidth
			self.tileheight = tileheight

			self.spacing = spacing or 0
			self.margin = margin or 0

			self.properties = {}

			self.width = math.floor((self.imagewidth - self.margin * 2 + self.spacing) / (self.tilewidth + self.spacing))
			self.height = math.floor((self.imageheight - self.margin * 2 + self.spacing) / (self.tileheight + self.spacing))

			self.vertices = {}
			self.tiles = {}


			if pad then
				self.imagewidth = self.width * 2 + self.width * self.tilewidth
				self.imageheight = self.height * 2 + self.height * self.tileheight

				self.srcimagedata = love.image.newImageData(P.IMAGES .. "/" ..imagepath .. ".png")
				self.imagedata = love.image.newImageData(self.imagewidth, self.imageheight)
			end

			for y=0, self.height - 1 do
				for x=0, self.width - 1 do
					local imagex = self.margin + x * (self.tilewidth + self.spacing)
					local imagey = self.margin + y * (self.tileheight + self.spacing)

					if pad then
						local tilex = x * (self.tilewidth + 2) + 1
						local tiley = y * (self.tileheight + 2) + 1
						self.imagedata:paste(self.srcimagedata, tilex, tiley, imagex, imagey, self.tilewidth, self.tileheight)

						imagex = tilex
						imagey = tiley
					end

					local vertices = {
					--    x,                                y,                                u,                                        v
						{ 0,                                -self.tileheight,                 imagex/self.imagewidth,                    imagey/self.imageheight                   ,32, 0, 0},
						{ self.tilewidth,                   -self.tileheight,                 (imagex+self.tilewidth)/self.imagewidth,   imagey/self.imageheight                   ,32, 0, 0},
						{ self.tilewidth,                   0,                                (imagex+self.tilewidth)/self.imagewidth,   (imagey+self.tileheight)/self.imageheight ,32, 0, 0},
						{ 0,                                0,                                imagex/self.imagewidth,                    (imagey+self.tileheight)/self.imageheight ,32, 0, 0},
					}

					table.insert(self.vertices, vertices)
				end
			end

			if pad then
				for x = 0, self.width - 1 do
					local tilex = x * (self.tilewidth + 2)

					self.imagedata:paste(self.imagedata, tilex, 0, tilex+1, 0, 1, self.imageheight)
					self.imagedata:paste(self.imagedata, tilex+self.tilewidth+1, 0, tilex+self.tilewidth, 0, 1, self.imageheight)
				end

				for y = 0, self.height - 1 do
					local tiley = y * (self.tileheight + 2)

					self.imagedata:paste(self.imagedata, 0, tiley, 0, tiley+1, self.imagewidth, 1)
					self.imagedata:paste(self.imagedata, 0, tiley+self.tileheight+1, 0, tiley+self.tileheight, self.imagewidth, 1)
				end

				self.image = love.graphics.newImage(self.imagedata)
				yama.assets.images[imagepath] = self.image
			end

			if yama.assets.generateMesh then
				for i = 1, #self.vertices do
					self.tiles[i] = love.graphics.newMesh(self.vertices[i], self.image)
				end
			end

			self.tilecount = #self.tiles

			yama.assets.tilesets[name] = self

			-- CLEAN UP
			self.srcimagedata = nil
			self.imagedata = nil

			return self
		else
			print("WARNING: ASSETS -> Couldn't load tileset: " .. name .. ". Image couldn't load.")
			return nil
		end
	else
		print("WARNING: ASSETS -> Couldn't load tileset: " .. name .. ". Too few arguments.")
		return nil
	end
end

function yama.assets.newDrawable(drawable, x, y, z, r, sx, sy, ox, oy, kx, ky)
	local self = {}
	self.type = "drawable"
	self.drawable = drawable
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.ox = ox or 0
	self.oy = oy or 0
	self.kx = kx or 0
	self.ky = ky or 0

	--[[
	function self.loadImage(imagepath)
		if yama.assets.images[imagepath] then
			self.drawable = yama.assets.images[imagepath]
		else

		end
	end
	--]]

	return self
end


function yama.assets.newContainer()
	local self = {}

	self.asset = nil

	function self.loadImage(imagepath)
		print(imagepath)
		self.test = "fungerar"
		if yama.assets.images[imagepath] then
			self.asset = yama.assets.images[imagepath]
		else
			-- Enqueue it!
		end
	end

	return self
end

-- ######## END ASSETS ########














-- DEBUG FUNCTIONS
yama.debug = {}
yama.debug.level = 2
yama.debug.warning2error = false
yama.debug.log = false

function info(text, i)
	if yama.debug.level >= 2 then
		local info = debug.getinfo(i or 2, "lS")
		print("Info: " .. info.short_src .. ":" .. info.currentline .. ": " .. text)
	end
end
function warning(text, i)
	if yama.debug.level >= 1 then
		if yama.debug.warning2error then
			error(text)
		else
			local info = debug.getinfo(i or 2, "lS")
			print("Warning: " .. info.short_src .. ":" .. info.currentline .. ": " .. text)
		end
	end
end


-- TOOLS

function yama.requireDir(path)
	local table = {}
	if love.filesystem.exists(path) then
		local files = love.filesystem.getDirectoryItems(path)
		for k, file in ipairs(files) do
			info("require(" .. path .. "/" .. file:gsub("%.lua", "") .. ")", 3)
			table[file:gsub("%.lua", "")] = require(path .. "/" .. file:gsub("%.lua", ""))
		end
	end
	return table
end


function yama.load()
	--love.graphics.setDefaultFilter("linear", "linear")
	love.graphics.setDefaultFilter("nearest", "nearest")


	yama.assets.load()
	yama.gui.load()

	-- Loading entities
	yama.entities = yama.requireDir(P.ENTITIES)

	--[[
	local rgb = {0, 1, 0, 0}

	local base = 256
	local newnum = 0
	for i = 1, #rgb do
		newnum = newnum + rgb[i] * base ^ (i - 1)
	end
	print(newnum)

	print(yama.tools.rgba2num(rgb))

	--]]
end

function yama.update(dt)
	if not yama.v.paused then
		yama.scenes.update(dt * yama.v.timescale)
	end
end

function yama.draw()
	yama.scenes.draw()

	---[[ FPS
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 3, 3, 100, "left")

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 2, 2, 100, "left")
	--]]
end

-- Love callbacks
yama.keybindings = {}
function love.keypressed(key)
	if yama.keybindings[key] then
		if type(yama.keybindings[key]) == "function" then
			yama.keybindings[key]()
		end
	end
end

yama.keybindings["escape"] = function()
	love.event.push("quit")
end

yama.keybindings["h"] = function()
	if yama.hud.enabled then
		yama.hud.enabled = false
	else
		yama.hud.enabled = true
	end
end

yama.keybindings["j"] = function()
	if yama.hud.physics then
		yama.hud.physics = false
	else
		yama.hud.physics = true
	end
end

yama.keybindings["p"] = function()
	if yama.v.paused then
		yama.v.paused = false
	else
		yama.v.paused = true
	end
end

return yama