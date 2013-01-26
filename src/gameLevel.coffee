class window.GameLevel
    #these arguments provide the gravity vector as well as the x,y coordinates for the objective
    constructor: (gravVec, @width, @height, playerX, playerY, objX, objY) ->
        @entities = []
        #this is the position in the game world that the draw window should start from
        #this is mapped to the top left corner of the window, not the center
        @worldPos =
            x: 0
            y: 0
        #this is not set to adjust for zoom level, this needs to be changed
        @windowDimensions =
            width: g.width / g.SCALE * 2
            height: g.height / g.SCALE * 2
        #create a rectangle that defines the corners of the viewable space
        #this is used to determine what entities should be rendered
        @viewRect =
            left: @worldPos.x
            right: @worldPos.x + @windowDimensions.width
            top: @worldPos.y
            bottom: @worldPos.y + @windowDimensions.height
        @world = new b2World gravVec, true

        #generate the player entity
        @player = new Player playerX, playerY, 1
        @worldPos.x = @player.x - @windowDimensions.width / 2
        @player.initPhysics @world
        @entities.push @player

        @levelStart = true

        #now that the world is created, add the walls and ceiling
        ceiling = new BlackStaticBox @width/2, -0.5, @width+2, 1
        ceiling.initPhysics @world
        left = new BlackStaticBox -.5, @height / 2, 1, @height
        left.initPhysics @world
        right = new BlackStaticBox @width + .5, @height/2, 1, @height
        right.initPhysics @world
        @entities.push ceiling, left, right

        #add the objective to the level at the provided coordinates
        @objective = new StaticBox objX, objY, 2, 2, 'sprites/objective.png'
        @objective.initPhysics @world
        @entities.push @objective

        #debug draw will probably not be needed but set it up anyways just in case
        debugDraw = new b2DebugDraw()
        debugDraw.SetSprite document.getElementById('testing').getContext '2d'
        debugDraw.SetDrawScale g.SCALE
        debugDraw.SetFillAlpha 0.3
        debugDraw.SetLineThickness 1.0
        debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
        @world.SetDebugDraw debugDraw

    addEntity: ->
        for entity in arguments
            entity.initPhysics(@world) if entity.initPhysics
            @entities.push entity

    addPlayer: (player) ->
        @player = player
        @worldPos.x = @player.x - @windowDimensions.width / 2
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
                
            ###
            edges = @player.contacts
            #since edges is a linked list, just iterate until edges is null
            while edges
                #edges.other is the body that is being collided with
                if edges.contact.IsTouching()
                        pos = edges.other.GetWorldCenter()
                        if pos == @objective.body.GetWorldCenter() then @levelOver()
                edges = edges.next
            ###

    initTheThings: ->
        for entity in @entities
            #only init the bodies that actually have physics properties
            entity.initPhysics(@world) if entity.initPhysics

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

        if @levelStart
            @levelStarting 2

        @world.Step 1/60, 10, 10
        #@world.DrawDebugData()
        @world.ClearForces()

        entity.update() for entity in @entities
        #keep the player horizontally centered in the screen
        #but only if they are still within the level, otherwise check for death
        if @player.y < @height
            @worldPos.x = @player.x - @windowDimensions.width / 2
            @worldPos.y = @player.y - @windowDimensions.height / 2
            @viewRect =
                left: @worldPos.x
                right: @worldPos.x + @windowDimensions.width
                top: @worldPos.y
                bottom: @worldPos.y + @windowDimensions.height
        else @checkForDeath()
        @checkForEnd()

    draw: ->
        canvas.clear() for canvas in g.canvases
        for entity in @entities
            if entity instanceof Composite
                ###
                for subentity in entity.entities
                    @checkExtremes subentity
                ###
                entity.draw()
            else if entity instanceof Player or entity instanceof TextEntity
                entity.draw()
            else
                @checkExtremes entity
        canvas.draw() for canvas in g.canvases

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
