window.b2Vec2 = Box2D.Common.Math.b2Vec2
window.b2BodyDef = Box2D.Dynamics.b2BodyDef
window.b2Body = Box2D.Dynamics.b2Body
window.b2FixtureDef = Box2D.Dynamics.b2FixtureDef
window.b2Fixture = Box2D.Dynamics.b2Fixture
window.b2World = Box2D.Dynamics.b2World
window.b2MassData = Box2D.Collision.Shapes.b2MassData
window.b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
window.b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
window.b2DebugDraw = Box2D.Dynamics.b2DebugDraw
window.b2WorldManifold = Box2D.Collision.b2WorldManifold

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


    #global functions start here
    initPhysics: ->
        #arguments for GameLevel: gracVec, width, height, playerX, playerY, objX, objY
        #entities are generally added from leftmost to rightmost for each level
        level0 = new GameLevel (new b2Vec2 0, 40), 50, 30, 2, 4, 48, 29
        level0.addEntity(
            new TextEntity 2, 3, 'Arial', '50px', "#000000", "Use left and right arrows to move"
            new BlackStaticBox 25, 30.5, 52, 1 #floor
            new BlackStaticBox 2, 20, 4, 20 #platform
            new SineRampComposite 4, 10, 20, 30, 20, 'l'
        )
        level1 = new GameLevel (new b2Vec2 0, 40), 174, 31, 2, 10, 172, 29
        level1.addEntity(
            new TextEntity 2, 3, 'Arial', '50px', '#000000', 'Press the spacebar or up arrow to jump'
            new BlackStaticBox 22.5, 22.5, 45, 17 #floor
            new BlackStaticBox 20, 13, 8, 2 #obstacle
            new BlackStaticBox 65, 22.5, 20, 17 #floor
            #this part is the first ramp that the player experiences in the game
            new SineRampComposite 75, 14, 20, 30, 16, 'l'
            new BlackStaticBox 95, 30.5, 40, 1 #floor
            #platform with the objective on it
            new BlackStaticBox 159, 30.5, 30, 1 #floor
        )
        level2 = new GameLevel (new b2Vec2 0, 40), 180, 25, 2, 4, 178, 18
        level2.addEntity(
            new BlackStaticBox 62, level2.height + 0.5, 126, 1 #floor
            #platform for the ramp below
            new BlackStaticBox 2, 17.5, 4, 15
            #the ramp has to be positioned by the top left corner since it is a polygon not a box
            new SineRampComposite 4, 10, 20, 25, 15, 'l'
            #series of three steps for the player to jump
            new BlackStaticBox 67, 24, 24, 2
            new BlackStaticBox 89, 23, 24, 4
            new BlackStaticBox 113, 22, 24, 6
            #platform and floor for the objectice
            new BlackStaticBox 165, 22, 30, 6 #platform
            new BlackStaticBox 165.5, level2.height + .5, 31, 1 #floor
        )
        level3 = new GameLevel (new b2Vec2 0, 40), 130, 50, 48, 40, 128, 39
        level3.addEntity(
            new BlackStaticBox 35.5, level3.height + .5, 73, 1
            #create the circular 'half-pipe' the player needs to climb
            new CircleRampComposite 0, 20, 30, 30, 'l'
            #jump the player launches off of and the platform they need to land on
            new RampEntity 64, 46, 8, 4, 'right'
            #platform and floor for objective
            new BlackStaticBox 120, 45, 20, 10 #platform
            new BlackStaticBox 120.5, level3.height + .5, 21, 1 #floor
        )
        level4 = new GameLevel (new b2Vec2 0, 40), 182, 34, 2, 4, 180, 33
        level4.addEntity(
            new BlackStaticBox 53.5, 34.5, 109, 1
            new BlackStaticBox 2, 20, 4, 28
            new SineRampComposite 4, 6, 20, 35, 28, 'l'
            new CircleRampComposite 99, 26, 8, 8, 'r'
            new BlackStaticBox 107.5, 30, 1, 8
            new CircleRampComposite 113, 26, 8, 8, 'l'
            new BlackStaticBox 112.5, 30, 1, 8
            new BlackStaticBox 122, 34.5, 20, 1
            new BlackStaticBox 172, 34.5, 22, 1

        )
        level5 = new GameLevel (new b2Vec2 0, 40), 242, 170, 2, 5, 240, 169
        level5.addEntity(
            new BlackStaticBox 2, 18, 4, 20
            new SineRampComposite 4, 8, 20, 28, 20, 'l'
            new BlackStaticBox 30, 30, 60, 4
            new SineRampComposite 60, 28, 10, 28, 4, 'l'
            #left wall start
            new BlackStaticBox 72, 34, 32, 4
            new BlackStaticBox 80, 38, 32, 4
            new BlackStaticBox 98, 42, 4, 4
            new BlackStaticBox 102, 46, 4, 4
            new BlackStaticBox 106, 109, 4, 122
            new BlackStaticBox 110, 80, 4, 48
            new BlackStaticBox 114, 78, 4, 36
            new BlackStaticBox 118, 78, 4, 12
            #right wall start
            new BlackStaticBox 114, 38, 4, 4
            new BlackStaticBox 118, 42, 4, 4
            new BlackStaticBox 122, 46, 4, 4
            new BlackStaticBox 126, 52, 4, 8
            new BlackStaticBox 130, 58, 4, 4
            new BlackStaticBox 134, 66, 4, 12
            new BlackStaticBox 138, 78, 4, 12
            new BlackStaticBox 134, 90, 4, 12
            new BlackStaticBox 130, 98, 4, 4
            new BlackStaticBox 130, 102, 4, 4
            new BlackStaticBox 126, 108, 4, 8
            #end of tunnel wall
            new CircleRampComposite 108, 150, 20, 20, 'l'
            new BlackStaticBox 132, 170.5, 56, 1
            new BlackStaticBox 234, 170.5, 18, 1
        )
        endLevel = new TextLevel()
        endLevel.addText "The End", 960, 640, "Arial", "60px", "#000000"
        g.gameWorld.addLevel level0, level1, level2, level3, level4, level5, endLevel

window.requestAnimationFrame or=
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.oRequestAnimationFrame or
    window.msRequestAnimationFrame or
    (callback, element) ->
        window.setTimeout( ->
            callback new Date()
        , 1000 / 60)
