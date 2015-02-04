### Game namespace ###
window.game = {
    data: {
        score: 0
    }
    onload: () ->
        # Initialize the video.
        me.sys.fps = 30;
        if !me.video.init('screen', me.video.CANVAS, 640, 360, true, 2)
            alert 'Your browser does not support HTML5 canvas.'
        # add "#debug" to the URL to enable the debug Panel
        if document.location.hash == '#debug'
            window.onReady () ->
                me.plugin.register.defer(this, me.debug.Panel, 'debug', me.input.KEY.V)
        # Initialize the audio.
        me.audio.init('mp3,ogg')
        # Set a callback to run when loading is complete.
        me.loader.onload = @loaded.bind(this)
        # Load the resources.
        me.loader.preload(game.resources)
        # Initialize melonJS and display a loading screen.
        me.state.change(me.state.LOADING)
    loaded: () ->
        me.state.set(me.state.MENU, new game.TitleScreen())
        me.state.set(me.state.PLAY, new game.PlayScreen())
        # add our player entity in the entity pool
        me.pool.register('mainPlayer', game.PlayerEntity)
        me.pool.register('CoinEntity', game.CoinEntity)
        me.pool.register('EnemyEntity', game.EnemyEntity)
        # enable the keyboard
        me.input.bindKey(me.input.KEY.LEFT, 'left')
        me.input.bindKey(me.input.KEY.RIGHT, 'right')
        me.input.bindKey(me.input.KEY.A, 'left')
        me.input.bindKey(me.input.KEY.D, 'right')
        me.input.bindKey(me.input.KEY.UP, 'jump', true)
        me.input.bindKey(me.input.KEY.W, 'jump', true)
        me.input.bindKey(me.input.KEY.CTRL, 'block', true)
        me.input.bindKey(me.input.KEY.SPACE, 'block', true)
        # Start the game.
        me.state.change(me.state.MENU)
}

