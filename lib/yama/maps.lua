local yama = require((...):match("(.+)%.[^%.]+$") .. "/table")




-- DEBUG
local debug = {}
debug.start_time = os.clock()
debug.tilesetcount = 0
debug.tilelayercount = 0
debug.tilecount = 0
debug.vertexcount = 0








local maps = {}

-- DEPTH
local getDepth = {}

function getDepth.z(x, y, z)
	return z
end
function getDepth.y(x, y, z)
	return y
end
function getDepth.yz(x, y, z)
	return y + z
end

local function index2xy(map, index)
	return (index-1) % map.width, math.floor((index-1) / map.width)
end

local function getSpritePosition(map, x, y, z)
	-- This function gives you a pixel position from a tile position.
	if map.orientation == "orthogonal" then
		return x * map.tilewidth, y * map.tileheight, z * map.tileheight
	elseif map.orientation == "isometric" then
		x, y = self.translatePosition(x * map.tileheight, y * map.tileheight)
		return x, y, z
	end
end

local function getTileset(map, gid)
	local i = #map.tilesets
	while map.tilesets[i] and gid < map.tilesets[i].firstgid do
		i = i - 1
	end
	return map.tilesets[i]
end

local function getTileKey(map, gid)
	local tileset = getTileset(map, gid)
	return gid - (tileset.firstgid - 1)
end

local function getTiles(map, x, y, width, height)
	x1 = math.floor( x / map.tilewidth)
	x2 = math.ceil( ( x + width ) / map.tilewidth)
	y1 = math.floor( y / map.tileheight )
	y2 = math.ceil( ( y + height ) / map.tileheight )
	return x1, y1, x2-x1, y2-y1
end







-- PHYSICS
-- For creating physics fixture, body and shape from a Tile object.
local function createFixture(world, object, bodyType)
	if world then
		if object.shape == "rectangle" then
			--Rectangle or Tile
			if object.gid then
				--Tile
				local body = love.physics.newBody(world, object.x, object.y-self.data.tileheight, bodyType)
				local shape = love.physics.newRectangleShape(self.data.tilewidth/2, self.data.tileheight/2, self.data.tilewidth, self.data.tileheight)
				return love.physics.newFixture(body, shape)
			else
				--Rectangle
				local body = love.physics.newBody(world, object.x, object.y, bodyType)
				local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
				return love.physics.newFixture(body, shape)
			end
		elseif object.shape == "ellipse" then
			--Ellipse
			local body = love.physics.newBody(world, object.x+object.width/2, object.y+object.height/2, bodyType)
			local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
			return love.physics.newFixture(body, shape)
		elseif object.shape == "polygon" then
			--Polygon
			local vertices = {}
			for i,vertix in ipairs(object.polygon) do
				table.insert(vertices, vertix.x)
				table.insert(vertices, vertix.y)
			end
			local body = love.physics.newBody(world, object.x, object.y, bodyType)
			local shape = love.physics.newPolygonShape(unpack(vertices))
			return love.physics.newFixture(body, shape)
		elseif object.shape == "polyline" then
			--Polyline
			local vertices = {}
			for i,vertix in ipairs(object.polyline) do
				table.insert(vertices, vertix.x)
				table.insert(vertices, vertix.y)
			end
			local body = love.physics.newBody(world, object.x, object.y, bodyType)
			local shape = love.physics.newChainShape(false, unpack(vertices))
			return love.physics.newFixture(body, shape)
		else
			return nil
		end
	else
		return nil
	end
end


