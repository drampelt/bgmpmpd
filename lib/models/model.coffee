class Model
  # Default parsing method assuming @data is a key:value list
  parse: (data) ->
    for row in data.split '\n'
      if (pos = row.indexOf(':')) >= 0
        key = row.substring 0, pos
        val = row.substring (pos + 1), row.length
        val = val.trim()
        if @attributes and (type = @attributes[key])
          switch type
            when 'int'
              val = parseInt val, 10
            when 'float'
              val = parseFloat val
            when 'bool'
              val = val is '1'
        @[key.trim()] = val
    @

module.exports = Model
