local yama = require((...):match("(.+)%.[^%.]+$") .. "/table")
local input = {}

yama.keybindings = {}
yama.gamepadreleased = {}
function love.gamepadreleased(joystick, button)
	if yama.gamepadreleased[key] then
		if type(yama.gamepadreleased[key]) == "function" then
			yama.gamepadreleased[key]()
		end
	end
end

return input