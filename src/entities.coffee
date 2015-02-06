###*
# Player Entity
###

MAX_SPEED = 9
MIN_SPEED = 5
SPEED_INCR = 1/4
MIN_JUMP = 11
MAX_JUMP = 14
BLOCK_FRAMES_TO_LIVE = 800

T = me.collision.types
solidMask = T.WORLD_SHAPE | T.PLAYER_OBJECT | T.ENEMY_OBJECT

jumpReleased = false

me.event.subscribe me.event.KEYUP, (action, keyCode) ->
    if keyCode == me.input.KEY.W or keyCode == me.input.KEY.UP
        jumpReleased = true

shouldReset = false
wrapped = me.game.update
me.game.update = (time) ->
    if shouldReset
        me.game.reset()
        me.audio.stopTrack()
        me.state.change(me.state.MENU)
        shouldReset = false
        return
    wrapped(time)

wouldCollide = (obj, dx, dy, filter = me.collision.types.ALL_OBJECT, dw = 0, dh = 0) ->
    {pos, width, height} = obj.getBounds()
    return testRect(pos.x + dx - dw / 2, pos.y + dy - dh / 2, width + dw, height + dh, filter, obj)

game.InvisibleBlock = me.Entity.extend {
    init: (x, y, width = 32, height = 32) ->
        settings = {
            width: width, height: height
            spritewidth: width, spriteheight: height
        }
        @_super(me.Entity, 'init', [x, y, settings])
        @body.collisionType = me.collision.types.WORLD_SHAPE
        @body.addShape(new me.Rect(0, 0, settings.width, settings.height))
        @body.setMaxVelocity(0,0)
    onCollision: (response, other) ->
        return false
}

game.BlockClearer = game.InvisibleBlock.extend {
    init: (player) ->
        [x,y] = [player.getRx(), player.getRy()]
        [w,h] = [96, 96]
        @_super(game.InvisibleBlock, 'init', [x - w/2, y - h/2, w, h])
        @body.collisionMask = me.collision.types.WORLD_SHAPE
        me.collision.check(@)
    onCollision: (response, other) ->
        if other instanceof game.PlayerBlock
            me.game.world.removeChild(other)
        return false
}

game.PlayerBlock = me.Entity.extend {
    init: (x, y) ->
        settings = {
            width: 32, height: 32
            spritewidth: 32, spriteheight: 40
            image: 'ciriblock'
        }
        @_super(me.Entity, 'init', [x, y, settings])
        @body.collisionType = me.collision.types.WORLD_SHAPE
        @body.addShape(new me.Rect(0, 0, settings.width, settings.height))
        # @topSprite = new me.Sprite(0, 0, me.loader.getImage('ciriblock_top'))
        @alwaysUpdate = true
        @renderable.translate(0,-4)
        @framesToLive = BLOCK_FRAMES_TO_LIVE
        @body.setMaxVelocity(0,0)
    update: (dt) ->
        {x, y} = @pos
        {pos} = @getBounds()
        if testRect(pos.x - 8, pos.y,48,32, me.collision.types.ENEMY_OBJECT, @)
            @framesToLive = 0
        if --@framesToLive < 0
            me.game.world.removeChild(@)
            return
        # Snap to grid if need be and can be:
        rX = 32*Math.round(x/32) ; rY = 32*Math.round(y/32)
        if rX != x or rY != y # Need be?
            if not testRect(pos.x+(rX-x), pos.y+(rY-y), 32, 32, me.collision.types.ALL_OBJECT, @) # Can be?
                @pos.x = rX; @pos.y = rY
                @updateBounds()

    draw: (renderer) ->
        [x, y] = [@getRx(), @getRy()]
        renderer.translate(x, y)
        @renderable.draw(renderer)
        renderer.translate(-x, -y)
    getRx: () ->
        {pos, width} = @getBounds()
        return Math.round(0.5 + pos.x + @anchorPoint.x * (width - @renderable.width))

    getRy: () ->
        {pos, height} = @getBounds()
        return Math.round(0.5 + pos.y + @anchorPoint.y * (height - @renderable.height))

    onCollision: (response, other) ->
        return false
}

