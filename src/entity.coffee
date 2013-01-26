class window.Entity
	constructor: (@x, @y, @color) ->

	update: ->

	draw: (canvas) ->

class window.RectEntity extends Entity
	constructor: (x, y, color, @width, @height) ->
		super x, y, color

class window.Obstacle extends Entity
	constructor: (x, y, color, @width, @height, @hori_vert) ->
		super x, y, color
	
	update: ->
		@x -= g.lateral
		###
		if @hori_vert then @x -= g.lateral
		else @y += g.lateral
		###

	draw: (canvas) ->
		canvas.drawFillBorder @

class window.Player extends RectEntity
	_acceleration = 0
	_boost = -4
	_gap = 60 #number of milliseconds between presses
	_lastBeat = 0 #when the last beast occured
	_firstBeat = false
	constructor: (x, y, color, width, height, @hori_vert) ->
		super x, y, color, width, height
	
	update: ->
		input = g.input
		_acceleration += g.gravity
		if (@hori_vert and input.isKeyNewDown 83) or input.isKeyNewDown 76
			@checkBeat()
		@y += _acceleration
		###
		if @hori_vert then @y += _acceleration
		else @x -= _acceleration
		###

	checkBeat: ->
		if not _firstBeat
			_firstBeat = true
		else
			_firstBeat = false
			_acceleration += _boost
		
	draw: (canvas) ->
		canvas.drawFill @

class window.Wall
	constructor: (@pos, color, @hori_vert) ->
		@entities = []
		count = Math.ceil g.width / g.entityDim
		for i in [0..count + 1]
			@entities.push new Obstacle g.entityDim * i, @pos, color, g.entityDim, g.entityDim, hori_vert
			###
			if hori_vert
				@entities.push new Obstacle g.entityDim * i, @pos, color, g.entityDim, g.entityDim, hori_vert
			else
				@entities.push new Obstacle @pos, g.entityDim * i, color, g.entityDim, g.entityDim, hori_vert
			###
	
	update: ->
		first = @entities[0]
		if first.x + first.width < 0
			@entities.removeIndex 0
			end = @entities.last()
			last = new Obstacle end.x + g.entityDim, @pos, end.color, g.entityDim, g.entityDim, @hori_vert
			@entities.push last
		###
		if _hori_vert and first.x + first.width < 0
			@entities.removeIndex 0
			end = @entities.last()
			last = new Obstacle end.x + g.entityDim, @pos, end.color, g.entityDim, g.entityDim, _hori_vert
			@entities.push last
		else if first.y + first.height < 0
			@entities.removeIndex 0
			last = new Obstacle @pos, end.y + g.entityDim, end.color, g.entityDim, g.entityDim, _hori_vert
			@entities.push last
		###
		entity.update() for entity in @entities
	
	draw: (canvas) ->
		entity.draw canvas for entity in @entities
