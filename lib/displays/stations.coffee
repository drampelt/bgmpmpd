request = require 'request'
blessed = require 'blessed'
_ = require 'lodash'
fs = require 'fs'

class Stations extends blessed.list
  constructor: (@events, @mpd, @blessed, options) ->
    super _.merge options, keys: true, mouse: true, selectedBg: 'red'

  init: ->
    @events.emit 'update-title', 'Stations'
    @focus()

    @stations = {}
    @loadStations()

    @key 'r', =>
      @loadStations()

    @on 'select', (item) =>
      # console.log '\n'
      # console.log @stations[item.content]
      url = @stations[item.content]
      request(url).pipe fs.createWriteStream("/var/lib/mpd/playlists/gmusic-station-#{url.substring url.length - 36}.m3u").on 'finish', ->
        console.log '\n'
        console.log '\n'
        console.log 'all dumb!'

  loadStations: ->
    request 'http://localhost:9999/get_all_stations?format=text', (err, res, body) =>
      return @events.emit 'error', err if err or res.statusCode isnt 200
      lines = body.split '\n'
      names = []
      for line in lines
        l = line.split '|'
        names.push l[0]
        @stations[l[0]] = l[1]
      @setItems names

module.exports = Stations