game.ActorBase = me.Entity.extend {
    draw : (renderer) ->
        [x, y] = [@getRx(), @getRy()]
        renderer.translate(x, y)
        @renderable.draw(renderer)
        renderer.translate(-x, -y)
    baseInit: () ->
        @alwaysUpdate = true
        @body.setMaxVelocity(MAX_SPEED, 22)
        @onPlatform = null
    getRx: () ->
        {pos, width} = @getBounds()
        return Math.round(0.5 + pos.x + @anchorPoint.x * (width - @renderable.width))

    getRy: () ->
        {pos, height} = @getBounds()
        return Math.round(0.5 + pos.y + @anchorPoint.y * (height - @renderable.height))

    baseUpdate: (dt) ->
        # apply physics to the body (this moves the entity)
        if @onPlatform?
            b = @onPlatform.getBounds()
            b.pos.y -= 2
            if not @getBounds().overlaps(@onPlatform.getBounds())
                @onPlatform = null
            b.pos.y += 2
        if @onPlatform?
            @body.vel.x += @onPlatform.body.vel.x
        @body.update(dt)
        if @onPlatform?
            @body.vel.x -= @onPlatform.body.vel.x
        # handle collisions against other shapes
        me.collision.check(@)
        # return true if we moved or if the renderable was updated
        return @_super(me.Entity, 'update', [ dt ]) or @body.vel.x != 0 or @body.vel.y != 0
    baseOnCollision: (response, other, playSounds = false) ->
        if other instanceof game.MovingPlatform
            if response.overlapV.y > 0 and !@body.jumping
                @onPlatform = other
        if other instanceof game.SpringEntity
            if response.overlapV.y > 0 and !@body.jumping
                @body.falling = false
                @body.vel.y = -40
                # set the jumping flag
                @body.jumping = true; @body.falling = false
                if playSounds
                    me.audio.play 'jump'
                return false
}

