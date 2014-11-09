Model = require './model'
class Status extends Model
  attributes:
    repeat: 'bool'
    random: 'bool'
    single: 'bool'
    consume: 'bool'
    volume: 'int'
    playlist: 'int'
    playlistlength: 'int'
    song: 'int'
    songid: 'int'
    bitrate: 'int'
    nextsong: 'int'
    nextsongid: 'int'

  parse: (data) ->
    super data

    if @time?
      ta = @time.split ':'
      @time =
        current: parseInt ta[0], 10
        total: parseInt ta[1], 10
      @time.string = "#{@toTime @time.current}/#{@toTime @time.total}"
      @time.percent = 100 * @time.current / @time.total

    @playing = @state is 'play'
    @

  toTime: (sec) ->
    "#{Math.floor(sec / 60)}:#{@pad(sec % 60, 2)}"

  pad: (n, width, z) ->
    z = z or '0'
    n = n + ''
    if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

module.exports = Status
