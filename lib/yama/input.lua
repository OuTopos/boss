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

input.joysticks = {}

function love.joystickadded(joystick)
	table.insert(input.joysticks, joystick)
end


function love.joystickremoved(joystick)

end

local function newGamepad(joystick)
	


	return {
		joystick = joystick,
	}
end

return {
	newGamepad = newGamepad,
}