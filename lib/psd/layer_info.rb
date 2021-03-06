class PSD
  # Parent class for all of the extra layer info.
  class LayerInfo
    attr_reader :data

    def initialize(layer, length)
      @layer = layer
      @file = layer.file
      @length = length
      @section_end = @file.tell + @length
      @data = {}
    end

    def skip
      @file.seek @section_end
    end

    # Override this - default seeks to end of section
    def parse
      skip
    end
  end
end