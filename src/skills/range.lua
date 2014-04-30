range = {}

function range.new(map)
	local self = {}
	local scene = map
	
	self.lastShot = 0

	-- public functions
	function self.update(dt)
		self.lastShot = self.lastShot + dt
	end

	function self.initialize(properties)
		self.origin = properties.origin
	end

	function self.execute()
	  	if self.lastShot > self.weapon.properties.rps then
			self.lastShot = 0 

			for i=1,self.weapon.properties.nrBulletsPerShot do				
				-- calculate projectile spawn position and offset
				local projectileSpawnPosX = self.origin.x + 29*math.cos( self.origin.aim )
				local projectileSpawnPosY = self.origin.y + 29*math.sin( self.origin.aim )

				-- create projectile
				local projectile = scene.newEntity( "projectile", {projectileSpawnPosX, projectileSpawnPosY, 0}, self.weapon.properties )

				-- calculate spread 
				local spread = love.math.random(0,self.weapon.properties.spread)
				spread = spread/100	
				if spread > self.weapon.properties.spread then
					spread = self.weapon.properties.spread
				end
				if love.math.random(0,1) == 1 then
					spread = - spread
				end
				local aimSpread =  self.origin.aim + spread
				local vectorSpreadX = math.cos( aimSpread )
				local vectorSpreadY = math.sin( aimSpread )
				
				local fxprojectile = self.weapon.properties.impulseForce * vectorSpreadX
				local fyprojectile = self.weapon.properties.impulseForce * vectorSpreadY

				projectile.execute( projectileSpawnPosX, projectileSpawnPosY, fxprojectile, fyprojectile, self.weapon.properties )
				projectile = nil
			end
		end
	end	

	-- private functions
	function self.weaponSetup()
		-- WEAPON STUFF 
		self.weapon = {}
		self.weapon.properties = {}
		self.weapon.properties.name = 'bouncer'
		self.weapon.properties.rps = 0.2
		self.weapon.properties.damageBody = 9
		self.weapon.properties.damageShield = 17
		self.weapon.properties.impulseForce = 900
		self.weapon.properties.nrBulletsPerShot = 100
		self.weapon.properties.magCapacity = 50
		self.weapon.properties.spread = 360
		self.weapon.properties.nrBounces = 1
		self.weapon.properties.blastRadius = 0
		self.weapon.properties.lifetime = 5
		self.weapon.properties.bulletWeight = 0.4
		self.weapon.properties.sizeX = 1
		self.weapon.properties.linearDamping = 0.5
		self.weapon.properties.inertia = 0.2
		self.weapon.properties.gravityScale = 0.01

	end
	
	-- initialize myself
	self.weaponSetup()

	return self
end

return range