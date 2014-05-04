{Module} = require 'coffeescript-module'

module.exports = class Layer extends Module
  @includes require('./layer/position_channels.coffee')
  @includes require('./layer/blend_modes.coffee')
  @includes require('./layer/mask.coffee')
  @includes require('./layer/blending_ranges.coffee')
  @includes require('./layer/name.coffee')
  @includes require('./layer/info.coffee')
  @includes require('./layer/helpers.coffee')
  # @includes require('./layer/channel_image.coffee')

  constructor: (@file, @header) ->
    @mask = {}
    @blendingRanges = {}
    @adjustments = {}
    @channelsInfo = []
    @blendMode = {}
    @groupLayer = null

    @infoKeys = []

    Object.defineProperty @, 'name',
      get: ->
        if @adjustments['name']?
          @adjustments['name'].data
        else
          @legacyName

  parse: ->
    @parsePositionAndChannels()
    @parseBlendModes()

    extraLen = @file.readInt()
    @layerEnd = @file.tell() + extraLen

    @parseMaskData()
    @parseBlendingRanges()
    @parseLegacyLayerName()
    @parseLayerInfo()

    @file.seek @layerEnd
    return @

  export: ->
    name: @name
    top: @top
    right: @right
    bottom: @bottom
    left: @left
    width: @width
    height: @height
    opacity: @opacity
    visible: @visible
    clipped: @clipped
    mask: @mask.export()