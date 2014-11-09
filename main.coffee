blessed = require 'blessed'
program = blessed.program()
MPDBridge = require './lib/mpdbridge'
eventEmitter = require('events').EventEmitter


# Create the event emitter
events = new eventEmitter

# Connect to mpd
mpd = new MPDBridge events

# Create a screen object.
screen = blessed.screen()
container = blessed.box
  left: 0
  top: 0
  width: '100%'
  height: '100%'
screen.append container

# Displays
displayopts =
  top: 2
  left: 0
  width: '100%'
  height: screen.height - 4
  # style: bg: 'red'
Stations = require './lib/displays/stations'
Queue = require './lib/displays/queue'
currentview = stations = queue = null

# Title/Header
header = new (require './lib/displays/shared/header') events, mpd, blessed,
  top: 0
  left: 0
  width: '100%'
  height: 2
container.append header

# Song Info/Footer
footer = new (require './lib/displays/shared/footer') events, mpd, blessed,
  bottom: 0
  left: 0
  width: '100%'
  height: 2
container.append footer
# footer.render()

events.emit 'mpd-connect', 'localhost', 6600
events.on 'mpd-connected', ->
  events.emit 'mpd-get-song'
  # Load defualt display
  # container.append stations
  # stations.init()

events.on 'render', -> screen.render()

# setTimeout ->
#   events.emit 'mpd-get-song'
# , 5000

screen.key ['escape', 'q', 'C-c'], (ch, key) ->
  process.exit 0

screen.key ['1', '2', '3', '4', '5', '6'], (ch, key) ->
  container.remove currentview if currentview?
  switch ch
    when '1'
      queue = new Queue events, mpd, blessed, displayopts unless queue?
      container.append queue
      currentview = queue
    when '2'
      stations = new Stations events, mpd, blessed, displayopts unless stations?
      container.append stations
      currentview = stations
    else
      stations = new Stations events, mpd, blessed, displayopts unless stations?
      container.append stations
      currentview = stations
  currentview.init()

screen.render()
