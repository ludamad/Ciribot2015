###*
# Player Entity
###

MAX_SPEED = 6
MIN_SPEED = 4
SPEED_INCR = 1/8
MIN_JUMP = 12
MAX_JUMP = 14

jumpReleased = false

me.event.subscribe me.event.KEYUP, (action, keyCode) ->
    if keyCode == me.input.KEY.W or keyCode == me.input.KEY.UP
        jumpReleased = true

wouldCollide = (obj, dx, dy) ->
    B = obj.getBounds()
    B.pos.x += dx; B.pos.y += dy
    obj.collided = false
    me.collision.check(obj)
    B.pos.x -= dx; B.pos.y -= dy
    return obj.collided

game.PlayerEntity = me.Entity.extend {
    init: (x, y, settings) ->
        settings.spritewidth = settings.width = 33
        settings.spriteheight = settings.height = 43
        @collided = false
        @_super(me.Entity, 'init', [x, y, settings])
        # set the default horizontal & vertical speed (accel vector)
        @body.setVelocity(MAX_SPEED, MAX_JUMP)
        # set the display to follow our position on both axis
        me.game.viewport.follow(@pos, me.game.viewport.AXIS.BOTH)
        me.game.viewport.setDeadzone(0, 100)
        # ensure the player is updated even when outside of the viewport
        @alwaysUpdate = true
        @renderable.addAnimation('walk', [0])
        @renderable.addAnimation('stand', [0])
        @renderable.setCurrentAnimation('stand')
        @renderable.draw = (renderer) ->

    _doStep: (dt) ->
        @body.update(dt)
    draw : (renderer) ->
        _bounds = @getBounds()
        x = Math.round(0.5 + _bounds.pos.x + @anchorPoint.x * (_bounds.width - @renderable.width))
        y = Math.round(0.5 + _bounds.pos.y + @anchorPoint.y * (_bounds.height - @renderable.height))
        renderer.translate(x, y)
        @renderable.draw(renderer)
        renderer.translate(-x, -y)
    jump: () ->
        if wouldCollide(@, 0, Math.max(4, @body.vel.y))
            charge_percent = Math.max(Math.abs(@body.vel.x) - MIN_SPEED, 0) / (MAX_SPEED - MIN_SPEED)
            # set current vel to the maximum defined value
            # gravity will then do the rest
            @body.vel.y = -(MIN_JUMP + (MAX_JUMP - MIN_JUMP) * charge_percent)
            # set the jumping flag
            @body.jumping = true
    update: (dt) ->
        if me.input.isKeyPressed('left')
            # flip the sprite on horizontal axis
            @renderable.flipX(true)
            # update the entity velocity
            @body.vel.x = Math.min(@body.vel.x - SPEED_INCR, -MIN_SPEED)
            # change to the walking animation
            if !@renderable.isCurrentAnimation('walk')
                @renderable.setCurrentAnimation('walk')
        else if me.input.isKeyPressed('right')
            # unflip the sprite
            @renderable.flipX(false)
            # update the entity velocity
            @body.vel.x = Math.max(@body.vel.x + SPEED_INCR, MIN_SPEED)
            # change to the walking animation
            if !@renderable.isCurrentAnimation('walk')
                @renderable.setCurrentAnimation('walk')
        else
            @body.vel.x = 0
            # change to the standing animation
            @renderable.setCurrentAnimation 'stand'

        # holdingJump = me.input.isKeyPressed('jump')
        # # Jump on every 'edge'
        if jumpReleased or me.input.isKeyPressed('jump') #holding_jump != holdingJump
            @jump()
        jumpReleased = false
        # holding_jump = holdingJump
        # apply physics to the body (this moves the entity)
        @_doStep(dt)
        # handle collisions against other shapes
        me.collision.check(@)
        # return true if we moved or if the renderable was updated
        @_super(me.Entity, 'update', [ dt ]) or @body.vel.x != 0 or @body.vel.y != 0
    onCollision: (response, other) ->
        switch response.b.body.collisionType
            when me.collision.types.WORLD_SHAPE
                @collided = true
                return true
            when me.collision.types.ENEMY_OBJECT
                if response.overlapV.y > 0 and !@body.jumping
                    # bounce (force jump)
                    @body.falling = false
                    @body.vel.y = -@body.maxVel.y
                    # set the jumping flag
                    @body.jumping = true
                    # play some audio
                    me.audio.play 'stomp'
                return false
            else
                # Do not respond to other objects (e.g. coins)
                return false
        # Make the object solid
        return true
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
            @body.vel.x += if @walkLeft then -@body.accel.x else @body.accel.x
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
            # if @alive and response.overlapV.y > 0 and response.a.body.falling
            #     @renderable.flicker 750
            return false
        # Make all other objects solid
        return true
}
