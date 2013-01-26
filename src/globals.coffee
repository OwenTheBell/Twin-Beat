#I find putting global variables and functions in object g makes stuff clearer
window.g =
    input: {}
    canvases: []
    layers: 1
    SCALE: 30
    #everything below here is set at run time
    now: null
    lastFrame: null
    div: null
    top: null
    left: null
    height: null
    world: null
    worker: null

Array.prototype.last = ->
	@[@length - 1]

Array.prototype.removeIndex = (index) ->
	@shift index, 1

window.requestAnimationFrame or=
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.oRequestAnimationFrame or
    window.msRequestAnimationFrame or
    (callback, element) ->
        window.setTimeout( ->
            callback new Date()
        , 1000 / 60)
