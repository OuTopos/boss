local yama = require((...):match("(.+)%.[^%.]+$") .. "/table")
local assets = {}
assets.images = {}
assets.tilesets = {}
assets.animations = {}

assets.padTilesets = true
assets.generateMesh = true

function assets.load()
	--love.graphics.setDefaultFilter("linear", "linear")
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- LOADING TILESETS
	if love.filesystem.exists(yama.paths.tilesets) then
		local files = love.filesystem.getDirectoryItems(yama.paths.tilesets)
		for k, file in ipairs(files) do
			--info("Autoloading file #" .. k .. ": " .. file)
			local chunk = love.filesystem.load(yama.paths.tilesets .. "/" .. file)
			local tilesets = chunk()
			for i = 1, #tilesets do
				assets.loadTileset(tilesets[i].name, tilesets[i].imagepath, tilesets[i].tilewidth, tilesets[i].tileheight, tilesets[i].spacing, tilesets[i].margin, tilesets[i].margin)
				info("Autoloaded tileset (" .. file .. ") " .. tilesets[i].name)
			end
		end
	end

	-- LOADING ANIMATIONS
	if love.filesystem.exists(yama.paths.animations) then
		print("Animations eh?")
		--[[
		local files = love.filesystem.enumerate("animations")
		for k, file in ipairs(files) do
			print("Autoloading tileset #" .. k .. ": " .. file)
			local animations = dofile("tilesets/" .. file)
			for i = 1, #animations do


				assets.loadTileset(tilesets[i].name, tilesets[i].imagepath, tilesets[i].tilewidth, tilesets[i].tileheight, tilesets[i].spacing, tilesets[i].margin)

			end
		end
		--]]
	end
end

-- IMAGE
function assets.loadImage(imagepath)
	if assets.images[imagepath] then
		-- info("Image " .. imagepath .. " was already loaded.", 3)
		return assets.images[imagepath]
	else
		if love.filesystem.exists(yama.paths.images .. "/" .. imagepath .. ".png") then
			assets.images[imagepath] = love.graphics.newImage(yama.paths.images .. "/".. imagepath .. ".png")
			-- info("Successfully loaded image: " .. imagepath, 3)
			return assets.images[imagepath]
		else
			warning("Couldn't load image: " .. imagepath .. ". File not found.", 3)
			return false
		end
	end
end


-- TILESET
function assets.loadTileset(name, imagepath, tilewidth, tileheight, spacing, margin, pad)
	if assets.tilesets[name] then
		return assets.tilesets[name]
	elseif imagepath and tilewidth and tileheight then
		local self = {}
		self.image = assets.loadImage(imagepath)
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

				self.srcimagedata = love.image.newImageData(yama.paths.images .. "/" ..imagepath .. ".png")
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
						{ 0,                                -self.tileheight,                 imagex/self.imagewidth,                    imagey/self.imageheight                   ,0, 0, 0},
						{ self.tilewidth,                   -self.tileheight,                 (imagex+self.tilewidth)/self.imagewidth,   imagey/self.imageheight                   ,0, 0, 0},
						{ self.tilewidth,                   0,                                (imagex+self.tilewidth)/self.imagewidth,   (imagey+self.tileheight)/self.imageheight ,0, 0, 0},
						{ 0,                                0,                                imagex/self.imagewidth,                    (imagey+self.tileheight)/self.imageheight ,0, 0, 0},
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
				assets.images[imagepath] = self.image
			end

			if assets.generateMesh then
				for i = 1, #self.vertices do
					self.tiles[i] = love.graphics.newMesh(self.vertices[i], self.image)
				end
			end

			self.tilecount = #self.tiles

			assets.tilesets[name] = self

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

assets.loading = {}

function assets.newDrawable(drawable, x, y, z, r, sx, sy, ox, oy, kx, ky)
	local self = {}
	self.type = "drawable"
	self.drawable = drawable
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.r = r or 0
	self.sx = sx or 1
	self.sy = sy or sx or 1
	self.ox = ox or 0
	self.oy = oy or 0
	self.kx = kx or 0
	self.ky = ky or 0

	function self.loadImage(imagepath)
		if assets.images[imagepath] then
			self.drawable = assets.images[imagepath]
		else

		end
	end

	return self
end

function assets.newContainer()
	local self = {}

	self.asset = nil

	function self.loadImage(imagepath)
		print(imagepath)
		self.test = "fungerar"
		if assets.images[imagepath] then
			self.asset = assets.images[imagepath]
		else
			-- Enqueue it!
		end
	end

	return self
end


assets.queue = {}
assets.loading = nil

function assets.tLoad(arguments)
	table.insert(assets.queue, arguments)
end

function assets.update()
	--[[
	if assets.loading then
		-- Check thread.


	elseif #assets.queue > 0 then
		-- start new thread and load.
		assets.thread = love.thread.newThread("thread.lua")
		assets.thread:start()

		assets.channel = love.thread.getChannel("assets.threadInput")
		-- push the load command through the channel
		assets.channel:push(assets.queue[1])

		-- remove from queue
		table.remove(assets.queue, 1)
	end
	--]]
end

return assets