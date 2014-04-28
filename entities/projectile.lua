local projectile = {}

function projectile.new( map, x, y, z )
	local self = {}



	local bulletUserdata = {}
	bulletUserdata.name = "Unnamed"
	bulletUserdata.type = "projectile"
	bulletUserdata.properties = {}
	bulletUserdata.id = 0
	bulletUserdata.callbacks = self

	self.weaponProperties = {}

	self.x = x
	self.y = y
	self.z = z	

	-- Common variables
	local width, height = 5, 5
	local width2, height2 = 4, 4
	local ox, oy = width2/2, height2/2
	local sx, sy = 1, 1
	local r = 0	

	self.bulletTimer = 0
	self.bounces = 0

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch( self.x, self.y, self.z )

	-- SPRITE (PLAYER)	
	local bulletsprite = yama.buffers.newDrawable( yama.assets.loadImage( "projectile" ), self.x, self.y, self.z, r, sx, sy, ox, oy )


	table.insert( bufferBatch.data, bulletsprite )

	function self.initialize( properties )

		print("CREATED")

		self.weaponProperties = properties
		-- Physics		
		self.bullet = love.physics.newFixture(love.physics.newBody( map.world, self.x, self.y, "dynamic"), love.physics.newCircleShape( self.weaponProperties.sizeX ) )

		self.bullet:setGroupIndex( -1 )
		self.bullet:setCategory( 2 )
		self.bullet:setMask( 2 )
		self.bullet:setUserData( bulletUserdata )
		self.bullet:setRestitution( 0.90 )
		self.bullet:getBody( ):setFixedRotation( false )
		self.bullet:getBody( ):setLinearDamping( self.weaponProperties.linearDamping )
		self.bullet:getBody( ):setMass( self.weaponProperties.bulletWeight )
		self.bullet:getBody( ):setInertia( self.weaponProperties.inertia )
		self.bullet:getBody( ):setGravityScale( self.weaponProperties.gravityScale )
		self.bullet:getBody( ):setBullet( true )
	end

	function self.update( dt )

		self.updatePosition( )

		self.x = x
		self.y = y
		self.z = z

		if self.bulletTimer <= self.weaponProperties.lifetime then
			self.bulletTimer = self.bulletTimer + dt
		else
			--print( "bulletTimer ends! killing bullet")
			self.bulletTimer = 0
			self.destroy()
			print("Bullet: update: lifetime run out!")
		end
	end
	
	function self.shoot( xpos, ypos, fx, fy, props )
		self.weaponProperties = props

		print("Bullet: shoot!")
		self.bulletTimer = 0

		self.bullet:setUserData( bulletUserdata )
		self.bullet:getBody( ):setLinearDamping( self.weaponProperties.linearDamping )
		self.bullet:getBody( ):setMass( self.weaponProperties.bulletWeight )
		self.bullet:getBody( ):setInertia( self.weaponProperties.inertia )
		self.bullet:getBody( ):setGravityScale( self.weaponProperties.gravityScale )
		self.bullet:getBody( ):setPosition( xpos, ypos )

		self.bullet:getBody( ):applyLinearImpulse( fx, fy )

	end

	function self.updatePosition( xn, yn )
		x = self.bullet:getBody( ):getX( )
		y = self.bullet:getBody( ):getY( )
		r = self.bullet:getBody( ):getAngle( )

		bufferBatch.x = x
		bufferBatch.y = y
		bufferBatch.z = 100
		bufferBatch.r = r
		
		bulletsprite.x = x --math.floor(x + 0.5)
		bulletsprite.y = y --math.floor(y-16 + 0.5)
		bulletsprite.r = 0

	end

	local animation = {}
	animation.quad = 1
	animation.dt = 0

	-- CONTACT --
	function self.beginContact( a, b, contact )
		local userdata = b:getUserData( )
		self.bounces = self.bounces + 1
		if self.weaponProperties.nrBounces and self.bounces > self.weaponProperties.nrBounces then
			if self.weaponProperties.blastRadius > 0 then
				--print( "max bullet bounces reached! Killing bullet ")
				contact:setRestitution( 0 )
				self.destroy()
			else
				self.destroy()
			end
		end
	end
	function self.endContact( a, b, contact )
		local userdata = b:getUserData( )
		if userdata then
			if userdata.type == 'shield' then  
				--print('bullet: shield end contact!')
			elseif userdata.type == 'player' then
				--print('bullet: body end contact!')
			end
		end
	end

	function self.draw( )

		love.graphics.setColorMode( "modulate" )

		love.graphics.setColor( 255, 255, 255, 255 );
		love.graphics.setBlendMode( "alpha" )

		if hud.enabled then
			physics.draw( bullet, { 0, 255, 0, 102 } )
		end

	end

	function self.addToBuffer( vp )
		vp.addToBuffer( bufferBatch )
	end


	-- Basic functions
	function self.setPosition( x, y )
		bullet.body:setPosition( x, y )
		bullet.body:setLinearVelocity( 0, 0 )
	end
	
	function self.getPosition( )
		return x, y
	end

	function self.getXvel( )
		return xvel
	end
	function self.getYvel( )
		return yvel
	end

	function self.destroy()

			print("Bullet: Destroy!")
			self.bullet:getBody():destroy()
			self.destroyed = true
	end

	return self
end

return projectile