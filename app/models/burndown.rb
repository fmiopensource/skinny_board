class Burndown < BaseBurndown
  attr_reader   :max_hours

  def generate(hours_per_day=nil)
    @data = hours_per_day.nil? ?
      get_hours_per_day.sort.map{|h| h[1]} :
      fill_in_blanks(hours_per_day).sort.map{|h| h[1]}

    make_line_of_best_fit
    @file_name = render_image('Burndown', @element.id, @data, @trend_data, @start_date, end_date)
  end

  def get_hours_per_day
    hours_per_day, sorted_dates = dates_and_hours_or_story_points_hash
    @start_date = @element.board_start_date || sorted_dates.first
    @last_date = sorted_dates.last || @start_date
    return fill_in_blanks(hours_per_day)
  end

  def end_date
    if @end_date.nil?
      date = @element.end_date.nil? ? @start_date + 14.days : @element.end_date.to_date
      @last_date ||= Date.today
      @end_date = [date, @last_date].max
    end
    @end_date
  end

  def total_days
    (end_date - @start_date).to_i
  end

end
