poly = new me.Polygon(0,0,[
    new me.Vector2d(0,0), new me.Vector2d(0, 0),
    new me.Vector2d(0,0), new me.Vector2d(0, 0)
])
getPoly = (x, y, w, h) ->
    poly.points[1].x = w
    poly.points[2].x = w
    poly.points[2].y = h
    poly.points[3].y = h
    poly.setShape(x, y, poly.points)
    return poly

nullObserver = new me.Polygon(0,0,[
    new me.Vector2d(0,0), new me.Vector2d(0, 0),
    new me.Vector2d(0,0), new me.Vector2d(0, 0)
])

testObject = (poly, obj, filter) ->
    if not obj.body?
        return false
    if (filter & obj.body.collisionType) == 0 or not poly.getBounds().overlaps(obj.getBounds())
        return false
    for shape in obj.body.shapes
        if me.collision.testPolygonPolygon(nullObserver, poly, obj, shape, me.collision.response.clear())
            return true
    return false

window.testRect = (x, y, w, h, filter = me.collision.types.ALL_OBJECT, objFilter = null) ->
    # retreive a list of potential colliding objects
    poly = getPoly(x,y,w,h)
    for obj in me.collision.quadTree.retrieve(poly)
        passes = (obj != objFilter)
        if typeof objFilter == "function"
            passes = objFilter(obj)
        if passes and testObject(poly, obj, filter)
            return true
    return false
 
# ---
# generated by js2coffee 2.0.0
### Game namespace ###
window.game = {
    data: {
        score: 0
        steps: 0
    }
    onload: () ->
        # Initialize the video.
        me.sys.fps = 30;
        if !me.video.init('screen', me.video.CANVAS, 640, 360, true, 2)
            alert 'Your browser does not support HTML5 canvas.'
        # add "#debug" to the URL to enable the debug Panel
        if document.location.hash == '#debug'
            window.onReady () ->
                me.plugin.register.defer(this, me.debug.Panel, 'debug', me.input.KEY.V)
        # Initialize the audio.
        me.audio.init('mp3,ogg')
        # Set a callback to run when loading is complete.
        me.loader.onload = @loaded.bind(this)
        # Load the resources.
        me.loader.preload(game.resources)
        # Initialize melonJS and display a loading screen.
        me.state.change(me.state.LOADING)
    loaded: () ->
        me.state.set(me.state.MENU, new game.TitleScreen())
        me.state.set(me.state.PLAY, new game.PlayScreen())
        # add our entity classes in the entity pool
        me.pool.register('mainPlayer', game.PlayerEntity)
        me.pool.register('Coin', game.Coin)
        me.pool.register('MonsterShooter', game.MonsterShooter)
        me.pool.register('BulletShooter', game.BulletShooter)
        me.pool.register('Portal', game.Portal)
        me.pool.register('SpringEntity', game.SpringEntity)
        me.pool.register('HealthPowerup', game.HealthPowerup)
        me.pool.register('MovingPlatform', game.MovingPlatform)
        me.pool.register('PotFrog', game.PotFrog)
        me.pool.register('Chicken', game.Chicken)
        me.pool.register('OldCiriEnemy', game.OldCiriEnemy)
        me.pool.register('Bullet', game.Bullet)
        me.pool.register('BlockClearer', game.BlockClearer)
        me.pool.register('PlayerBlock', game.PlayerBlock)
        me.pool.register('DeadMonster', game.DeadMonster)
        me.pool.register('Animation', game.Animation)

        # Keyboard bindings:
        me.input.bindKey(me.input.KEY.LEFT, 'left')
        me.input.bindKey(me.input.KEY.RIGHT, 'right')
        me.input.bindKey(me.input.KEY.A, 'left')
        me.input.bindKey(me.input.KEY.D, 'right')
        me.input.bindKey(me.input.KEY.ESC, 'restart', true)
        me.input.bindKey(me.input.KEY.DOWN, 'down')
        me.input.bindKey(me.input.KEY.S, 'down')
        me.input.bindKey(me.input.KEY.UP, 'jump', true)
        me.input.bindKey(me.input.KEY.W, 'jump', true)
        me.input.bindKey(me.input.KEY.F, 'block', true)
        me.input.bindKey(me.input.KEY.V, 'block2', true)
        me.input.bindKey(me.input.KEY.CTRL, 'block', true)
        me.input.bindKey(me.input.KEY.SPACE, 'block', true)
        me.input.bindKey(me.input.KEY.SHIFT, 'modkey')
        me.input.bindKey(me.input.KEY.C, 'clear', true)
        # Start the game.
        me.state.change(me.state.MENU)
}

