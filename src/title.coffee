game.TitleScreen = me.ScreenObject.extend(
    onResetEvent: ->
        # title screen
        # change to play state on press Enter or click/tap
        me.input.bindKey(me.input.KEY.ENTER, 'enter', true)
        me.input.bindPointer(me.input.mouse.LEFT, me.input.KEY.ENTER)
        me.audio.play('cling')
        me.state.change(me.state.PLAY)
    onDestroyEvent: ->
        me.input.unbindKey me.input.KEY.ENTER
        me.input.unbindPointer me.input.mouse.LEFT
)
