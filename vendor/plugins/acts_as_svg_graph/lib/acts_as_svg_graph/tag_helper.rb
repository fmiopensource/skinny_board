# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

module ActsAsSvgGraph
  module TagHelper
    attr :tags_to_close, true
    attr :last_point, true

    def clear_last_point
      @last_point = nil
    end

    def svg_tag
      make_tag(:svg, :xmlns => "http://www.w3.org/2000/svg", 
        'xmlns:xlink' => "http://www.w3.org/1999/xlink",  :id => "body",
        'xml:space' => "preserve", :viewBox => "0 0 #{form_width} #{form_height}")
      yield
      close_tag
    end

    def draw_title(the_title)
      make_tag(:title, {}, the_title, true)
      g(:transform => "translate(#{form_width/2}, 20)") do
        x = (form_width / 2.to_f * -1)
        rect(x, -10, form_width, 20, {:fill => "none"})
        text(the_title, {'text-anchor' => "middle", 'dominant-baseline' => "mathematical"})
      end
    end

    def draw_vertical_gradiant(id, start_color, stop_color)
      make_tag :defs
        make_tag :linearGradient, {:id => id, :x1 => "0%", :y1 => "0%", :x2 => "0%", :y2 => "100%"}
          make_tag :stop, {:offset => "0%", :style => "stop-color:rgb(#{start_color}); stop-opacity:1"}, '', true
          make_tag :stop, {:offset => "100%", :style => "stop-color:rgb(#{stop_color}); stop-opacity:1"}, '', true
        close_tag    
      close_tag
    end

    def y_gridline_helper
      y_axis_lines.times do |i|
        y = i * (graph_height.to_f/(y_axis_lines-1).to_f)
        horizontal_line(0, y, graph_width)
      end
    end

    def x_gridline_helper
      ticks = data_point_count
      y = graph_height

      ticks.times do |i|
        x = i * (graph_width.to_f / (ticks.to_f)) + 20.0 # 20 = The buffer from the origin
        vertical_line(x.round(3), y, 5)
      end
    end

    def draw_grid_and_legend
      g(:id => "GridAndLegend", :style => "stroke:none;") do
        draw_grid
        draw_legend
      end
    end

    def draw_labels
      g(:style => "font-size: 10px") do
        x_axis_label_helper
        y_axis_label_helper
      end
    end

    def draw_grid
      g(:stroke => 'black') do
        # Make the background
        rect(0, 0, graph_width, graph_height, :fill => 'url(#sb_gradient)', :stroke => 'black')
        y_gridline_helper
        x_gridline_helper
      end
    end

    def draw_legend
      x = graph_width + 10
      y = (graph_height - legend_height) / 2
      g(:style => "font-size: 10px", :transform => "translate(#{x}, #{y})", :stroke => 'black') do
        draw_legend_background
        draw_legend_items
      end
    end

    def draw_legend_background
      rect(0, 0, legend_width-10, legend_height, :fill => 'lightgray')
    end

    def draw_legend_items
      items = ''
      @data.each_with_index do |dataset, index|
        items += draw_legend_item(dataset.label, dataset.color, index)
      end
      items
    end

    def draw_legend_item(label, color, index)
      x = 5
      y = 15 * index + 5
      item = rect(x, y, 10, 10, :fill => color)
      x += 15
      y += 8
      item += text(label, {:x => x, :y => y, :stroke => 'none'})
    end

    def x_axis_label_helper
      y = graph_height + 12

      labels.each_with_index do |label, i|
        x = i * ((graph_width-20).to_f / (data_point_count - 1).to_f) + 23
        text(label, 'text-anchor' => 'end', :transform => "translate(#{x}, #{y}) rotate(315)")
      end
    end

    def y_axis_label_helper
      lines = y_axis_lines
      less_lines = lines - 1

      lines.times do |i|
        y_value = (max_value / less_lines.to_f * (less_lines - i)).to_i
        x = (lines * -1) - y_value.to_s.length * 4.5 # String-length fix.  Bigger strings need more space
        y = i * (graph_height / less_lines.to_f) + 3    # +3 to align the text with the lines properly
        text(y_value, :transform => "translate(#{x}, #{y})")
      end
    end

    def draw_data_points
      @data.each do |dataset|
        g(:stroke => dataset.color, :fill => dataset.color, 'stroke-width' => "2") do
          clear_last_point
          dataset.data.each_with_index { |datum, i| data_point_helper(datum, i) }
        end
      end
    end

    def data_point_helper(value, index)
      number_of_ticks = data_point_count
      ratio = value / max_value.to_f
      y = graph_height - (ratio * graph_height)
      x = index * (graph_width / (number_of_ticks.to_f)) + 20 # 20 = The buffer from the origin
      unless @last_point.nil?
        connect_line(x, y)
      end
      @last_point = [x, y]
      circle(x, y, 3)
    end

    def connect_line(x, y)
      path("M #{@last_point[0]} #{@last_point[1]} L #{x} #{y}")
    end

    ###########################
    # Tags be below this line #
    ###########################

    def g(options={})
      make_tag(:g, options)
      yield
      close_tag
    end

    def rect(x, y, w, h, options={})
      defaults = { :x => x, :y => y, :width => w, :height => h }
      options = defaults.merge(options)
      make_tag(:rect, options, '', true)
    end

    def horizontal_line(start_x=0, start_y=0, distance=0)
      d = path_vars(start_x, start_y, distance)
      path(d)
    end

    def vertical_line(start_x=0, start_y=0, distance=0)
      d = path_vars(start_x, start_y, distance).gsub(/ h /, ' v ')
      path(d)
    end

    def path(d)
      make_tag(:path, {:d => d}, '', true)
    end

    def text(text, options={})
      make_tag(:text, options, text, true)
    end

    def circle(x, y, r)
      defaults = { :cx => x, :cy => y, :r => r }
      make_tag(:circle, defaults, '', true)
    end

  private
    def make_tag(name, attrs={}, inner_html='', close=false)
      @svg ||= ''
      name = name.to_s
      attrs.stringify_keys!
      tag = "<#{name}"
      attrs.each do |key, value|
        tag += " #{key}=\"#{value}\""
      end
      if close
        if inner_html.blank?
          tag += "/>"
        else
          tag += ">#{inner_html}</#{name}>"
        end
      else
        tag += ">#{inner_html}"
        @tags_to_close ||= []
        @tags_to_close << name
      end
      @svg += tag
      return tag
    end

    def close_tag
      @svg += "</#{@tags_to_close.pop}>"
    end

    def path_vars(x, y, d)
      "M #{x},#{y} h #{d}"
    end
  end

end