game.PlayerEntity = game.ActorBase.extend {
    init: (x, y, settings) ->
        settings.spritewidth = 33 ; settings.spriteheight = 43
        settings.width = 30       ; settings.height = 30
        settings.z = 0
        me.game.player = @
        @collided = false
        @_super(me.Entity, 'init', [x, y, settings])
        @body.collisionType = me.collision.types.PLAYER_OBJECT
        # set the display to follow our position on both axis
        me.game.viewport.follow(@pos, me.game.viewport.AXIS.BOTH)
        me.game.viewport.setDeadzone(0, 100)
        # ensure the player is updated even when outside of the viewport
        @alwaysUpdate = true
        @renderable.translate(0,-7)
        @renderable.addAnimation('walk', [0,1,2,3])
        @renderable.addAnimation('stand', [0])
        @renderable.setCurrentAnimation('stand')
        @firstUpdate = true
        @baseInit()

    hasFloorBelow: () -> 
        if wouldCollide(@,0,0, me.collision.types.WORLD_SHAPE)
            return false
        return wouldCollide(@, 0, Math.max(1, @body.vel.y), me.collision.types.WORLD_SHAPE, -8)

    jump: () ->
        if @hasFloorBelow()
            charge_percent = Math.max(Math.abs(@body.vel.x) - MIN_SPEED, 0) / (MAX_SPEED - MIN_SPEED)
            # set current vel to the maximum defined value
            # gravity will then do the rest
            @body.vel.y = -(MIN_JUMP + (MAX_JUMP - MIN_JUMP) * charge_percent)
            # set the jumping flag
            @body.jumping = true
    tryMakeBlock: (dx) ->
        [x, y] = [@getRx(), @getRy()]
        x += dx
        block = new game.PlayerBlock(Math.round(x/32)*32, Math.round(y/32)*32)
        _bounds = block.getBounds()
        if not testRect(_bounds.pos.x, _bounds.pos.y, 32, 32, solidMask)
            me.game.world.addChild(block)
            return true
        block.pos.x = x; block.pos.y = y
        block.updateBounds()
        if not testRect(_bounds.pos.x, _bounds.pos.y, 32, 32, solidMask)
            me.game.world.addChild(block)
            return true
        return false
    update: (dt) ->
        if @pos.y > me.game.world.height + 32
            shouldReset = true
            return
        if @firstUpdate 
            @z = 1000000
            me.game.world.sort()
            @firstUpdate = false
        if me.input.isKeyPressed('block') and @hasFloorBelow()
            [x, y] = [@getRx(), @getRy()]
            y += 4
            dx = 32
            if @renderable.lastflipX 
                dx = -32
            @tryMakeBlock(2*dx) or @tryMakeBlock(dx)
        if me.input.isKeyPressed('clear')
            new game.BlockClearer(@) # Constructor handles everything necessary

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
        if me.input.isKeyPressed('down')
            @body.vel.x = 0

        # holdingJump = me.input.isKeyPressed('jump')
        # # Jump on every 'edge'
        if jumpReleased or me.input.isKeyPressed('jump') #holding_jump != holdingJump
            @jump()
        jumpReleased = false
        # holding_jump = holdingJump
        @baseUpdate(dt)

    onCollision: (response, other) ->
        @baseOnCollision(response, other, true)
        switch response.b.body.collisionType
            when me.collision.types.WORLD_SHAPE
                return true
            when me.collision.types.ENEMY_OBJECT
                if response.overlapV.y > 0 or (other.pos.y > @pos.y + 8)
                    other.die()
                    if !@body.jumping
                        # bounce (force jump)
                        @body.falling = false
                        @body.vel.y = -17
                        # set the jumping flag
                        @body.jumping = true
                        # play some audio
                        me.audio.play 'stomp'
                else
                    shouldReset = true # DED!
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

game.Coin = me.CollectableEntity.extend {
    init: (x, y, settings) ->
        # call the parent constructor
        @_super(me.CollectableEntity, 'init', [x, y, settings])
        @body.setCollisionMask(me.collision.types.PLAYER_OBJECT)
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
game.MovingPlatform = me.Entity.extend {
    init: (x, y, settings) ->
        settings.width = 85
        settings.height = 23
        settings.spritewidth = 101
        settings.spriteheight = 39
        settings.image = 'movingplatform'
        @_super(me.Entity, 'init', [x, y, settings])
        @alwaysUpdate = true
        @speed = settings.speed or 4
        @body.collisionType = me.collision.types.WORLD_SHAPE
        @body.shapes = []
        @body.addShape(new me.Rect(0, 0, settings.width, settings.height))
        @body.setMaxVelocity(@speed,0)
        @goLeft = (settings.facing == "left")
    update: (dt) ->
        if @body.vel.x == 0
            if Math.random() > .5 
                @body.vel.x = -@speed
            else
                @body.vel.x = @speed
        if wouldCollide(@, @body.vel.x, 0, solidMask)
            if not wouldCollide(@, -@body.vel.x, 0, solidMask)
                @body.vel.x *= -1
            else
                @body.vel.x = 0
        # check & update movement
        @body.update(dt)
        # handle collisions against other shapes
        me.collision.check(this)
        # return true if we moved or if the renderable was updated
        return @_super(me.Entity, 'update', [ dt ]) or @body.vel.x != 0 or @body.vel.y != 0
}

game.MonsterShooter = me.Entity.extend {
    getRx: () ->
        {pos, width} = @getBounds()
        return Math.round(0.5 + pos.x + @anchorPoint.x * (width - @renderable.width))
    getRy: () ->
        {pos, height} = @getBounds()
        return Math.round(0.5 + pos.y + @anchorPoint.y * (height - @renderable.height))
    init: (x, y, settings, image = 'monster_shooter') ->
        settings.width = 32
        settings.height = 32
        settings.spritewidth = 32
        settings.spriteheight = 32
        settings.image = image
        @facing = (settings.facing == 'left')
        @alwaysUpdate = true
        @_super(me.Entity, 'init', [x, y, settings])
        @body.collisionType = me.collision.types.WORLD_SHAPE
        @body.addShape(new me.Rect(0, 0, settings.width, settings.height))
        @body.setMaxVelocity(0,0)
        @timeTilSpawn = 25 + ~~(Math.random()*50)
        @nextKind = Math.min(3, ~~(Math.random() *4))
        @renderable.flipX(@facing)
    update: (dt) ->
        if @timeTilSpawn-- < 0
            [x, y] = [@getRx(), @getRy()]
            dx = (if @facing then -32 else 32)
            vx = dx / 32 * 4
            if wouldCollide(@, dx*1.25, 0, T.PLAYER_OBJECT, 16, 16)
                return
            if Math.random() < .1
                me.game.world.addChild(new game.PotFrog(x + dx, y, vx))
            else
                me.game.world.addChild(new game.OldCiriEnemy(x + dx, y, @nextKind, vx))
                @nextKind = (@nextKind + 1) % 4
            @timeTilSpawn = 25 + ~~(Math.random()*50)
}

game.BulletShooter = game.MonsterShooter.extend {
    init: (x, y, settings) ->
        @_super(game.MonsterShooter, 'init', [x, y, settings, 'bullet_shooter'])
    update: (dt) ->
        if @timeTilSpawn-- < 0
            [x, y] = [@getRx(), @getRy()]
            dx = (if @facing then -32 else 32)
            vx = dx / 32 * 4
            if wouldCollide(@, dx*1.25, 0, T.PLAYER_OBJECT, 16, 16)
                return
            me.game.world.addChild(new game.Bullet(x + dx, y, vx))
            @timeTilSpawn = 25 + ~~(Math.random()*50)
}

game.DeadMonster = me.Entity.extend {
    init: (x, y, settings) ->
        @_super(me.Entity, 'init', [x, y, settings])
        if settings.flipY != false
            @renderable.flipY(settings.flipY)
        @renderable.flipX(settings.flipX)
        @body.vel.y = 9
        @body.setCollisionMask(me.collision.types.NO_OBJECT)
        @renderable.addAnimation('stand', [settings.frame or 0])
        @renderable.setCurrentAnimation('stand')
        @alwaysUpdate = true
    update: (dt) ->
        @body.update(dt)
        if @pos.y > me.game.world.height + 100
            me.game.world.removeChild(@)
}

game.Animation = me.Entity.extend {
    init: (x, y, settings) ->
        @_super(me.Entity, 'init', [x, y, settings])
        @body.setMaxVelocity(0,0)
        @body.setCollisionMask(me.collision.types.NO_OBJECT)
        @alwaysUpdate = true
    update: (dt) ->
        @body.update(dt)
        if @renderable.current.frame.length-1 <= @renderable.getCurrentAnimationFrame()
            me.game.world.removeChild(@)
}

game.Monster = game.ActorBase.extend {
    die: () ->
        [x, y] = [@getRx(), @getRy()]
        @settings.flipX = @body.lastflipX
        mon = new game.DeadMonster(x, y, @settings)
        me.game.world.addChild(mon)
        @body.setCollisionMask(me.collision.types.NO_OBJECT)
        me.game.world.removeChild(@)
        return mon

    init: (x, y, settings) ->
        # call the parent constructor
        @_super(me.Entity, 'init', [x, y, settings])
        @walkLeft = false
        # walking & jumping speed
        @settings = settings
        @body.addShape(new me.Rect(0, 0, settings.width, settings.height))
        @body.collisionType = me.collision.types.ENEMY_OBJECT
        @baseInit()
    update: (dt) ->
        if @pos.y > me.game.world.height + 100
            me.game.world.removeChild(@)
            return
        if @body.vel.x == 0
            if Math.random() > .5 
                @body.vel.x = -@settings.speed
            else
                @body.vel.x = @settings.speed
        @renderable.flipX(@body.vel.x < 0)
        if wouldCollide(@, @body.vel.x, 0, me.collision.types.WORLD_SHAPE)
            if not wouldCollide(@, -@body.vel.x, 0, me.collision.types.WORLD_SHAPE)
                @body.vel.x *= -1
        @baseUpdate(dt)
    onCollision: (response, other) ->
        @baseOnCollision(response, other, false)
        if response.b.body.collisionType != me.collision.types.WORLD_SHAPE
            # res.y >0 means touched by something on the bottom
            # which mean at top position for this one
            # if @alive and response.overlapV.y > 0 and response.a.body.falling
            #     @renderable.flicker 750
            return false
        # Make all other objects solid
        return true
}

game.PotFrog = game.Monster.extend {
    init: (x, y, vx) ->
        settings = {
            image: 'potfrog'
            width: 30, height: 30
            speed: 6
            spritewidth: 32, spriteheight: 48
        }
        @_super(game.Monster, 'init', [x, y, settings])
        @renderable.translate(0, -8)
        @body.vel.x = vx
}

game.Chicken = game.Monster.extend {
    init: (x, y, vx) ->
        settings = {
            image: 'monsters'
            width: 30, height: 30
            frame: 1 # For dead monster
            spritewidth: 32, spriteheight: 32
        }
        @_super(game.Monster, 'init', [x, y, settings])
        @renderable.addAnimation('stand', [1])
        @renderable.setCurrentAnimation('stand')
        @body.vel.x = vx
}

game.OldCiriEnemy = game.Monster.extend {
    init: (x, y, n, vx) ->
        settings = {
            image: 'oldcirienemies'
            width: 32, height: 32
            frame: n # For dead monster
            speed: 3
            spritewidth: 32, spriteheight: 32
        }
        @_super(game.Monster, 'init', [x, y, settings])
        @renderable.addAnimation('stand', [n])
        @renderable.setCurrentAnimation('stand')
        @body.vel.x = vx
}

game.Bullet = game.Monster.extend {
    init: (x, y, vx) ->
        settings = {
            image: 'bullet'
            width: 30, height: 30
            frame: 0 # For dead monster
            speed: 3
            # flipY: false # For dead monster
            spritewidth: 32, spriteheight: 32
        }
        @_super(game.Monster, 'init', [x, y, settings])
        @renderable.addAnimation('fly', [0,1])
        @renderable.setCurrentAnimation('fly')
        @body.vel.x = vx * 2
        @renderable.flipX(@body.vel.x < 0)
        @body.setMaxVelocity(Math.abs(@body.vel.x), 0)
    update: (dt) ->
        if wouldCollide(@, @body.vel.x, 0, me.collision.types.WORLD_SHAPE)
            settings = {
                image: 'explosion'
                width: 32, height: 32
                spritewidth: 32, spriteheight: 32
            }
            anim = new game.Animation(@pos.x, @pos.y, settings)
            anim.renderable.addAnimation('stand', [0], 0)
            anim.renderable.setCurrentAnimation('stand')
            me.game.world.addChild(anim)
            me.game.world.removeChild(@)
        # check & update movement
        @body.update(dt)
        # handle collisions against other shapes
        me.collision.check(this)
        # return true if we moved or if the renderable was updated
        return @_super(me.Entity, 'update', [ dt ]) or @body.vel.x != 0 or @body.vel.y != 0
}
portalObjects = {}
justChanged = false
game.Portal = me.Entity.extend {
    init: (x, y, settings) ->
        @_super(me.Entity, 'init', [x, y, settings])
        portalObjects[settings.id] = @
        @next_id = settings.next_id or null
        @next_level = settings.next_level or null
        @body.collisionType = me.collision.types.COLLECTABLE_OBJECT
        @body.setCollisionMask(me.collision.types.NO_OBJECT)
    update: (dt) ->
        if me.input.isKeyPressed('down') 

            if not justChanged and wouldCollide(@, 0, 0, me.collision.types.PLAYER_OBJECT)
                if @next_id == null
                    window.CURRENT_LEVEL = @next_level
                    shouldReset = true
                    return
                p = me.game.player
                next = portalObjects[@next_id]
                bounds = next.getBounds()
                centerx = bounds.left/2 + bounds.right/2
                {pos} = p
                if not testRect(centerx - 32, bounds.bottom - 64, 64, 64, me.collision.types.ENEMY_OBJECT)                    
                    pos.x = centerx - 16
                    pos.y = bounds.bottom - 32
                    p.updateBounds()
                    justChanged = true
        else
            justChanged = false
}

###*
# Spring Entity
###

game.SpringEntity = me.Entity.extend {
    init: (x, y, settings) ->
        # define this here instead of tiled
        settings.image = 'bounce_spring'
        # save the area size defined in Tiled
        width = settings.width
        height = settings.height
        # adjust the size setting information to match the sprite size
        # so that the entity object is created with the right size
        settings.spritewidth = settings.width = 32
        settings.spriteheight = settings.height = 32
        # call the parent constructor
        @_super(me.Entity, 'init', [x, y, settings])
        @body.collisionType = me.collision.types.COLLECTABLE_OBJECT
        # set start/end position based on the initial area size
        x = @pos.x
        @startX = x
        @endX = x + width - settings.spritewidth
        @pos.x = x + width - settings.spritewidth
}
