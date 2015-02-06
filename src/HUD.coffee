###*
# a HUD container and child items
###

game.HUD = game.HUD or {}
game.HUD.Container = me.Container.extend(init: ->
    # call the constructor
    @_super me.Container, 'init'
    # persistent across level change
    @isPersistent = true
    # make sure we use screen coordinates
    @floating = true
    # make sure our object is always draw first
    @z = Infinity
    # give a name
    @name = 'HUD'
    @addChild new game.HUD.ScoreItem(0, 0)
    return
)

###* 
# a basic HUD item to display score
###

game.HUD.ScoreItem = me.Renderable.extend(
    init: (x, y) ->
        # call the parent constructor 
        # (size does not matter here)
        @_super(me.Renderable, 'init', [x,y,640,480])
        # create a font
        @font = new (me.BitmapFont)('32x32_font', 32)
        @font.set('right')
    update: () ->
        return true
    draw: (renderer) ->
        {x, y} = @pos
        @font.draw(renderer, "Health", x + 49, y + 99)
        player = me.game.player
        X = x+60 ; Y = y+20
        W = 500 ; H = 20
        _alpha = renderer.globalAlpha()
        renderer.setColor('black')
        renderer.fillRect(X-1, Y-1, W+2, H + 2)
        renderer.setColor('red')
        renderer.fillRect(X,Y, W, H )
        renderer.setColor('#346524');
        if @health < 50 then renderer.setColor('yellow')
        # if @health < 50 then renderer.setColor('red');
        # get viewport position
        renderer.fillRect(X,Y, W * player.health/100, H);
        renderer.setGlobalAlpha(_alpha)
)
