###
This is a wrapper class that handles adding a canvas entity to the DOM as well
as ensuring that everything draws to that canvas. This abstracts the need to 
handle contexts with other objects as well as covering prerendering.
###
class window.WrapCanvas
	constructor: ->
		@zoom = 1
		@width = g.width
		@height = g.height
		@canvas = document.createElement 'canvas'
		@canvas.width = @width
		@canvas.height = @height
		@context = @canvas.getContext '2d'
	
	clear: ->
		@context.clearRect 0, 0, @width, @height
	
	update: ->
		@canvas.width = @width
		@canvas.height = @height
	
	draw: ->

class window.DrawCanvas extends WrapCanvas
	constructor: ->
		super
		@context.strokeStyle = '#000000'

	#this function takes the prerendered canvas that has been rendered and draws
	#it to the canvas that is actually on the DOM
	draw: (rCanvas) ->
		rCanvas.drawCanvas @canvas

	#DO NOT USE. This is super depricated and will not work
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

###
	This classes is specifically designed to take input canvases and draw them
	to the screen. This lets me easily layer canavs, change the order of the
	layering, and rotate the layered canvases.
###
class window.RenderCanvas extends WrapCanvas
	constructor: ->
		super
		@renderCanvas = document.createElement 'canvas'
		@renderCanvas.width = g.width
		@renderCanvas.height = g.height
		@renderContext = @renderCanvas.getContext '2d'
		$('#twinbeat').append @renderCanvas
	
	update: ->
		#don't think you really need anything here, or even need this method

	clear: ->
		@context.clearRect 0, 0, g.width, g.height
		@renderContext.clearRect 0, 0, g.width, g.height

	draw: ->
		@renderContext.drawImage @canvas, 0, 0, g.width, g.height
	
	drawCanvas: (canvas) ->
		@context.drawImage canvas, 0, 0, canvas.width, canvas.height
