local yama = require((...):match("(.+)%.[^%.]+$") .. "/yama/table")

-- Paths

yama.paths = {}
yama.paths.lib = "lib"
yama.paths.src = "src"
yama.paths.assets = "assets"

yama.paths.entities = yama.paths.src .. "/entities"

yama.paths.tilesets = yama.paths.assets .. "/tilesets"
yama.paths.images = yama.paths.assets .. "/images"
yama.paths.animations = yama.paths.assets .. "/animations"
yama.paths.maps = yama.paths.assets .. "/maps"

-- MODULES
yama.assets         = require(yama.paths.lib .. "/yama.assets")
yama.animations     = require(yama.paths.lib .. "/yama.animations")
yama.newAnimation = yama.animations.new

yama.worlds         = require(yama.paths.lib .. "/yama.worlds")
yama.scenes         = require(yama.paths.lib .. "/yama.scenes")
yama.viewports      = require(yama.paths.lib .. "/yama.viewports")
yama.maps           = require(yama.paths.lib .. "/yama.maps")

yama.gui            = require(yama.paths.lib .. "/yama.gui")
yama.hud            = require(yama.paths.lib .. "/yama.hud")
yama.physics        = require(yama.paths.lib .. "/yama.physics")

yama.tools		    = require(yama.paths.lib .. ".yama.tools")

-- Phase these out

yama.buffers      	= require(yama.paths.lib .. "/yama.buffers")
yama.ai             = require(yama.paths.lib .. "/yama.ai")
yama.ai.patrols     = require(yama.paths.lib .. "/yama.ai_patrols")

-- VARIABLES
yama.v = {}
yama.v.paused = false
yama.v.gcInterval = 10
yama.v.gcTimer = 10


-- DEBUG FUNCTIONS
yama.log = love.filesystem.newFile("yama.log")
yama.log:open("w")


yama.debug = {}
yama.debug.level = 2
yama.debug.warning2error = false
yama.debug.log = false

function info(text, i)
	if yama.debug.level >= 2 then
		local info = debug.getinfo(i or 2, "lS")
		print("Info: " .. info.short_src .. ":" .. info.currentline .. ": " .. text)
		yama.log:write("Info: " .. info.short_src .. ":" .. info.currentline .. ": " .. text .. "\r\n")
	end
end
function warning(text, i)
	if yama.debug.level >= 1 then
		if yama.debug.warning2error then
			error(text)
		else
			local info = debug.getinfo(i or 2, "lS")
			print("Warning: " .. info.short_src .. ":" .. info.currentline .. ": " .. text)
			yama.log:write("Warning: " .. info.short_src .. ":" .. info.currentline .. ": " .. text .. "\r\n")
		end
	end
end


-- TOOLS

local function requireDir(path)
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


local function load()
	--love.graphics.setDefaultFilter("linear", "linear")
	love.graphics.setDefaultFilter("nearest", "nearest")


	yama.assets.load()
	--yama.gui.load()

	-- Loading entities
	yama.entities = requireDir(yama.paths.entities)

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

local function update(dt)
	if not yama.v.paused then
		yama.worlds.update(dt)
	end
	yama.viewports.update(dt)
end

local function draw()
	-- yama.worlds.draw()
	yama.viewports.draw()

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

return {
	load = load,
	update = update,
	draw = draw,

	newWorld = yama.worlds.new,
	newViewport = yama.viewports.new,
	newAnimation = yama.animations.new,

	keybindings = yama.keybindings,

	requireDir = requireDir,

	assets = yama.assets,
	tools = yama.tools,
}