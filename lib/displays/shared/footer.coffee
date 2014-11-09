blessed = require 'blessed'
class Footer extends blessed.box
  constructor: (@events, @mpd, @blessed, options) ->
    super options

    @song = @blessed.text
      top: 1
      left: 0
      width: '80%'
      height: 1
      content: 'Song name'
      align: 'left'
      # style: hover: bg: 'green'
    @append @song

    @progressText = @blessed.text
      top: 1
      left: '80%'
      width: '20%'
      height: 1
      content: '100%'
      align: 'right'
      # style: hover: bg: 'green'
    @append @progressText

    @progress = @blessed.progressbar
      top: 0
      left: 0
      width: '100%'
      height: 1
      orientation: 'horizontal'
      filled: 75
      style: bar: bg: 'green'
    @append @progress

    @events.on 'mpd-song', =>
      # console.log @mpd.status
      @updateSong.apply @, arguments
    @events.on 'mpd-status', => @updateSong.apply @, arguments

    @on 'wheeldown', => @events.emit 'mpd-seekcur', '+2'
    @on 'wheelup', => @events.emit 'mpd-seekcur', '-2'
    @on 'mouseup', => @events.emit 'mpd-toggle'

  updateSong:  ->
    @song.setText "[#{@mpd.status.state}] #{@mpd.song.Artist} - #{@mpd.song.Title}"
    @progressText.setText "[#{@mpd.status.time?.string}]"
    @progress.setProgress @mpd.status.time.percent if @mpd.status.time?
    @events.emit 'render'

module.exports = Footer
