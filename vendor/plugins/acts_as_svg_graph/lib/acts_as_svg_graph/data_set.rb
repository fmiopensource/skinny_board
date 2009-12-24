module ActsAsSvgGraph
  class DataSet
    attr_accessor :label, :data, :color

    def initialize(label, data, color)
      @label = label
      @data = data
      @color = color
    end
  end
end
