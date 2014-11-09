request = require 'request'
blessed = require 'blessed'
_ = require 'lodash'
fs = require 'fs'

class Queue extends blessed.list
  constructor: (@events, @mpd, @blessed, options) ->
    super _.merge options, keys: true, mouse: true, selectedBg: 'red'

  init: ->
    @events.emit 'update-title', 'Queue'
    @focus()

    @events.emit 'mpd-playlistinfo'

    @on 'select', (item) =>

module.exports = Queue
