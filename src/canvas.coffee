###
This is a wrapper class that handles adding a canvas entity to the DOM as well
as ensuring that everything draws to that canvas. This abstracts the need to 
handle contexts with other objects as well as covering prerendering.
###
class window.Canvas
	constructor: ->
		#this variable will control level of zoom eventually
		@zoom = 1
		@width = g.width
		@height = g.height
		#this canvas is for prerendering and has all objects drawn to it
		@canvas = document.createElement 'canvas'
		@canvas.width = @width * @zoom
		@canvas.height = @height * @zoom
		#this canvas is what is actually displayed by the game. Once @canvas has
		#finished rendering, it is then drawn to this canvas and actually displayed
		@renderCanvas = document.createElement 'canvas'
		@renderCanvas.width = @width
		@renderCanvas.height = @height
		@renderCanvas.setAttribute 'id', "canvas#{@layer}"
		@context = @canvas.getContext '2d'
		@renderContext = @renderCanvas.getContext '2d'

		@context.strokeStyle = '#000000'

		#add the canvas that we have created to our page
		$('#twinbeat').append @renderCanvas

	update: ->

#this function takes the prerendered canvas that has been rendered and draws
#it to the canvas that is actually on the DOM
	draw: ->
		@renderContext.drawImage @canvas, 0, 0, @width, @height

	clear: ->
		@context.clearRect 0, 0, @width * @zoom, @height * @zoom
		@renderContext.clearRect 0, 0, @width, @height

	drawText: (entity) ->
		x = Math.round (entity.x - g.gameWorld.activeLevel.worldPos.x) * g.SCALE
		y = Math.round (entity.y - g.gameWorld.activeLevel.worldPos.y) * g.SCALE
		@context.font = entity.fontSize + ' ' + entity.font
		@context.fillStyle = entity.color
		@context.fillText entity.text, x, y

#this draws a string to a specfic set of pixel coordinates on the canvas
#it does not change position with the player
	hardTextDraw: (text, left, top, font, fontSize, color) ->
		@context.font =  fontSize + ' ' + font
		@context.fillStyle = color
		@context.fillText text, left, top

#this always draws off the top left corner as all entities have that value
	drawFill: (entity) ->
		x = Math.floor entity.x
		y = Math.floor entity.y
		@context.save()
		@context.fillStyle = entity.color
		@context.fillRect x, y, entity.width, entity.height
		@context.restore()
	
	drawFillBorder: (entity) ->
		@drawFill entity
		x = entity.x
		y = entity.y
		@context.strokeRect x, y, entity.width, entity.height
