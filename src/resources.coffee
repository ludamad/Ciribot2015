game.resources = []

defineLevels = (names) ->
    i = 0
    while i < names.length
        game.resources.push
            name: names[i]
            type: 'tmx'
            src: 'src/levels/' + names[i] + '.tmx'
        i++

defineImages = (names) ->
    i = 0
    while i < names.length
        game.resources.push
            name: names[i]
            type: 'image'
            src: 'src/sprites/' + names[i] + '.png'
        i++

defineSounds = (names) ->
    i = 0
    while i < names.length
        game.resources.push
            name: names[i]
            type: 'audio'
            src: 'src/sounds/'
        i++

defineImages [
    'gripe_run_right'
    'spinning_coin_gold'
    'wheelie_right'
    '32x32_font'
    'title_screen'
    'area01_bkg0'
    'area01_bkg1'
    'area01_level_tiles'
    'mario_tiles'
    'monsters'
]
defineLevels [
    'area01'
    'area02'
]
defineSounds [
    'dst-inertexponent'
    'cling'
    'stomp'
    'jump'
]
