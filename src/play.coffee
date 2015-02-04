game.PlayScreen = me.ScreenObject.extend {
    onResetEvent: ->
        # play the audio track
        #me.audio.playTrack 'ciribot_theme'
        # load a level
        me.levelDirector.loadLevel 'area01'
        # reset the score
        game.data.score = 0
        # add our HUD to the game world
        @HUD = new (game.HUD.Container)
        me.game.world.addChild(@HUD)
        return
    onDestroyEvent: ->
        # remove the HUD from the game world
        me.game.world.removeChild(@HUD)
}
