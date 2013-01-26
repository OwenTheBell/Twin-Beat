###
This is a wrapper class that handles adding a canvas entity to the DOM as well
as ensuring that everything draws to that canvas. This abstracts the need to 
handle contexts with other objects as well as covering prerendering.
###
class window.Canvas
    constructor: (@layer) ->
        #this variable will control level of zoom eventually
        @zoom = 2
        #start all canvases as covered by white
        @alpha = 1
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
        #add the canvas that we have created to our page
        $('#peg').append @renderCanvas

    update: ->

#this function takes the prerendered canvas that has been rendered and draws
#it to the canvas that is actually on the DOM
    draw: ->
        if @alpha > 0
            @context.fillStyle = "rgba(255, 255, 255," + @alpha + ")"
            @context.fillRect 0, 0, @canvas.width, @canvas.height
        @renderContext.drawImage @canvas, 0, 0, @width, @height

    clear: ->
        @context.clearRect 0, 0, @width * @zoom, @height * @zoom
        @renderContext.clearRect 0, 0, @width, @height

    fadeIn: (sec) ->
        if not @fading
            @fading = true
            @fadingTime = 0
            @finishFade = sec
        else if @fadingTime < @finishFade
            @fadingTime += g.elapsed
            @alpha = 1 - @fadingTime / @finishFade
        else
            delete @fading
            delete @fadingTime
            delete @finishFade
            return true
        return false

    fadeOut: (sec) ->
        if not @fading
            @fading = true
            @fadingTime = 0
            @finishFade = sec
        else if @fadingTime < @finishFade
            @fadingTime += g.elapsed
            @alpha = @fadingTime / @finishFade
        else
            delete @fading
            delete @fadingTime
            delete @finishFade
            return true
        return false

#most basic drawing function, this is used when the body exactly matches the
#sprite that needs to be drawn
    drawBody: (entity) ->
        sprite = entity.sprite
        #if the entity if a Box then the texture may needs to be tiled
        if entity instanceof BoxPEntity or entity instanceof BoxEntity
            if sprite.width != entity.pixelWidth() or sprite.height != entity.pixelHeight()
                @drawTiled entity
                return #don't finish the rest of the function
        #if the entity is not a box just assume that it can be drawn as is
        body = entity.body
        x = Math.round (entity.x - g.gameWorld.activeLevel.worldPos.x) * g.SCALE
        y = Math.round (entity.y - g.gameWorld.activeLevel.worldPos.y) * g.SCALE
        @context.save()
        @context.translate x, y
        @context.rotate entity.angle
        #@context.rotate body.GetAngle()
        @context.drawImage sprite.image, -(sprite.width / 2), -(sprite.height / 2)
        @context.restore()

#dis is very interesting, apparently Box2D has inconsistent system of
#determing world position
    drawBodyTopLeft: (entity) ->
        body = entity.body
        sprite = entity.sprite
        x = Math.round (entity.x - g.gameWorld.activeLevel.worldPos.x) * g.SCALE
        y = Math.round (entity.y - g.gameWorld.activeLevel.worldPos.y) * g.SCALE
        @context.save()
        @context.translate x, y
        @context.rotate body.GetAngle()
        @context.drawImage sprite.image, 0, 0
        @context.restore()

    drawTiled: (entity) ->
        body = entity.body
        sprite = entity.sprite
        #since GetPostion() returns the center of the entity the coordinates need to be moved to the top left
        x = Math.round((entity.x - g.gameWorld.activeLevel.worldPos.x) * g.SCALE) - (entity.pixelWidth() / 2)
        y = Math.round((entity.y - g.gameWorld.activeLevel.worldPos.y) * g.SCALE) - (entity.pixelHeight() / 2)
        width = entity.pixelWidth()
        height = entity.pixelHeight()
        @context.save()
        @context.translate x, y
        @context.rotate entity.angle
        #@context.rotate body.GetAngle()
        #There define the top left corner of where you are about to draw within the image
        drawX = 0
        drawY = 0
        while drawY < height
            #draw only to height and width available in the entity. If there is more than enough space
            #for the sprite then draw it once and move on. Otherwise cut off the edges of the sprite
            #to make it fit
            dWidth = if width - drawX < sprite.width then width - drawX else sprite.width
            dHeight = if height - drawY < sprite.height then height - drawY else sprite.height
            #NOTE: use dWidth and dHeight here because you are defining the width and height of what you
            #are drawing. The last two arguments are not supposed to be dimensions of source sprite
            @context.drawImage sprite.image, 0, 0, dWidth, dHeight, drawX, drawY, dWidth, dHeight
            drawX += sprite.width
            if drawX >= width
                drawX = 0
                drawY += sprite.height
        @context.restore()

#This is probably just a temp method used to make debugging a help of a lot easier
#Side note, performance on this is shitty as hell
    drawStretched: (entity) ->
        body = entity.body
        sprite = entity.sprite
        topLeft = entity
        x = Math.round (topLeft.x - g.gameWorld.activeLevel.worldPos.x) * g.SCALE
        y = Math.round (topLeft.y - g.gameWorld.activeLevel.worldPos.y) * g.SCALE
        @context.save()
        @context.translate(x, y)
        @context.rotate body.GetAngle()
        if entity.reversed
            @context.scale -1, 1
            @context.drawImage sprite.image, -entity.pixelWidth(), 0, entity.pixelWidth(), entity.pixelHeight()
        else
            @context.drawImage sprite.image, 0, 0, entity.pixelWidth(), entity.pixelHeight()
        @context.restore()

    drawText: (entity) ->
        #console.log entity.x + ', ' + entity.y
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

    drawFill: (entity) ->
        topLeft = entity.topLeft
        x = Math.round((topLeft.x - g.gameWorld.activeLevel.worldPos.x) * g.SCALE)
        y = Math.round((topLeft.y - g.gameWorld.activeLevel.worldPos.y) * g.SCALE)
        corners = entity.corners
        @context.save()
        @context.fillStyle = "#000000"
        @context.translate x, y
        @context.rotate entity.angle
        @context.beginPath()
        #round all values to make sure that canvas is not drawing subpixels
        @context.moveTo Math.round(corners[0].x * g.SCALE), Math.round(corners[0].y * g.SCALE)
        i = 1
        while i < corners.length
            @context.lineTo Math.round(corners[i].x * g.SCALE), Math.round(corners[i].y * g.SCALE)
            i++
        @context.lineTo Math.round(corners[0].x * g.SCALE), Math.round(corners[0].y * g.SCALE)
        @context.closePath()
        @context.fill()
        @context.restore()
