class window.GameWorld
	constructor: () ->
		@level1 = new GameLevel 0, true
		@level2 = new GameLevel Math.PI / 2, false
		@levelOrder = [@level1, @level2]
		@levelSplit = 10000
		@nextLevel = g.now + @levelSplit
		@pickupSplit = 5000
		@nextPickup = g.now + @pickupSplit + (Math.random() * @pickupSplit)
		@canvas = new RenderCanvas()
		@gameOver = false
		@startGame = true
		@start = g.now
		@winner = null
		@swapZoomAdj = 0.3
		@themeMusic = new Audio 'theme'
	
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
			@swapPeriod = g.now + g.swap
			console.log @swapPeriod + ' ' + g.now
			@targetAngle1 = @createTarget @levelOrder[0].angle, Math.PI / 2
			@targetAngle2 = @createTarget @levelOrder[1].angle, -(Math.PI / 2)
			console.log @targetAngle1 + ' ' + @targetAngle2
		else if g.now <= @swapPeriod
			@swapZoomAdj -= 0.6 * (g.elapsed / g.swap)
			@level1.canvas.zoom = 0.7 + Math.abs @swapZoomAdj
			@level2.canvas.zoom = 0.7 + Math.abs @swapZoomAdj
			console.log @level1.canvas.zoom
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
			@swapZoomAdj = 0.3
			delete @swapPeriod
			delete @targetAngle2
			delete @targetAngle1
	
	reverse: (onbot) ->
		if not @revPeriod
			@revPeriod  = g.now + g.reverse
			console.log @revPeriod + ' ' + g.now
			if onbot then @revTarget = 0
			else @revTarget = 1
			@targetAngle = @createTarget @levelOrder[@revTarget].angle, Math.PI
			console.log @targetAngle
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
	
	createTarget: (old, adj) ->
		target = (Math.PI / 2) * Math.round (old + adj) / (Math.PI / 2)
		if target > Math.PI * 2
			target = (Math.PI / 2) * Math.round (target - Math.PI * 2) / (Math.PI / 2)
		return target
	
	challenge: ->
		if not @challengePeriod
			@challengePeriod = g.now + g.challenge + g.challengePrep
			@challengePrep = g.now + g.challengePrep
			@targetAngle1 = @level1.angle
			@targetAngle2 = @level2.angle
			@themeMusic.pause()
			@challenge1.play()
		else if g.now <= @challengePrep
			1 #just waiting for now
		else if g.now <= @challengePerio
			delete @challengePrep
			angleAdj = (Math.PI * 2 * g.challengeRot) * (g.elapsed / g.challenge)
			@level1.angle += angleAdj
			@level2.angle -= angleAdj
		else if g.now >= @challengePeriod
			if not @challengePrep
				@challengePrep = g.now + g.challengePrep
			else
				@level1.angle = @targetAngle1
				@level2.angle = @targetAngle2
				delete @targetAngle1
				delete @targetAngle2
				delete @challengePeriod
				delete @challengePrep
				@nextPickup = g.now + @pickupSplit + (Math.random() * @pickupSplit)
				@nextChall = g.now + @challengeSplit
				@themeMusic.play()

	update: ->
		g.input.update()
		if not @gameOver and not @startGame

			#level up
			if @nextLevel <= g.now
				@level1.level++
				@level2.level++
				@nextLevel = g.now + @levelSplit
				@pickupSplit -= 100

			#check if using powerup or if you need to spawn one
			if @swapPeriod then @swap()
			else if @revPeriod then @reverse()
			#else if @challengePeriod then @challenge()
			#else if g.now >= @nextChall then @challenge()
			else
				if @nextPickup and @nextPickup <= g.now
					onbot = false
					if Math.random() > 0.5
						onbot = true
					if Math.random() > 0.5
						@swap true
					else
						@reverse onbot
			#check for game over and update the levels
			if not @level1.gameOver
				if not @challengePrep
					@level1.update g.input.isKeyNewDown 83
			else if not @gameOver
				@end = g.now
				@gameOver = true
				@winner = 2
			if not @level2.gameOver
				if not @challengePrep
					#@level2.update g.input.isKeyNewDown 83
					@level2.update g.input.isKeyNewDown 76
			else if not @gameOver
				@end = g.now
				@gameOver = true
				@winner = 1
		else
			if g.input.isKeyNewDown 88
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
			$('#midTxt').html 'You lasted: ' + ((@end - @start) / 1000)
			$('#lwrTxt').html 'Press X to play again'
		else if @startGame
			$('#uprTxt').html 'Press X to play'
		@canvas.draw()
