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
        @ciriSprite = new me.Sprite(0, 0, me.loader.getImage('ciribot'), 32, 48)
        # @ciriSprite.setCurrentAnimation("stand")
    update: () ->
        return true
    draw: (renderer) ->
        {x, y} = @pos
        {health} = me.game.player
        X = x+60 ; Y = y+320
        W = 25*5 ; H = 32
        renderer.setColor('white')
        # _alpha = renderer.globalAlpha()
        renderer.setColor('black')
        # renderer.strokeRect(X-1, Y-1, W+2, H + 2)
        # renderer.setColor('white')
        # renderer.strokeRect(X+5, Y+2, W, H)
        # renderer.setColor('red')
        # renderer.fillRect(X,Y, W, H )
        # renderer.setColor('#346524');
        # if @health < 50 then renderer.setColor('yellow')
        # # if @health < 50 then renderer.setColor('red');
        # # get viewport position
        # renderer.fillRect(X,Y, W * player.health/100, H);
        # renderer.setGlobalAlpha(_alpha)

        _alpha = renderer.globalAlpha()
        renderer.setGlobalAlpha(0.7)
        Y -= 260
        @font.draw(renderer, "GOLD #{game.data.coins}", X+150, Y-100+96)
        i = 0
        @fontW.draw(renderer, "#{health}%", X+120, Y-40)

        # while (i+1) * 20 <= health
        renderer.setGlobalAlpha(health/100)
        renderer.translate(X - 40, Y - 50)
        @ciriSprite.draw(renderer)
        renderer.translate(-X + 40, -Y + 50)

        renderer.setGlobalAlpha(0.7)
        time = Math.floor(game.data.steps / 30) # fps == 30
        minutes = Math.floor(time / 60)
        seconds = time - minutes * 60
        if seconds < 10
            seconds = "0" + seconds
        @fontW.draw(renderer, "TIME #{minutes}:#{seconds}", X+550, y+15)
        #     i++
        renderer.setGlobalAlpha(_alpha)
)
