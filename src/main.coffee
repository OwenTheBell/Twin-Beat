#because fuck not having a contains method
Array.prototype.contains = (value) ->
  return true if @indexOf(value) > -1
  return false

###
setInterval ->
  $('#fps').html g.output
, 1000
###
$ ->
    init()

init = ->
    g.input = new InputHandler()
    g.div = document.getElementById 'peg'
    g.width = $('#peg').width()
    g.height = $('#peg').height()
    g.top = $('#peg').top
    g.left = $('#peg').left
    g.fps = 0
    g.now = Date.now()
    g.lastFrame = g.now
    g.sixty = Date.now()
    g.output = 0
    g.frameCount = 0
    g.gameWorld = new GameWorld()
    g.cachedSprites = []

#create a whole bunch of canvas so that we can do layered rendering
    i = 0
    while i < g.layers
        g.canvases.push new Canvas g.layers - i
        i++
    g.initPhysics()
    #this is here to for caching the sprites for all entities that require them
    preloader g.cachedSprites

#this function ensures that execution does not continue until all images
#have been cached in memory in the client's browser
preloader = (sprites) ->
    cache = new Image
    cache.src = sprites[0].src
    cache.onload = ->
        sprites[0].setup()
        if sprites.length > 1
            preloader(sprites.splice 1)
        else
            gameLoop()

#binding is required for this function so it can call other functions
gameLoop = ->
    g.now = Date.now()
    g.elapsed = (g.now - g.lastFrame) / 1000
    g.lastFrame = g.now
#sometimes requestAnimationFrame runs at greater than 60Hz so ensure that
#framerate remains capped at 1/60
    g.elapsed = 1/60 if g.elapsed < 1/60
    if g.frameCount < 60
        g.frameCount++
    else
        g.frameCount = 0
        temp = Date.now()
        g.output = temp - g.sixty
        g.sixty = temp
    run()
    requestAnimationFrame(gameLoop)

run = ->
    g.input.update()
    g.gameWorld.update()
    g.gameWorld.draw()
