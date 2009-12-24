module ActsAsBurndown
  # Generates burndown image
  def render_image(type, board_id, data, trend_data, start_date, end_date, options={})
    if type == 'profitBurndown'
      title = 'Profit Burndown'
      data_title = 'Daily Profit Estimate'
      trend_title = 'Expected Total Profit'
    else
      title = 'Burndown'
      data_title = 'Actual'
      trend_title = 'Trend'
    end
    format = options.has_key?(:format) ? options[:format] : 'gif'

    g = Gruff::Line.new
    g.title = title
    g.data(data_title, data)
    g.data(trend_title, trend_data) unless trend_data.blank?
    g.marker_font_size = 16  
    g.title_font_size = 20
    g.y_axis_label = type == "backlogBurndown" ? "Story Points" : "Hours"
    g.x_axis_label = "Date"
     
    g.minimum_value = 0
    g.theme_skinnyboard
    
    (start_date..end_date).each_with_index do |date, i|
      g.labels[i] = date.strftime("%m/%d")
    end
    file_name = "/images/burndowns/#{type}_#{board_id}.#{format}"
    g.write("public" + file_name)
    file_name
  end
end