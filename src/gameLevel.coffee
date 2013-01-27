class window.GameLevel
	#vert_hori: defines whether level or vertical or horizontal scroll
	constructor: (@angle, @top) ->
		@entities = []
		@spawnGap = 1000
		@nextSpawn = 0
		@inputBool = false
		@canvas = new DrawCanvas()
		@playerC = '#800000'
		@obstacleC = '#ff0000'
		@gameOver = false
		@level = 0
		#if this is player2's level, change what needs to be changed
		if angle != 0
			@canvas.angle = @angle
			@playerC = '000080'
			@obstacleC = '#00ffff'
		@entities = []
		@player = new Player 25, 100, @playerC, @
		@entities.push @player
		
		@entities.push new Wall -15, @obstacleC, @
		@entities.push new Wall g.height - 15, @obstacleC, @

	update: (inputBool) ->
		@inputBool = inputBool
		@gameOver = @player.dead
		if @nextSpawn <= g.now
			for i in [0..@level]
				@entities.push new Obstacle(
					g.width * 1.5
					15 + Math.floor(Math.random() * (g.height - g.entityDim * 1.5))
					@obstacleC
					@
				)
			@nextSpawn = g.now + @spawnGap + Math.random() * @spawnGap
		@canvas.angle = @angle
		toRemove = []
		for entity in @entities
			if entity.x + entity.width < -(g.width / 2)
				toRemove.push entity
			else
				entity.update()
		for entity in toRemove
			@entities.remove entity

	draw: (rCanvas) ->
		@canvas.clear()
		entity.draw @canvas for entity in @entities
		rCanvas.drawCanvas @canvas
