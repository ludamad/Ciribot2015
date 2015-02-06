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
        @ciriSprite = new me.Sprite(0, 0, me.loader.getImage('oldciribot'))
    update: () ->
        return true
    draw: (renderer) ->
        {x, y} = @pos
        {health} = me.game.player
        X = x+60 ; Y = y+320
        W = 25*5 ; H = 32
        renderer.setColor('white')
        @font.draw(renderer, game.data.coins, X+500, Y)
        # _alpha = renderer.globalAlpha()
        renderer.setColor('black')
        # renderer.strokeRect(X-1, Y-1, W+2, H + 2)
        # renderer.setColor('white')
        renderer.strokeRect(X+5, Y+2, W, H)
        # renderer.setColor('red')
        # renderer.fillRect(X,Y, W, H )
        # renderer.setColor('#346524');
        # if @health < 50 then renderer.setColor('yellow')
        # # if @health < 50 then renderer.setColor('red');
        # # get viewport position
        # renderer.fillRect(X,Y, W * player.health/100, H);
        # renderer.setGlobalAlpha(_alpha)
        i = 0
        while (i+1) * 20 <= health
            renderer.translate(X + i * 25, Y)
            @ciriSprite.draw(renderer)
            renderer.translate(-X - i * 25, -Y)
            i++
)
