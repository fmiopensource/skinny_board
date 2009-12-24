class Gruff::Base
  def draw_label(x_offset, index)
      return if @hide_line_markers
      if !@labels[index].nil? && @labels_seen[index].nil?
        y_offset = @graph_bottom + LABEL_MARGIN
        @d.fill = @font_color
        @d.font = @font if @font
        @d.stroke('transparent')
        @d.font_weight = NormalWeight
        @d.pointsize = 14
        @d.gravity = CenterGravity
        @d.rotation = -45
        @d = @d.annotate_scaled(@base_image,
          1.0, 1.0,
          (x_offset-20), (y_offset+15),
          @labels[index], @scale)
        @d.rotation = 45
        @labels_seen[index] = 1
        debug { @d.line 0.0, y_offset, @raw_columns, y_offset }
      end
    end


def theme_skinnyboard
# Colors
@green = '#E0F6DD'
@purple = '#cc99cc'
@blue = '#434343'
@yellow = '#F8FFC8'
@red = '#ff0000'
@orange = '#cf5910'
@black = '#4C4C4C'

@colors = [@yellow, @blue, @green, @red, @purple, @orange, @black]
self.theme = {
:colors => @colors,
:marker_color => '#CCCCCC',
:font_size => '12',
:font_color => '#333333',
:background_colors => ['#EEEEEE', 'white']
}
end

end
