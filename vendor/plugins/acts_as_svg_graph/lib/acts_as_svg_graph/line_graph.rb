module ActsAsSvgGraph
  class LineGraph
    include TagHelper

    # Required attributes
    attr_accessor :data
    # Optional attributes
    attr_writer :include_trend_line, :y_axis_lines, :form_width, :form_height,
                :legend_width, :title
    attr_reader :svg
    attr        :labels, true
    def include_trend_line
      @include_trend_line = true unless defined? @include_trend_line
      @include_trend_line
    end
    def y_axis_lines
      @y_axis_lines ||= 9
    end
    def form_width
      @form_width ||= 480
    end
    def form_height
      @form_height ||= 320
    end
    def graph_width
      form_width - legend_width - 20 # 20 = buffer
    end
    def graph_height
      form_height - 60 # 60 = title + buffer
    end
    def legend_width
      @legend_width ||= 80
    end
    def legend_height
      items = @data.length
      (items*10) + ((items+1)*5)
    end
    def title
      @title ||= 'Line Graph'
    end

    def initialize
      @data = []
    end

    def add(label, data, color='blue')
      @data << DataSet.new(label, data, color)
    end

    def data_point_count
      cnt = 0
      @data.each { |dataset| cnt = [cnt, dataset.data.length].max }
      [cnt, labels.length].max
    end

    def max_value
      return @max unless @max.nil? or @max.zero?
      @max = 0
      @data.each do |dataset|
        dataset.data.each do |datum|
          @max = [datum, @max].max
        end
      end
      @max
    end

    def to_svg(include_trend_line=false, trend_line_color='red')
      @svg = ''

      calculate_trend(trend_line_color) if include_trend_line

      @svg += svg_tag do
        draw_title(title)
        draw_vertical_gradiant('sb_gradient', '207,232,239', '251,254,254')
        g(:id => "lineChart", :transform => "translate(20, 25)") do
          draw_grid_and_legend
          draw_labels
          draw_data_points
        end
      end
    end

  protected
    def calculate_trend(color)
      # Forumla taken from:
      # http://people.hofstra.edu/stefan_waner/realworld/calctopic1/regression.html
      return [] if @data.empty?
      # The formula for a line of best fit is
      #    y = mx + b
      # where
      #    m = (n(Σxy) - (Σx)(Σy)) / (n(Σx^2) - Σ(x)^2)
      #    b = Σy - m(Σx) / n
      # Remember, Σ (sigma) is 'sum of,' m is 'slope,' and b is the y-intercept.
      #
      # 1.  Set up variables
      n = data_point_count
      sigma_xy = 0.0
      sigma_x = 0.0
      sigma_y = 0.0
      sigma_x_squared = 0.0

      @data.each do |dataset|
        dataset.data.each_with_index do |y, index|
          x = index + 1
          sigma_xy += (x*y)
          sigma_x += x
          sigma_y += y
          sigma_x_squared += x**2
        end
      end

      # Now that we have our numbers, we can do our calculations
      m = (n*sigma_xy - sigma_x*sigma_y) / (n*(sigma_x_squared) - sigma_x**2)
      b = (sigma_y - m*sigma_x) / n

      # We've calculated m and b, let's fill in the points for our trend line
      #start_date = data.first[0]
      trend_data = Array.new
      data_point_count.times do |i|
        x = i + 1
        y = m*x + b
        y = 0.0 if y.nan?
        y = [y, 0.0].max
        trend_data << y.round(3)
      end
      add('Trend', trend_data, color)
    end
  end
end