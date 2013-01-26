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
	g.div = document.getElementById 'twinbeat'
	g.width = $('#twinbeat').width()
	g.height = $('#twinbeat').height()
	g.top = $('#twinbeat').top
	g.left = $('#twinbeat').left
	g.gravity = .1
	g.lateral = 2
	g.entityDim = 30
	g.fps = 0
	g.now = Date.now()
	g.lastFrame = g.now
	g.sixty = Date.now()
	g.output = 0
	g.frameCount = 0
	g.gameWorld = new GameWorld()
	g.cachedSprites = []
	#g.canvas = new Canvas()
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
