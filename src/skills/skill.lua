skill = {}

function skill.new(map)
	local self = {}
	local scene = map

	self.components = {}

	-- public functions
	function self.update(dt) 
	end
	
	function self.execute()	
		for i=1,#self.components do
			self.components[i].execute()
		end
	end
	
	function self.initialize(properties)
		-- properties can contain:

		-- level = integer
		-- mandatory = { {name="name", properties=properties}, ... }
		-- 		

		if properties.mandatory then
			for k,v in pairs(properties.mandatory) do
				local component = scene.newEntity(v.name, {0, 0, 0}, v.properties or {})

				table.insert(self.components, component)
			end
		end

	end


	return self
end



return skill