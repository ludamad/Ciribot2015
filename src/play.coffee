window.CURRENT_LEVEL = 'area01'
game.PlayScreen = me.ScreenObject.extend {
    onResetEvent: ->
        # play the audio track
        #me.audio.playTrack 'ciribot_theme'
        # load a level
        me.levelDirector.loadLevel window.CURRENT_LEVEL
        chainX = 0 ; chainY = 0
        chainLen = 0
        chainOff = null
        flushChainObj = () ->
            if chainLen > 0
                me.game.world.addChild new game.InvisibleBlock(chainOff.x + chainX*32, chainOff.y + chainY*32, 32, 32*chainLen)
            chainX = 0 ; chainY = 0
            chainLen = 0
        for layer in me.game.currentLevel.getLayers()
            if layer instanceof me.TMXLayer
                if layer.name.indexOf("solid") != 0
                    continue
                x = 0
                for row in layer.layerData
                    chainObj = null
                    y = 0
                    for tile in row 
                        if tile
                            if chainLen == 0
                                chainX = x; chainY = y
                                chainOff = tile.tileset.tileoffset
                            chainLen++
                        else 
                            flushChainObj()
                        y++
                    flushChainObj()
                    x++
        # reset the score
        game.data.score = 0
        # add our HUD to the game world
        @HUD = new game.HUD.Container()
        {width, height} = me.game.world
        me.game.world.addChild(@HUD)
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
