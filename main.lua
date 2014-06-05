require("strict")

local yama = require("lib.yama")
local game = {}

function love.load()
	yama.load()

	love.window.setMode(1280, 720, {
		fullscreen = false,
		fullscreentype = "desktop",
		vsync = false,
		fsaa = 0,
		resizable = true,
		borderless = false,
		centered = true,
	})

	love.graphics.setFont(love.graphics.newImageFont(yama.assets.loadImage("font")," abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\""))

	-- All skills loaded into game.skills.
	game.skills = {
	 	base = require("src/skills/base"),
	
	 	components = yama.requireDir("src/skills/components"),

		attacks = yama.requireDir("src/skills/attack"),
		defends = yama.requireDir("src/skills/defend"),
		heals = yama.requireDir("src/skills/heal"),
	}

	game.world = yama.newWorld()
	game.world.enablePhysics()
	game.world.loadMap("test/start")

	game.buttonStates = {}
	game.buttonStates["lefttrigger"] = false
	
	-- todo: check joy
	local nbJoy = love.joystick.getJoystickCount( )

	game.players = {}
	if nbJoy > 0 then 
		for i=1, nbJoy do
			local p = game.world.newEntity("player", {1000, 500, 0}, { name = "Player "..i })
			
			-- Temporary to test
			local ab = game.skills.base.new(game, p)
			ab.initialize({mandatory = { { name = "range",  } } })
			p.setSkill("rightshoulder", ab)

			local ab2 = game.skills.base.new(game, p)
			ab2.initialize({mandatory = { { name = "close", } } })
			p.setSkill("leftshoulder", ab2)

			local ab3 = game.skills.base.new(game, p)
			ab3.initialize({mandatory = { { name = "shield", } } })
			p.setSkill("lefttrigger", ab3)

			p.setJoystick(love.joystick.getJoysticks()[i])		
			table.insert(game.players, p)
		end
	else
		assert("no joysticks found")
	end

	game.boss = game.world.newEntity("boss", {500,500, 0})
	game.boss = game.world.newEntity("boss", {500,600, 0})

	game.vp1 = yama.newViewport()
	game.vp1.attach(game.world)
	game.vp1.camera.cx = love.window.getWidth() / 2
	game.vp1.camera.cy = love.window.getHeight() / 2
	game.vp1.follow(game.players[1])



	-- Adding keybindings for drawmodes
	yama.keybindings["q"] = function()
		game.vp1.drawmode = 0
	end

	yama.keybindings["w"] = function()
		game.vp1.drawmode = 1
	end

	yama.keybindings["e"] = function()
		game.vp1.drawmode = 2
	end

	yama.keybindings["r"] = function()
		game.vp1.drawmode = 3
	end


	game.resize()
end

function love.update(dt)
	yama.update(dt)
	for i in ipairs(game.players) do
		-- simulate gamepadpressed/released on axis 5
		if game.players[i].joystick:getAxis(5) > 0.2 and not game.buttonStates["lefttrigger"] then
			game.buttonStates["lefttrigger"] = true
			game.players[i].gamepadpressed( "lefttrigger" )
		elseif game.players[i].joystick:getAxis(5) < 0.2 and game.buttonStates["lefttrigger"] then
			game.players[i].gamepadreleased( "lefttrigger" )
			game.buttonStates["lefttrigger"] = false
		end
		if game.players[i].joystick:isGamepadDown("rightshoulder") then
			game.players[i].gamepaddown( "rightshoulder" )
			game.buttonStates["rightshoulder"] = true
		end
		if not game.players[i].joystick:isGamepadDown("rightshoulder") then
			game.buttonStates["rightshoulder"] = false
		end
	end
end

function love.draw()
	yama.draw()
end

function love.gamepadpressed(joystick, button)
	game.players[joystick:getID( )].gamepadpressed( button )
end

function love.gamepadreleased(joystick, button)
	game.players[joystick:getID( )].gamepadreleased( button )
end

function love.resize(w, h)
	game.resize()
end

function love.joystickadded(joystick)
	joysticks = love.joystick.getJoysticks()
end
function love.joystickremoved(joystick)
	joysticks = love.joystick.getJoysticks()
end

function love.threaderror(t, e)
	return error(e)
end

function game.resize()
	game.vp1.resize(love.window.getWidth(), love.window.getHeight())
	-- game.vp1.zoom(4, 4)
end