-- MESHES
local function addToMeshes(map, x, y, z, gid, layerKey, flat)
	local meshData = map.meshData
	if gid then
		if gid > 0 then
			map.debug.tiles = map.debug.tiles + 1
			map.debug.vertices = map.debug.vertices + 4
			map.debug.triangles = map.debug.triangles + 2

			local tileset = yama.assets.tilesets[getTileset(map, gid).name]
			local tile = tileset.vertices[getTileKey(map, gid)]
			local depth = getDepth[map.depthmode](x, y, z)
			-- depth = 1
			-- layerKey = 1
			local image = tileset.image
			local imagepath = tileset.imagepath

			if not meshData[depth] then
				meshData[depth] = {}
			end

			if not meshData[depth][layerKey] then
				meshData[depth][layerKey] = {}
			end

			if not meshData[depth][layerKey][image] then
				meshData[depth][layerKey][image] = {}
				meshData[depth][layerKey][image].vertexmap = {}
				meshData[depth][layerKey][image].vertices = {}
				meshData[depth][layerKey][image].tiles = {}
				meshData[depth][layerKey][image].x1 = nil
				meshData[depth][layerKey][image].y1 = nil
				meshData[depth][layerKey][image].x2 = nil
				meshData[depth][layerKey][image].y2 = nil
				meshData[depth][layerKey][image].imagepath = imagepath
			end

			table.insert(meshData[depth][layerKey][image].vertexmap, #meshData[depth][layerKey][image].vertices + 1)
			table.insert(meshData[depth][layerKey][image].vertexmap, #meshData[depth][layerKey][image].vertices + 2)
			table.insert(meshData[depth][layerKey][image].vertexmap, #meshData[depth][layerKey][image].vertices + 3)
			table.insert(meshData[depth][layerKey][image].vertexmap, #meshData[depth][layerKey][image].vertices + 1)
			table.insert(meshData[depth][layerKey][image].vertexmap, #meshData[depth][layerKey][image].vertices + 3)
			table.insert(meshData[depth][layerKey][image].vertexmap, #meshData[depth][layerKey][image].vertices + 4)


			local x1, y1, u1, v1, r1, g1, b1, a1
			local x2, y2, u2, v2, r2, g2, b2, a2
			local x3, y3, u3, v3, r3, g3, b3, a3
			local x4, y4, u4, v4, r4, g4, b4, a4

			-- if flat then
				x1, y1, u1, v1, r1, g1, b1, a1 = tile[1][1], tile[1][2], tile[1][3], tile[1][4], math.floor(z + 0.5), 0, 0, 255
				x2, y2, u2, v2, r2, g2, b2, a2 = tile[2][1], tile[2][2], tile[2][3], tile[2][4], math.floor(z + 0.5), 0, 0, 255
				x3, y3, u3, v3, r3, g3, b3, a3 = tile[3][1], tile[3][2], tile[3][3], tile[3][4], math.floor(z + 0.5), 0, 0, 255
				x4, y4, u4, v4, r4, g4, b4, a4 = tile[4][1], tile[4][2], tile[4][3], tile[4][4], math.floor(z + 0.5), 0, 0, 255
			-- else
			-- 	x1, y1, u1, v1, r1, g1, b1, a1 = tile[1][1], tile[1][2], tile[1][3], tile[1][4], math.floor(z + 0.5), 0, 0, 255
			-- 	x2, y2, u2, v2, r2, g2, b2, a2 = tile[2][1], tile[2][2], tile[2][3], tile[2][4], math.floor(z + 0.5), 0, 0, 255
			-- 	x3, y3, u3, v3, r3, g3, b3, a3 = tile[3][1], tile[3][2], tile[3][3], tile[3][4], math.floor(z -32 + 0.5), 0, 0, 255
			-- 	x4, y4, u4, v4, r4, g4, b4, a4 = tile[4][1], tile[4][2], tile[4][3], tile[4][4], math.floor(z -32 + 0.5), 0, 0, 255
			-- end

			x1 = x1 + x
			y1 = y1 + y
			x2 = x2 + x
			y2 = y2 + y
			x3 = x3 + x
			y3 = y3 + y
			x4 = x4 + x
			y4 = y4 + y

			if meshData[depth][layerKey][image].x1 then
				if x < meshData[depth][layerKey][image].x1 then
					meshData[depth][layerKey][image].x1 = x
				end
			else
				meshData[depth][layerKey][image].x1 = x
			end

			if meshData[depth][layerKey][image].y1 then
				if y < meshData[depth][layerKey][image].y1 then
					meshData[depth][layerKey][image].y1 = y
				end
			else
				meshData[depth][layerKey][image].y1 = y
			end

			if meshData[depth][layerKey][image].x2 then
				if x3 > meshData[depth][layerKey][image].x2 then
					meshData[depth][layerKey][image].x2 = x3
				end
			else
				meshData[depth][layerKey][image].x2 = x3
			end

			if meshData[depth][layerKey][image].y2 then
				if y3 > meshData[depth][layerKey][image].y2 then
					meshData[depth][layerKey][image].y2 = y3
				end
			else
				meshData[depth][layerKey][image].y2 = y3
			end

			table.insert(meshData[depth][layerKey][image].vertices, {x1, y1, u1, v1, r1, g1, b1, a1})
			table.insert(meshData[depth][layerKey][image].vertices, {x2, y2, u2, v2, r2, g2, b2, a2})
			table.insert(meshData[depth][layerKey][image].vertices, {x3, y3, u3, v3, r3, g3, b3, a3})
			table.insert(meshData[depth][layerKey][image].vertices, {x4, y4, u4, v4, r4, g4, b4, a4})

			--meshData[depth][image].tiles =

			--self.addToGrid()
			--table.insert(meshData[depth][image].tiles, {self.getTiles(x1, y1, x2-x1, y3-y1)})

			--print( tiles[1], tiles[2])
			--print(self.getTiles(x1, y1, x2-x1, y3-y1))

			-- have to add to the grid
			tileset = nil
			tile = nil
			depth = nil
			image = nil
		end
	end
end

local function createMeshes(map, world)
	local testdepths = 0
	local testlayers = 0
	local testint = 0
	for depth, v in pairs(map.meshData) do
		testdepths = testdepths + 1
		-- DEPTH
		local batchEntity = world.scene.newEntity()
		batchEntity.z = depth
		local x1, y1, x2, y2 = 3200, 3200, 0, 0

		for layer, vv in pairs(v) do
			testlayers = testlayers + 1
			-- LAYER

			for image, meshdata in pairs(vv) do
				-- IMAGE

				testint = testint + 1
				local sceneEntity = batchEntity.newEntity()
				sceneEntity.z = 0
				sceneEntity.drawable = love.graphics.newMesh(meshdata.vertices)
				sceneEntity.drawable:setTexture(image)
				sceneEntity.drawable:setVertexMap(meshdata.vertexmap)
				sceneEntity.drawable:setDrawMode("triangles")

				-- print(meshdata.imagepath)
				if yama.assets.loadImage(meshdata.imagepath .. "_depth") then
					sceneEntity.depthmap = yama.assets.loadImage(meshdata.imagepath.. "_depth")
				end
				
				if yama.assets.loadImage(meshdata.imagepath .. "_normal") then
					sceneEntity.normalmap = yama.assets.loadImage(meshdata.imagepath.. "_normal")
				end
				
				-- table.insert(batchEntity.batch, sceneEntity)

				--for i = 1, #meshdata.tiles do
					--print(meshdata.tiles[i][1], meshdata.tiles[i][2], meshdata.tiles[i][3], meshdata.tiles[i][4])
				--	self.addToGrid(batch, meshdata.tiles[i][1], meshdata.tiles[i][2], meshdata.tiles[i][1]+meshdata.tiles[i][3], meshdata.tiles[i][2]+meshdata.tiles[i][4])
				--end
				-- if batchEntity.x < 
				-- batchEntity

				if meshdata.x1 < x1 then
					x1 = meshdata.x1
				end
				if meshdata.y1 < y1 then
					y1 = meshdata.y1
				end
				if meshdata.x2 > x2 then
					x2 = meshdata.x2
				end
				if meshdata.y2 > y2 then
					y2 = meshdata.y2
				end

				debug.vertexcount = debug.vertexcount + #meshdata.vertices
			end
			--print(yama.tools.serialize(batchEntity))
		end

		batchEntity.x = x1
		batchEntity.y = y1
		batchEntity.width = x2 - x1
		batchEntity.height = y2 - y1

		print(batchEntity.x, batchEntity.y, batchEntity.width, batchEntity.height)
	end
	print("number of SE from map loading: " .. testint, testdepths, testlayers)
	info("Tiles: " .. map.debug.tiles .. " Triangles: " .. map.debug.triangles .. " Vertices: " .. map.debug.vertices)
end






-- Load tilesets into the asset handler.
local function loadTilesets(map)
	for i,tileset in ipairs(map.tilesets) do
		tileset.image = string.match(tileset.image, "../../images/(.*).png") or string.match(tileset.image, "../images/(.*).png") 
		local pad = false
		if tileset.properties.pad == "true" then
			pad = true
		end
		yama.assets.loadTileset(tileset.name, tileset.image, tileset.tilewidth, tileset.tileheight, tileset.spacing, tileset.margin, pad)
	end
end

-- Load layers
local function loadLayers(map, world)
	for k = 1, #map.layers do
		local layer = map.layers[k]
		local layerKey = k

		info("Loading layer #" .. k .. " " ..layer.name)
		-- if layer.properties then
		-- 	if layer.properties.z then
		-- 		print(layer.properties.z)
		-- 	else
		-- 		print(" no z")
		-- 	end
		-- else
		-- 	print("no properties")
		-- end

		if layer.type == "tilelayer" then
			
			-- TILE LAYERS
			local flat = false
			if layer.properties.flat == "true" then
				flat = true
			end
			flat = true
			for i, gid in ipairs(layer.data) do
				if gid > 0 then
					local x, y = index2xy(map, i)
					local z = tonumber(layer.properties.z) or 0
					x, y, z = getSpritePosition(map, x, y, z)
					addToMeshes(map, x, y + map.tileheight, z, gid, layerKey, flat)

					debug.tilecount = debug.tilecount + 1
				end
			end

		elseif layer.type == "objectgroup" then


			-- OBJECT GROUPS
			if layer.properties.type == "collision" then


				--COLLISION
				-- Block add to physics.
				for i, object in ipairs(layer.objects) do
					-- Creating a fixture from the object.
					local fixture = createFixture(world.physics, object, "static")

					if fixture then
						-- And setting the userdata from the object.
						fixture:setUserData({name = object.name, type = object.type, properties = object.properties})

						-- Setting filter data from object properties. (category, mask, groupindex)
						if object.properties.category then
							local category = {}
							for x in string.gmatch(object.properties.category, "%P+") do
								x = tonumber(string.match(x, "%S+"))
								if x then
									table.insert(category, x)
								end
							end
							fixture:setCategory(unpack(category))
						end
						if object.properties.mask then
							local mask = {}
							for x in string.gmatch(object.properties.mask, "%P+") do
								x = tonumber(string.match(x, "%S+"))
								if x then
									table.insert(mask, x)
								end
							end
							fixture:setMask(unpack(mask))
						end
						if object.properties.groupindex then
							fixture:setGroupIndex(tonumber(object.properties.groupindex))
						end
					else
						warning("Physics not enabled. No fixture created.")
					end
				end


			elseif layer.properties.type == "entities" then


				-- ENTITIES
				-- Spawning entities.
				for _, object in ipairs(layer.objects) do
					if object.type == "" then
						-- STATIC TILE
						local z = tonumber(object.properties.z) or 1
						z = z * map.tileheight
						addToMeshes(map, object.x, object.y, z, object.gid, layerKey)

						debug.tilecount = debug.tilecount + 1

						z = nil
						
					elseif object.type and object.type ~= "" then
						object.z = tonumber(object.properties.z) or 1
						object.z = object.z * map.tileheight
						object.properties.z = nil
						self.spawnXYZ(object.type, object.x + object.width / 2, object.y + object.height / 2, object.z, object)
					end
				end


			elseif layer.properties.type == "paths" then

				-- PATHS
				-- Adding paths to the patrols table.
				for i, object in ipairs(layer.objects) do
					if object.shape == "polyline" then
						local path = {}
						path.name = object.name
						path.type = object.type
						path.properties = object.properties
						path.vertices = {}
						for k, vertex in ipairs(object.polyline) do
							table.insert(path.vertices, {x = object.polyline[k].x+object.x, y = object.polyline[k].y+object.y})
						end
						world.paths[path.name] = path
					end
				end


			elseif layer.properties.type == "portals" then


				-- PORTALS
				-- Creating portal fixtures.
				for i, object in ipairs(layer.objects) do
					local fixture = createFixture(object, "static")
					if fixture then
						fixture:setUserData({name = object.name, type = "portal", properties = object.properties})
						fixture:setSensor(true)
					end
				end


			elseif layer.properties.type == "locations" then


				-- LOCATIONS
				-- Adding locations to the location list
				for i, object in ipairs(layer.objects) do
					local location = {}
					location.name = object.name
					location.type = object.type
					location.properties = object.properties

					location.x = object.x + object.width / 2
					location.y = object.y + object.height / 2
					location.z = tonumber(object.properties.z) or 0
					--location.z = spawn.z * map.tileheight
					world.locations[location.name] = location
				end
			end


		end
	end
end



-- MAPS - For loading Tiled maps
local function load(world, path, offset)

	if love.filesystem.isFile(yama.paths.maps .. "/" .. path .. ".lua") then
		



		local map = require(yama.paths.maps .. "/" .. path)

		-- TEMP VARS, should be nilled later.
		map.meshData = {}
		map.debug = {}
		map.debug.tiles = 0
		map.debug.vertices = 0
		map.debug.triangles = 0

		-- DEPTH
		if map.properties.sortmode then
			map.depthmode = map.properties.sortmode
		else
			map.depthmode = "z"
		end
		map.depthmode = "yz"



		-- Actual loading
		debug.timestamp1 = os.clock()

		loadTilesets(map)

		debug.timestamp2 = os.clock()

		loadLayers(map, world)

		debug.timestamp3 = os.clock()

		createMeshes(map, world)

		debug.timestamp4 = os.clock()


		--maps[path] = map

		--if map.properties == "false" then
			-- self.boundingbox.x = 0
			-- self.boundingbox.y = 0
			-- self.boundingbox.width = map.width * map.tilewidth
			-- self.boundingbox.height = map.height * map.tileheight
		--end

		debug.end_time = os.clock()
		debug.load_time = debug.end_time - debug.start_time
		debug.pre = debug.timestamp1 - debug.start_time
		debug.loadTilesets = debug.timestamp2 - debug.timestamp1
		debug.loadLayers = debug.timestamp3 - debug.timestamp2
		debug.createMeshes = debug.timestamp4 - debug.timestamp3
		debug.post = debug.end_time - debug.timestamp4
		map.debug = debug

		maps[path] = map
		return map
	end
end

local function loadOld(world, path, offset)
	--if maps[path] then
	--	info(path .. " already loaded.")
	--else
		--if self.maps.new(path) then
			--[[
			info("Successfully loaded map \"" .. path .. "\" in " .. maps[path].debug.load_time .. " seconds.")
			print("Pre stuff " .. maps[path].debug.pre)
			print("loadTilesets() " .. maps[path].debug.loadTilesets)
			print("loadLayers() " .. maps[path].debug.loadLayers)
			print("createMeshes() " .. maps[path].debug.createMeshes)
			print("post stuff " .. maps[path].debug.post)
			print("sum: " .. maps[path].debug.pre + maps[path].debug.loadTilesets + maps[path].debug.loadLayers + maps[path].debug.createMeshes + maps[path].debug.post)

			--info(maps[path].debug.tilecount .. " tiles, " .. #maps[path].bufferbatches .. " meshes.")
			--]]
		--end
	--end

	--return maps[path]
	return self.maps.new(world, path, offset)
end

return {
	load = load
}