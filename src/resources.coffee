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
    "32x32_font"
    "area01_bkg0"
    "area01_bkg1"
    "area01_level_tiles"
    "bounce_spring"
    "bullet"
    "bullet_shooter"
    "ciriblock"
    "ciribot"
    "ciribot_tiles"
    "mario_tiles"
    "monster_shooter"
    "monsters"
    "oldciricaveblock"
    "oldcirienemies"
    "potfrog"
    "spinning_coin_gold"
    "title_screen"
]
defineLevels [
    'area01'
]
defineSounds [
    #    'ciribot_theme'
    'cling'
    'stomp'
    'jump'
]
