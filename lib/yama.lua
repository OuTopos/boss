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
yama.assets         = require(P.LIB .. "/yama.assets")
yama.animations     = require(P.LIB .. "/yama.animations")
yama.entities       = require(P.LIB .. "/yama.entities")
yama.scenes         = require(P.LIB .. "/yama.scenes")
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

function yama.load()
	yama.assets.load()
	yama.gui.load()
	yama.entities.load()

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

-- DEBUG FUNCTIONS
function info(text, i)
	local info = debug.getinfo(i or 2, "lS")
	print("Info: " .. info.short_src .. ":" .. info.currentline .. ": " .. text)
end
function warning(text, i)
	local info = debug.getinfo(i or 2, "lS")
	print("Warning: " .. info.short_src .. ":" .. info.currentline .. ": " .. text)
end

return yama