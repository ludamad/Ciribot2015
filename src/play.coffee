game.PlayScreen = me.ScreenObject.extend {
    onResetEvent: ->
        # play the audio track
        #me.audio.playTrack 'ciribot_theme'
        # load a level
        me.levelDirector.loadLevel 'area01'
        for layer in me.game.currentLevel.getLayers()
            if layer instanceof me.TMXLayer
                x = 0
                for row in layer.layerData
                    y = 0
                    for tile in row 
                        if tile
                            toff = tile.tileset.tileoffset
                            me.game.world.addChild(new game.InvisibleBlock(toff.x + x*32, toff.y + y*32))
                        y++
                    x++
        # reset the score
        game.data.score = 0
        # add our HUD to the game world
        @HUD = new (game.HUD.Container)
        me.game.world.addChild(@HUD)
    onDestroyEvent: ->
        # remove the HUD from the game world
        me.game.world.removeChild(@HUD)
}
