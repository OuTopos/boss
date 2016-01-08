local yama = require((...):match("(.+)%.[^%.]+$") .. "/table")

local function new()
	local x = 0
	local y = 0

	return {
		x = x,
		y = y
	}
end

return {
	new = new
}