class window.Player extends DynamicCircle
    constructor: (@x, @y, @radius) ->
        super @x, @y, @radius, 'sprites/Red_Circle.png'
        @fixDef.density = 2.0
        #this array contains all contactEdges where the player is touching the contact
        @contactEdges = []
        @colliding = false #is the player touching another object
        @canJump = false
        @jumpPrev = null
        @jumpBuffer = 100 #number of milliseconds the player is allowed to still jump after collision stops
        @heightTrack = @y
        @gMove = 20
        @aMove = 5

    goRight: ->
        vec = @body.GetLinearVelocity()
        if vec.x < @gMove and @canJump
            @body.ApplyImpulse new b2Vec2(@gMove, 0), @body.GetWorldCenter()
        #if the player is in air, give them more limited control of horizontal movement
        else if vec.x < @aMove
            @body.ApplyImpulse new b2Vec2(@aMove, 0), @body.GetWorldCenter()

    goLeft: ->
        vec = @body.GetLinearVelocity()
        if vec.x > -@gMove and @canJump
            @body.ApplyImpulse new b2Vec2(-@gMove, 0), @body.GetWorldCenter()
        else if vec.x > -@aMove
            @body.ApplyImpulse new b2Vec2(-@gMove, 0), @body.GetWorldCenter()

    jump: ->
        #if @colliding and @lastJump + @jumpLockout < g.now
        if @canJump
            @lastJump = g.now
            @body.ApplyImpulse new b2Vec2(0, -120), @body.GetWorldCenter()

    #returns the player to the starting location for the level
    reset: ->
        newPos = new b2Vec2 @startX, @startY
        @body.SetPosition newPos
        newVel = new b2Vec2 0, 0
        @body.SetLinearVelocity newVel
        @body.SetAngularVelocity 0

    update: ->
        tContacts = @body.GetContactList()
        testCollide = false
        #tContacts is a link list and must be iterated over
        while tContacts
            if tContacts.contact.IsTouching()
                @contactEdges.push tContacts
                testCollide = true
            tContacts = tContacts.next
        if testCollide
            @canJump = true
            @jumpPrev = null
        #if not colliding make a note of when the player stopped colliding
        else if not @jumpPrev
            @jumpPrev = g.now
        #if the player stopped colliding more than @jumpBuffer ms ago, don't let them jump
        else if g.now - @jumpPrev >= @jumpBuffer
            @canJump = false
        @colliding = testCollide
        #handle da input
        if g.input.isKeyDown 39
            @goRight()
        else if g.input.isKeyDown 37
            @goLeft()
        if g.input.isKeyNewDown(32) or g.input.isKeyNewDown(38)
            @jump()
        super
