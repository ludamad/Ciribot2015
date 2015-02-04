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
    # add our child score object at the right-bottom position
    @addChild new (game.HUD.ScoreItem)(630, 440)
    return
)

###* 
# a basic HUD item to display score
###

game.HUD.ScoreItem = me.Renderable.extend(
    init: (x, y) ->
        # call the parent constructor 
        # (size does not matter here)
        @_super me.Renderable, 'init', [
            x
            y
            10
            10
        ]
        # create a font
        @font = new (me.BitmapFont)('32x32_font', 32)
        @font.set 'right'
        # local copy of the global score
        @score = -1
        return
    update: ->
        # we don't do anything fancy here, so just
        # return true if the score has been updated
        if @score != game.data.score
            @score = game.data.score
            return true
        false
    draw: (renderer) ->
        @font.draw renderer, game.data.score, @pos.x, @pos.y
        return
)
