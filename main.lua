require("strict")

yama = require("yama")

game = {}

function love.load()
	yama.load()

	love.window.setTitle("Yama")
	love.window.setIcon(love.image.newImageData("icon.png"))
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

	game.scene = yama.scenes.new()
	game.scene.enablePhysics()
	game.scene.loadMap("test/start")

	game.p1 = game.scene.newEntity("player", {1000, 500, 32})

	game.vp1 = game.scene.newViewport()
	game.vp1.follow(game.p1)


	game.vp2 = game.scene.newViewport()
	game.vp2.follow(game.p1)

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
	game.vp1.resize(love.window.getWidth() / 4, love.window.getHeight() / 2)
	game.vp1.sx = 2
	game.vp1.sy = 2

	game.vp2.resize(love.window.getWidth() / 2, love.window.getHeight())
	game.vp2.x = love.window.getWidth() / 2
end