class window.Entity
	constructor: (@x, @y, @color) ->

	update: ->

	draw: (canvas) ->

class window.RectEntity extends Entity
	constructor: (x, y, color, @width, @height) ->
		super x, y, color

class window.Obstacle extends RectEntity
	constructor: (x, y, color, @parent) ->
		super x, y, color, 30, 30
	
	checkCollision: ->
		player = @parent.player
		return not ((player.x > @x + @width) or
				(player.x + player.width < @x) or
				(player.y > @y + @height) or
				(player.y + player.height < @y))

	update: ->
		if @checkCollision()
			@parent.player.dead = true
		@x -= g.lateral

	draw: (canvas) ->
		canvas.drawFill @

class window.Player extends RectEntity
	constructor: (x, y, color, @parent) ->
		@acceleration = 0
		@boost = -4
		@gap = 60
		@lastBeat = 0
		@firstBeat = false
		@dead = false
		super x, y, color, 30, 30
	
	update: ->
		input = g.input
		@acceleration += g.gravity
		if @parent.inputBool
			@checkBeat()
		@y += @acceleration

	checkBeat: ->
		if not @firstBeat
			@firstBeat = true
		else
			@firstBeat = false
			@acceleration += @boost
		
	draw: (canvas) ->
		canvas.drawFill @

class window.Pickup extends RectEntity
	constructor: (x, y, @type, @parent) ->
		switch @type
			when 0 then color = '#ff00ff'
			when 1 then color = '#800080'
			when 2 then color = '#ffff00'
			else console.log 'invalid pickup type'
		super x, y, color, g.entityDim, g.entityDim
		@collected = false
	
	checkCollision: ->
		player = @parent.player
		return not ((player.x > @x + @width) or
				(player.x + player.width < @x) or
				(player.y > @y + @height) or
				(player.y + player.height < @y))

	changeType: (type) ->
		@type = type
		switch @type
			when 0 then @color = '#ff00ff'
			when 1 then @color = '#800080'
			when 2 then @color = '#ffff00'
			else console.log 'invalid pickup type'

	update: ->
		if @checkCollision()
			@collected = true

	draw: (canvas) ->
		canvas.drawFill @

class window.Wall
	constructor: (@pos, color, @parent) ->
		@entities = []
		count = Math.ceil (g.width * 1.5) / g.entityDim
		for i in [0..count + 1]
			@entities.push new Obstacle g.entityDim * i, @pos, color, @parent
	
	update: ->
		first = @entities[0]
		if first.x + first.width < -(g.width / 2)
			@entities.removeIndex 0
			end = @entities.last()
			last = new Obstacle end.x + g.entityDim, @pos, end.color, @parent
			@entities.push last
		entity.update() for entity in @entities
	
	draw: (canvas) ->
		entity.draw canvas for entity in @entities
