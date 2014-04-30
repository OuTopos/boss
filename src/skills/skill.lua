skill = {}

function skill.new(game)
	local self = {}

	local game = game
	local scene = game.scene

	self.components = {}

	-- public functions
	function self.update(dt)
 		for i=1,#self.components do
			self.components[i].update(dt)
		end
	end
	
	function self.execute()	
		for i=1,#self.components do
			self.components[i].execute()
		end
	end
	
	function self.initialize(properties)
		-- WIP
		-- Currently NEEDs a mandatory table.

		-- properties can contain:

		-- level = integer
		-- mandatory = { {name="name", properties=properties}, ... }
		-- 

		if properties.mandatory then
			for k,v in pairs(properties.mandatory) do
				local component = game.skills[v.name].new(game.scene)
				component.initialize(v.properties)

				table.insert(self.components, component)
			end
		end

	end


	return self
end



return skill