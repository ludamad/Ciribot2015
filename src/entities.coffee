###*
# Player Entity
###

game.PlayerEntity = me.Entity.extend {
    init: (x, y, settings) ->
        settings.spritewidth = settings.width = 33
        settings.spriteheight = settings.height = 43
        @_super(me.Entity, 'init', [x, y, settings])
        # set the default horizontal & vertical speed (accel vector)
        @body.setVelocity(3, 15)
        # set the display to follow our position on both axis
        me.game.viewport.follow(@pos, me.game.viewport.AXIS.BOTH)
        # ensure the player is updated even when outside of the viewport
        @alwaysUpdate = true
        @renderable.addAnimation('walk', [0])
        @renderable.addAnimation('stand', [0])
        @renderable.setCurrentAnimation('stand')
    update: (dt) ->
        if me.input.isKeyPressed('left')
            # flip the sprite on horizontal axis
            @renderable.flipX true
            # update the entity velocity
            @body.vel.x -= @body.accel.x * me.timer.tick
            # change to the walking animation
            if !@renderable.isCurrentAnimation('walk')
                @renderable.setCurrentAnimation 'walk'
        else if me.input.isKeyPressed('right')
            # unflip the sprite
            @renderable.flipX false
            # update the entity velocity
            @body.vel.x += @body.accel.x * me.timer.tick
            # change to the walking animation
            if !@renderable.isCurrentAnimation('walk')
                @renderable.setCurrentAnimation('walk')
        else
            @body.vel.x = 0
            # change to the standing animation
            @renderable.setCurrentAnimation 'stand'
        if me.input.isKeyPressed('jump')
            if !@body.jumping and !@body.falling
                # set current vel to the maximum defined value
                # gravity will then do the rest
                @body.vel.y = -@body.maxVel.y * me.timer.tick
                # set the jumping flag
                @body.jumping = true
                # play some audio 
                me.audio.play 'jump'
        # apply physics to the body (this moves the entity)
        @body.update(dt)
        # handle collisions against other shapes
        me.collision.check(this)
        # return true if we moved or if the renderable was updated
        @_super(me.Entity, 'update', [ dt ]) or @body.vel.x != 0 or @body.vel.y != 0
    onCollision: (response, other) ->
        switch response.b.body.collisionType
            when me.collision.types.WORLD_SHAPE
                # Simulate a platform object
                if other.type == 'platform'
                    # Repond to the platform (it is solid)
                    return true
            when me.collision.types.ENEMY_OBJECT
                if response.overlapV.y > 0 and !@body.jumping
                    # bounce (force jump)
                    @body.falling = false
                    @body.vel.y = -@body.maxVel.y * me.timer.tick
                    # set the jumping flag
                    @body.jumping = true
                    # play some audio
                    me.audio.play 'stomp'
                else
                    # let's flicker in case we touched an enemy
                    @renderable.flicker 750
                return false
            else
                # Do not respond to other objects (e.g. coins)
                return false
        # Make the object solid
        true
}

###*
# Coin Entity
###

game.CoinEntity = me.CollectableEntity.extend {
    init: (x, y, settings) ->
        # call the parent constructor
        @_super(me.CollectableEntity, 'init', [x, y, settings])
    onCollision: (response, other) ->
        # do something when collide
        me.audio.play 'cling'
        # give some score
        game.data.score += 250
        # make sure it cannot be collected "again"
        @body.setCollisionMask(me.collision.types.NO_OBJECT)
        # remove it
        me.game.world.removeChild(this)
        return false
}

###*
# Enemy Entity
###

game.EnemyEntity = me.Entity.extend {
    init: (x, y, settings) ->
        # define this here instead of tiled
        settings.image = 'monsters'
        # save the area size defined in Tiled
        width = settings.width
        height = settings.height
        # adjust the size setting information to match the sprite size
        # so that the entity object is created with the right size
        settings.spritewidth = settings.width = 32
        settings.spriteheight = settings.height = 32
        # call the parent constructor
        @_super(me.Entity, 'init', [x, y, settings])
        # set start/end position based on the initial area size
        x = @pos.x
        @startX = x
        @endX = x + width - settings.spritewidth
        @pos.x = x + width - settings.spritewidth
        # manually update the entity bounds as we manually change the position
        @updateBounds()
        # to remember which side we were walking
        @walkLeft = false
        # walking & jumping speed
        @body.setVelocity 4, 6
        @renderable.addAnimation('stand', [1])
        @renderable.setCurrentAnimation('stand')
    update: (dt) ->
        if @alive
            if @walkLeft and @pos.x <= @startX
                @walkLeft = false
            else if !@walkLeft and @pos.x >= @endX
                @walkLeft = true
            @renderable.flipX @walkLeft
            @body.vel.x += if @walkLeft then -@body.accel.x * me.timer.tick else @body.accel.x * me.timer.tick
        else
            @body.vel.x = 0
        # check & update movement
        @body.update(dt)
        # handle collisions against other shapes
        me.collision.check(this)
        # return true if we moved or if the renderable was updated
        @_super(me.Entity, 'update', [ dt ]) or @body.vel.x != 0 or @body.vel.y != 0
    onCollision: (response, other) ->
        if response.b.body.collisionType != me.collision.types.WORLD_SHAPE
            # res.y >0 means touched by something on the bottom
            # which mean at top position for this one
            if @alive and response.overlapV.y > 0 and response.a.body.falling
                @renderable.flicker 750
            return false
        # Make all other objects solid
        return true
}
