game.resources = []

defineLevels = (names) ->
    i = 0
    while i < names.length
        game.resources.push {
            name: names[i]
            type: 'tmx'
            src: 'src/levels/' + names[i] + '.tmx'
        }
        i++

defineImages = (names) ->
    i = 0
    while i < names.length
        game.resources.push {
            name: names[i]
            type: 'image'
            src: 'src/sprites/' + names[i] + '.png'
        }
        i++

defineSounds = (names) ->
    i = 0
    while i < names.length
        game.resources.push {
            name: names[i]
            type: 'audio'
            src: 'src/sounds/'
        }
        i++

defineImages [
    "32x32_font"
    "32x32_font_white"
    "area01_bkg0"
    "area01_bkg1"
    "area01_level_tiles"
    "bounce_spring"
    "bottomless_warning"
    "bullet"
    "bullet_explosion"
    "bullet_shooter"
    "ciriblock"
    "ciribot"
    'ciribot_health'
    "ciribot_tiles"
    "explosion"
    "normal_block" 
    "mario_tiles"
    "monster_shooter"
    "monsters"
    "movingplatform"
    "oldciricaveblock"
    "oldcirienemies"
    "oldciribot"
    "potfrog"
    "spinning_coin_gold"
    "title_screen"
]
defineLevels [
    'area01'
    'area02'
]
defineSounds [
    'ciribot_theme'
    'cling'
    'stomp'
    'jump'
]
