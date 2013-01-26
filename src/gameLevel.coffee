class window.GameLevel
	@entities = []

	#vert_hori: defines whether level or vertical or horizontal scroll
	constructor: (@hori_vert) ->
		@canvas = new DrawCanvas()
		@entities = []
		@hori_vert = hori_vert
		#this is not set to adjust for zoom level, this needs to be changed
		@windowDimensions =
			width: g.width / g.SCALE * 2
			height: g.height / g.SCALE * 2

		#generate the player entity
		@player = {}
		if @hori_vert then @player = new Player 10, 100, '#ff0000', 30, 30, @hori_vert
		else @player = new Player 500, 560, '#ff0000', 30, 30, @hori_vert
		@entities.push @player
		
		@entities.push new Wall -15, '#808000', @hori_vert
		@entities.push new Wall g.height - 15, '#808000', @hori_vert

		@levelStart = true

	addEntity: ->
		for entity in arguments
			@entities.push entity

	addPlayer: (player) ->
		@player = player
		@addEntity player

	checkForDeath: ->
		if @player.y > @height + @windowDimensions.height / 2 then @player.reset()

	checkForEnd: ->
		if @levelEnded
			@levelOver 2
		else if @player.contactEdges
			for edge in @player.contactEdges
				pos = edge.other.GetWorldCenter()
				@levelOver(2) if pos == @objective.body.GetWorldCenter()

	levelOver: (sec) ->
		@levelEnded = true
		end = false
		for canvas in g.canvases
			if canvas.fadeOut sec
				end = true
		if end
			delete @levelEnded
			g.gameWorld.toNextLevel()

	levelStarting: (sec) ->
		start = false
		for canvas in g.canvases
			if canvas.fadeIn sec
				start = true
		if start
			@levelStart = false

	update: ->
		entity.update() for entity in @entities

	draw: (rCanvas) ->
		@canvas.clear()
		entity.draw @canvas for entity in @entities
		@canvas.draw rCanvas

	checkExtremes: (entity) ->
		extremes = entity.extremes
		draw = false
		#check if the entity is contained within the player's view
		if @viewRect.right < extremes.left \
		or @viewRect.left > extremes.right \
		or @viewRect.top < extremes.bottom \
		or @viewRect.bottom > extremes.top
			draw = true
		if draw
			entity.draw()

###
	This is a level that servers only to display text on the screen. There are no
	entities or anything. The reason this exists as a level is for clarity as it
	is added to the gameWorld's list of levels.
###
class window.TextLevel
	constructor: () ->
		@texts =[]
		@canvas = g.canvases[0]
		@levelStart = true

	addText: (text, left, top, font, fontSize, color) ->
		@texts.push {
			text: text
			left: left
			top: top
			font: font
			fontSize: fontSize
			color: color
		}

	massAddText: ->
		for text in @arguments
			if text.text and text.left and text.top and text.font and text.fontSize and text.color
				@texts.push text
			else
				console.log "ERROR: text entry is missing categories"

	levelStarting: (sec) ->
		start = false
		for canvas in g.canvases
			if canvas.fadeIn sec
				start = true
		if start
			@levelStart = false

	update: ->
		if @levelStart
			@levelStarting 2

	draw: ->
		canvas.clear() for canvas in g.canvases
		for text in @texts
			@canvas.hardTextDraw text.text, text.left, text.top, text.font, text.fontSize, text.color
		canvas.draw() for canvas in g.canvases
