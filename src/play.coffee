window.CURRENT_LEVEL = 'area01'
game.PlayScreen = me.ScreenObject.extend {
    onResetEvent: ->
        # play the audio track
        #me.audio.playTrack 'ciribot_theme'
        # load a level
        me.levelDirector.loadLevel window.CURRENT_LEVEL
        for layer in me.game.currentLevel.getLayers()
            if layer instanceof me.TMXLayer
                if layer.name.indexOf("solid") != 0
                    continue
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
        {width, height} = me.game.world
        # Add the 'invisible walls'
        # Left wall
        me.game.world.addChild(new game.InvisibleBlock(-width, 0, width, height))
        # Top wall
        me.game.world.addChild(new game.InvisibleBlock(0, -height, width, height))
        # Right wall
        me.game.world.addChild(new game.InvisibleBlock(width, 0, width, height))
    onDestroyEvent: ->
        # remove the HUD from the game world
        me.game.world.removeChild(@HUD)
}
