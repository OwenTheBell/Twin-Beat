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

#if console is not supported (ie. IE not in debug mode) then set the console
#to an empty object to make sure that the code doesn't crash
###
try
	console
catch e
	console = {}
	console.log = ->
###

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
	g.width = g.div.clientWidth
	g.height = g.div.clientHeight
	g.top = g.div.offsetTop
	g.left = g.div.offsetLeft
	#g.gravity = .18
	g.gravity = 10.8
	g.lateral = 4 #per frame lateral move, needs to change
	g.entityDim = 30
	g.swap = 200 #time to swap levels
	g.reverse = 200
	g.challenge = 25000
	g.challengePrep = 3000
	g.challengeRot = 2 #number of full rotations in challenge mode
	g.fps = 0
	g.now = Date.now()
	g.start = Date.now()
	g.end = 0
	g.lastFrame = g.now
	g.elapsed = 0
	g.sixty = Date.now()
	g.output = 0
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
	#g.elapsed = 1/60 if g.elapsed < 1/60
	run()
	requestAnimationFrame(gameLoop)

run = ->
	g.sFrac = g.elapsed / 1000 #fraction of a second covered by last frame
	if g.gameWorld.reset
		delete g.gameWorld
		$('#twinbeat').html ''
		$('#uprTxt').html ''
		$('#midTxt').html ''
		$('#lwrTxt').html ''
		g.gameWorld = new GameWorld()
		g.gameWorld.startGame = false
		g.gameWorld.start = g.now
		g.gameWorld.themeMusic.play()
	g.gameWorld.update()
	g.gameWorld.draw()
