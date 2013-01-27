class window.GameWorld
	constructor: () ->
		@level1 = new GameLevel 0, true
		@level2 = new GameLevel Math.PI / 2, false
		@levelOrder = [@level1, @level2]
		@levelSplit = 10000
		@nextLevel = g.now + @levelSplit
		@pickupSplit = 5000
		@nextPickup = g.now + @pickupSplit + (Math.random() * @pickupSplit)
		@challengeSplit = 5000
		@nextChall = g.now + @challengeSplit
		@canvas = new RenderCanvas()
		@pickup1 = new Pickup 25, 500, 0, @level1
		@pickup2 = new Pickup 25, 500, 0, @level2
		@gameOver = false
		@winner = null
		@swapZoomAdj = 0.3
	
	collectPickup: (onbot) ->
		@level1.entities.remove @pickup1
		@pickup1.collected = false
		@level2.entities.remove @pickup2
		@pickup2.collected = false
		switch @pickup1.type
			when 0 then @swap onbot
			when 1 then @reverse onbot
			when 2 then @spin()
			else console.log 'invalid type as you already know'
	
	swap: (onbot) ->
		if not @swapPeriod
			if onbot
				@swapPeriod = g.now + g.swap
				@targetAngle1 = @levelOrder[0].angle + (Math.PI / 2)
				@targetAngle2 = @levelOrder[1].angle - (Math.PI / 2)
				console.log @targetAngle1 + ' ' + @targetAngle2
		else if g.now <= @swapPeriod
			@swapZoomAdj -= 0.6 * (g.elapsed / g.swap)
			@level1.canvas.zoom = 0.7 + Math.abs @swapZoomAdj
			@level2.canvas.zoom = 0.7 + Math.abs @swapZoomAdj
			angleAdj = (Math.PI / 2) * (g.elapsed / g.swap)
			@levelOrder[0].angle += angleAdj
			@levelOrder[1].angle -= angleAdj
		else if g.now >= @swapPeriod
			@level1.canvas.zoom = 1
			@level2.canvas.zoom = 1
			@levelOrder.reverse()
			@levelOrder[0].angle = @targetAngle2
			@levelOrder[1].angle = @targetAngle1
			@nextPickup = g.now + @pickupSplit + (Math.random() * @pickupSplit)
			delete @swapPeriod
			delete @targetAngle2
			delete @targetAngle1
	
	reverse: (onbot) ->
		if not @revPeriod
			@revPeriod  = g.now + g.reverse
			if onbot then @revTarget = 0
			else @revTarget = 1
			@targetAngle = @levelOrder[@revTarget].angle + Math.PI
		else if g.now <= @revPeriod
			angleAdj = (Math.PI) * (g.elapsed / g.reverse)
			@levelOrder[@revTarget].angle += angleAdj
		else if g.now >= @revPeriod
			@levelOrder[@revTarget].angle = @targetAngle
			if @levelOrder[@revTarget].angle >= Math.PI * 2
				@levelOrder[@revTarget].angle = 0
			delete @revPeriod
			delete @revTarget
			delete @targetAngle
			@nextPickup = g.now + @pickupSplit + (Math.random() * @pickupSplit)
	
	challenge: ->
		if not @challengePeriod
			@challengePeriod = g.now + g.challenge
			@targetAngle1 = @level1.angle
			@targetAngle2 = @level2.angle
			@level1.entities.remove @pickup1
			@level2.entities.remove @pickup2
		if g.now <= @challengePeriod
			angleAdj = (Math.PI * 2 * g.challengeRot) * (g.elapsed / g.challenge)
			@level1.angle += angleAdj
			@level2.angle -= angleAdj
		if g.now >= @challengePeriod
			@level1.angle = @targetAngle1
			@level2.angle = @targetAngle2
			delete @targetAngle1
			delete @targetAngle2
			delete @challengePeriod
			@nextPickup = g.now + @pickupSplit + (Math.random() * @pickupSplit)
			@nextChall = g.now + @challengeSplit

	update: ->
		g.input.update()
		if not @gameOver

			#level up
			if @nextLevel <= g.now
				@level1.level++
				@level2.level++
				@nextLevel = g.now + @levelSplit

			#check if using powerup or if you need to spawn one
			if @swapPeriod then @swap()
			else if @revPeriod then @reverse()
			else if @challengePeriod then @challenge()
			else if g.now >= @nextChall then @challenge()
			else
				if @nextPickup and @nextPickup <= g.now
					type = Math.floor Math.random() * 2
					type = 0
					@pickup1.changeType type
					@pickup2.changeType type
					#@level1.entities.push @pickup1
					@level2.entities.push @pickup2
					@nextPickup = null
				if @pickup1.collected
					onbot = false
					if @level1 == @levelOrder[1]
						onbot = true
					@collectPickup onbot
				else if @pickup2.collected
					onbot = false
					if @level2 == @levelOrder[1]
						onbot = true
					@collectPickup onbot

			#check for game over and update the levels
			if not @level1.gameOver
				@level1.update g.input.isKeyNewDown 83
			else if not @gameOver
				@gameOver = true
				@winner = 2
				console.log 'player 2 wins'
			if not @level2.gameOver
				@level2.update g.input.isKeyNewDown 83
			else if not @gameOver
				@gameOver = true
				@winner = 1
				console.log 'player 1 wins'
		else
			if g.input.isKeyNewDown 32
				@reset = true

	draw: ->
		#if not @gameOver
		@canvas.clear()
		@levelOrder[1].draw @canvas
		@levelOrder[0].draw @canvas
		if @gameOver
			if @winner == 1
				@canvas.context.fillStyle = '#800000'
			else if @winner == 2
				@canvas.context.fillStyle = '#000080'
			@canvas.context.fillRect 100, 100, 400, 400
			$('#gameText').css 'color', '#ff00ff'
			$('#uprTxt').html 'WINNER!!!!'
			$('#lwrTxt').html 'Hit SPACE to play again'
		@canvas.draw()
