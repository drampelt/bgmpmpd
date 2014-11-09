mpd = require 'mpd'
cmd = mpd.cmd

Model = require './models/model'
Status = require './models/status'

class MPDBridge
  constructor: (@events) ->
    @client = null
    @events.on 'mpd-connect', => @connect.apply @, arguments
    @events.on 'mpd-get-song', => @getCurrentSong.apply @, arguments
    @events.on 'mpd-vol', => @changeVol.apply @, arguments
    @events.on 'mpd-seekcur', => @seekCur.apply @, arguments
    @events.on 'mpd-play', => @play.apply @, arguments
    @events.on 'mpd-pause', => @pause.apply @, arguments
    @events.on 'mpd-toggle', => @toggle.apply @, arguments
    @events.on 'mpd-playlistinfo', => @playlistInfo.apply @, arguments
    @status = {}
    @song = {}

  connect: (host, port) ->
    @client = mpd.connect host: host, port: port unless @connected()
    @client.on 'ready', =>
      @events.emit 'mpd-connected'
      @getStatus.apply @, arguments
      setInterval =>
        @getStatus()
      , 1000
    @client.on 'system-player', =>
      @getStatus.apply @, arguments
      @getCurrentSong.apply @, arguments
    @client.on 'system-mixer', =>
      @getStatus.apply @, arguments
    @client.on 'system-options', => @getStatus.apply @, arguments

  connected: ->
    @client? and @client.socket.readable and @client.socket.writable and not @client.socket.destroyed

  getStatus: ->
    return unless @connected()
    @client.sendCommand cmd('status', []), (err, msg) =>
      @events.emit 'error', err if err
      @status = new Status().parse msg
      @events.emit 'mpd-status', @status

  getCurrentSong: ->
    return unless @connected()
    @client.sendCommand cmd('currentsong', []), (err, msg) =>
      @events.emit 'error', err if err
      @song = new Model().parse msg
      @events.emit 'mpd-song', @song

  changeVol: (amount) ->
    return unless @connected()
    vol = @status.volume
    vol += amount
    return if isNaN vol
    vol = 100 if vol > 100
    vol = 0 if vol < 0
    @client.sendCommand cmd('setvol', [vol.toString(10)]), (err, msg) =>
      @events.emit 'error', err if err

  # TODO: this doesn't seem to be working
  seekCur: (pos) ->
    return unless @connected()
    @client.sendCommand cmd('seekcur', [pos]), (err, msg) =>
      @events.emit 'error', err if err

  play: ->
    @client.sendCommand cmd('pause', [0]), (err, msg) =>
      @events.emit 'error', err if err

  pause: ->
    @client.sendCommand cmd('pause', [1]), (err, msg) =>
      @events.emit 'error', err if err

  toggle: ->
    if @status.playing then @pause() else @play()

  playlistInfo: ->
    @client.sendCommand cmd('playlistinfo', []), (err, msg) =>
      @events.emit 'error', err if err
      console.log msg


module.exports = MPDBridge
