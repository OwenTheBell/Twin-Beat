class window.Audio
	constructor: (target) ->
		if $.browser.webkit or $.browser.msie
			@element = document.getElementById target + 'mp3'
		else
			@element = document.getElementById target + 'ogg'
	
	play: ->
		@element.play()
	
	pause: ->
		@element.pause()
