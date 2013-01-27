window.g =
    input: {}
    canvases: []
    layers: 1
    SCALE: 30
    #everything below here is set at run time
    now: null
    lastFrame: null
    div: null
    top: null
    left: null
    height: null
    world: null
    worker: null

#because fuck not having a contains method
Array.prototype.contains = (value) ->
  return true if @indexOf(value) > -1
  return false

Array.prototype.remove = (value) ->
	index = @indexOf value
	if index > -1
		@splice index, 1
		return true
	return false

Array.prototype.last = ->
	@[@length - 1]

Array.prototype.removeIndex = (index) ->
	@splice index, 1

window.requestAnimationFrame or=
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.oRequestAnimationFrame or
    window.msRequestAnimationFrame or
    (callback, element) ->
        window.setTimeout( ->
            callback new Date()
        , 1000 / 60)
###
setInterval ->
  $('#fps').html g.output
, 1000
###
$ ->
    init()

init = ->
	g.input = new InputHandler()
	g.div = document.getElementById 'twinbeat'
	g.width = $('#twinbeat').width()
	g.height = $('#twinbeat').height()
	g.top = $('#twinbeat').top
	g.left = $('#twinbeat').left
	g.gravity = .1
	g.lateral = 3 #per frame lateral move, needs to change
	g.entityDim = 30
	g.swap = 1000 #time to swap levels
	g.reverse = 500
	g.challenge = 25000
	g.challengeRot = 2 #number of full rotations in challenge mode
	g.fps = 0
	g.now = Date.now()
	g.lastFrame = g.now
	g.elapsed = 0
	g.sixty = Date.now()
	g.output = 0
	g.frameCount = 0
	g.gameWorld = new GameWorld()
	g.cachedSprites = []
	gameLoop()

#binding is required for this function so it can call other functions
gameLoop = ->
	g.now = Date.now()
	g.elapsed = g.now - g.lastFrame
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
	if g.gameWorld.reset
		delete g.gameWorld
		$('#twinbeat').html ''
		$('#uprTxt').html ''
		$('#lwrTxt').html ''
		g.gameWorld = new GameWorld()
	g.gameWorld.update()
	g.gameWorld.draw()
