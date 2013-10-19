class PSD
  # Represents a single layer and all of the data associated with
  # that layer.
  class Layer
    include Section
    include BlendModes
    include BlendingRanges
    include ChannelImage
    include Exporting
    include Helpers
    include Info
    include Mask
    include Name
    include PathComponents
    include PositionAndChannels

    attr_reader :id, :mask, :blending_ranges, :adjustments, :channels_info
    attr_reader :blend_mode, :layer_type, :blending_mode, :opacity, :fill_opacity
    attr_reader :channels, :image

    attr_accessor :group_layer
    attr_accessor :top, :left, :bottom, :right, :rows, :cols, :ref_x, :ref_y, :node, :file

    alias :info :adjustments
    alias :width :cols
    alias :height :rows

    # Initializes all of the defaults for the layer.
    def initialize(file)
      @file = file
      @image = nil
      @mask = {}
      @blending_ranges = {}
      @adjustments = {}
      @channels_info = []
      @blend_mode = {}
      @group_layer = nil

      @layer_type = 'normal'
      @blending_mode = 'normal'
      @opacity = 255
      @fill_opacity = 255

      # Just used for tracking which layer adjustments we're parsing.
      # Not essential.
      @info_keys = []
    end

    # Parse the layer and all of it's sub-sections.
    def parse(index=nil)
      start_section

      @id = index

      parse_info
      parse_blend_modes

      extra_len = @file.read_int
      @layer_end = @file.tell + extra_len

      parse_mask_data
      parse_blending_ranges
      parse_legacy_layer_name
      parse_extra_data

      PSD.logger.debug "Layer name = #{name}"

      @file.seek @layer_end # Skip over any filler zeros

      end_section
      return self
    end

    # We just delegate this to a normal method call.
    def [](val)
      self.send(val)
    end

    # We delegate all missing method calls to the extra layer info to make it easier
    # to access that data.
    def method_missing(method, *args, &block)
      return @adjustments[method] if @adjustments.has_key?(method)
      super
    end
  end
end