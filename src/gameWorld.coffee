class window.GameWorld
	constructor: () ->
		@level1 = new GameLevel(true)
		@canvas = new RenderCanvas()

	update: ->
		@level1.update()

	draw: ->
		@canvas.clear()
		@level1.draw @canvas
		@canvas.draw()
