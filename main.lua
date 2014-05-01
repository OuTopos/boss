require("strict")

-- yama should be local. have to fix.
yama = require("lib.yama")

local game = {}

function love.load()
	yama.load()

	love.window.setTitle("Yama")
	love.window.setIcon(love.image.newImageData("assets/images/icon.png"))
	love.window.setMode(1920, 1080, {
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

	game.scene = yama.newScene()
	game.scene.enablePhysics()
	game.scene.loadMap("test/start")
	
	-- todo: check joy
	local nbJoy = love.joystick.getJoystickCount( )

	game.players = {}
	if nbJoy > 0 then 
		for i=1, nbJoy do
			local p = game.scene.newEntity("player", {1000, 500, 0}, { name = "Player "..i })
			
			-- Temporary to test
			local ab = game.skills.base.new(game)
			ab.initialize({mandatory = { { name = "range", properties = { origin = p}, } } })
			p.setSkill("rightshoulder", ab)

			local ab2 = game.skills.base.new(game)
			ab2.initialize({mandatory = { { name = "close", properties = { origin = p}, } } })
			p.setSkill("leftshoulder", ab2)

			p.setJoystick(love.joystick.getJoysticks()[i])		
			table.insert(game.players, p)
		end
	else
		assert("no joysticks found")
	end

	game.boss = game.scene.newEntity("boss", {500,500, 0})

	game.vp1 = game.scene.newViewport()
	game.vp1.camera.cx = love.window.getWidth() / 2
	game.vp1.camera.cy = love.window.getHeight() / 2
	-- game.vp1.follow(game.players[1])


	game.resize()
end

function love.update(dt)
	yama.update(dt)
end

function love.draw()
	yama.draw()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
	if key == "h" then
		if yama.hud.enabled then
			yama.hud.enabled = false
		else
			yama.hud.enabled = true
		end
	end
	if key == "j" then
		if yama.hud.physics then
			yama.hud.physics = false
		else
			yama.hud.physics = true
		end
	end

	if key == "p" then
		if yama.v.paused then
			yama.v.paused = false
		else
			yama.v.paused = true
		end
	end

	if key == "n" then
		game.vp1.camera.r = game.vp1.camera.r + 0.1
	end

	if key == "m" then
		game.vp1.camera.r = game.vp1.camera.r - 0.1
	end

	if key == "k" then
		if game.vp1.parallax.enabled then
			game.vp1.parallax.enabled = false
		else
			game.vp1.parallax.enabled = true
		end
	end

	if key == "1" then
		game.vp1.zoom(1)
	end

	if key == "2" then
		game.vp1.zoom(2)
	end

	if key == "3" then
		game.vp1.zoom(3)
	end

	if key == "4" then
		game.vp1.zoom(4)
	end

	if key == "5" then
		game.vp1.zoom(0.5)
	end

	if key == "6" then
		game.vp1.zoom(8)
	end

	if key == "0" then
		local scale = game.vp1.camera.sx + 1
		if scale > 5 then
			scale = 1
		end
		game.vp1.camera.zoom(scale)
	end

	if key == "+" then
		if game.vp1.camera.round then
			game.vp1.camera.round = false
		else
			game.vp1.camera.round = true
		end
	end

	if key == "q" then
		game.scene.drawmode = 0
	end

	if key == "w" then
		game.scene.drawmode = 1
	end

	if key == "e" then
		game.scene.drawmode = 2
	end

	if key == "r" then
		game.scene.drawmode = 3
	end
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
end