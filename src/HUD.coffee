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
        @font = new me.BitmapFont('32x32_font', 32)
        @font.set('right')
        @fontW = new me.BitmapFont('32x32_font_white', 32)
        @fontW.set('right')
        @ciriSprite = new me.Sprite(0, 0, me.loader.getImage('ciribot'), 32, 43)
    update: () ->
        return true
    draw: (renderer) ->
        {x, y} = @pos
        {health} = me.game.player
        X = x+60 ; Y = y+60
        W = 25*5 ; H = 32
        renderer.setColor('white')
        renderer.setColor('black')
        _alpha = renderer.globalAlpha()

        renderer.setGlobalAlpha(0.7)
        @font.draw(renderer, "GOLD #{game.data.coins}", X+200, Y-100+96)
        @fontW.draw(renderer, "#{health}%", X+120, Y-40)

        renderer.setGlobalAlpha(health/100)
        renderer.translate(X - 40, Y - 50)
        @ciriSprite.draw(renderer)
        renderer.translate(-X + 40, -Y + 50)

        renderer.setGlobalAlpha(0.7)
        time = Math.floor(game.data.steps / 30) # fps == 30
        minutes = Math.floor(time / 60)
        seconds = time - minutes * 60
        if seconds < 10 then seconds = "0" + seconds
        @fontW.draw(renderer, "TIME #{minutes}:#{seconds}", X+550, y+15)
        
        renderer.setGlobalAlpha(_alpha)
)
