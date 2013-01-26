###
This is a class that is used to access the output from the listerners also in this file.
This object is used to simplify access to those listeners
###
class window.InputHandler
  constructor: ->
    @keys = []
    @oldKeys = []
    @new = false

  #this is done every frame to get the current input state
  update: ->
    #slice the array to create a clone of the array
    @oldKeys = @keys.slice 0
    @keys = input.keys.slice 0
    @new = input.new
    #set new to false so that we know the key has been registered
    input.new = false

  isKeyDown: (num) ->
    return true if @keys.contains num
    return false

  isKeyNewDown: (num) ->
    return true if (@keys.contains num) and (not @oldKeys.contains num)
    return false

#below here is where we put the listerners and an object to store the output of those listeners
#this part of the code operators outside of the gameloop that the rest of the code is within
input =
  keys: []
  new: false

$(document).keydown (e) ->
  #console.log e.which
  input.keys.push(e.keyCode) if !input.keys.contains e.keyCode
  input.new = true if !input.new

$(document).keyup (e) ->
  input.keys.splice input.keys.indexOf(e.keyCode), 1
