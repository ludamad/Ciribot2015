game.TitleScreen = me.ScreenObject.extend(
    onResetEvent: ->
        # title screen
        me.game.world.addChild new (me.Sprite)(0, 0, me.loader.getImage('title_screen')), 1
        # change to play state on press Enter or click/tap
        me.input.bindKey me.input.KEY.ENTER, 'enter', true
        me.input.bindPointer me.input.mouse.LEFT, me.input.KEY.ENTER
        @handler = me.event.subscribe(me.event.KEYDOWN, (action, keyCode, edge) ->
            if action == 'enter'
                # play something on tap / enter
                # this will unlock audio on mobile devices
                me.audio.play 'cling'
                me.state.change me.state.PLAY
        )
    onDestroyEvent: ->
        me.input.unbindKey me.input.KEY.ENTER
        me.input.unbindPointer me.input.mouse.LEFT
        me.event.unsubscribe @handler
)
