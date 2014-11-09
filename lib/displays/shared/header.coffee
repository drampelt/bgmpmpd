blessed = require 'blessed'
class Header extends blessed.box
  constructor: (@events, @mpd, @blessed, options) ->
    super options

    @title = @blessed.text
      top: 0
      left: 0
      width: '80%'
      height: 1
      content: 'Connecting...'
      align: 'left'
      style: hover: bg: 'green'
    @append @title

    @volume = @blessed.text
      top: 0
      left: '80%'
      width: '20%'
      height: 1
      content: '100%'
      align: 'right'
      style: hover: bg: 'green'
    @append @volume
    @volume.on 'wheeldown', => @events.emit 'mpd-vol', -2
    @volume.on 'wheelup', => @events.emit 'mpd-vol', 2

    @separator = @blessed.line
      top: 1
      left: 0
      width: '100%'
      height: 1
      orientation: 'horizontal'
    @append @separator

    @events.on 'update-title', => @updateTitle.apply @, arguments
    @events.on 'mpd-status', => @updateVolume.apply @, arguments

  updateTitle: (title) ->
    @title.setText title
    @events.emit 'render'

  updateVolume: (status) ->
    @volume.setText "#{status.volume}%"
    @events.emit 'render'

module.exports = Header
