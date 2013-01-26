class window.GameWorld
  constructor: () ->
    @levels = []
    @activeLevel = null
    @activeIndex = 0

  #one potential issue with this little bit of code is that levels cannont
  #be added to specific points in the level array. This may need to be fixed
  #so that levels don't have to be added in order.
  addLevel: ->
    for level in arguments
      @activeLevel = level if not @activeLevel
      @levels.push level

  toNextLevel: ->
    nextLevel = @levels[++@activeIndex]
    if nextLevel
      @activeLevel = nextLevel
    else
      @activeLevel = null
      console.log 'the end'

  update: ->
    @activeLevel.update()

  draw: ->
    @activeLevel.draw()
