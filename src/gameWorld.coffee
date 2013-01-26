class window.GameWorld
	constructor: () ->
		@level1 = new GameLevel(false)

	update: ->
		@level1.update()

	draw: ->
		g.canvas.clear()
		@level1.draw()
		g.canvas.draw()
