class BaseBurndown
  include ActsAsBurndown
  require 'gruff'
  require 'lib/gruff/base.rb'
  attr_accessor :element, :data, :file_name, :start_date, :format, :last_date, :end_date
  attr_reader   :trend_data

  def initialize(attributes={})
    unless attributes.has_key?(:element)
      raise ArgumentError.new("Please provide a board.")
    end

    @format = 'gif' unless attributes.has_key?(:format)
    # Defaults
    FileUtils.mkdir_p 'public/images/burndowns'
    @trend_data = []
    set_attributes(attributes)
  end

  def make_line_of_best_fit
    # Forumla taken from:
    # http://people.hofstra.edu/stefan_waner/realworld/calctopic1/regression.html
    return [] if @data.empty? || @data.length <= 1

    m, b = calculate_m_and_b

    # We've calculated m and b, let's fill in the points for our trend line
    @trend_data = Array.new
    @trend_data << m + b
    if will_be_below_zero?(total_days, m, b)
      add_trendline_to_zero(total_days, m, b)
    else
      add_trendline_to_end(total_days, m, b)
    end

    @trend_data
  end

  def will_be_below_zero?(total_days, m, b)
    y = m*(total_days) + b
    y < 0.0
  end

  def labels
    returning [] do |labels|
      (@start_date..end_date).each do |date|
        labels << date.strftime("%m/%d")
      end
    end
  end

private
  def set_attributes(attributes)
    unless attributes == nil
      attributes.each do |key, value|
        begin
          method_name = "#{key}="
          send method_name, value
        rescue
          raise ArgumentError.new("The attribute '#{key}' is invalid.")
        end
      end
    end
  end

  def add_trendline_to_zero(total_days, m, b)
    2.upto(total_days + 1) do |x|
      y = m*x + b
      if y < 0
        @trend_data << 0.0
        break
      else
        @trend_data << y
      end
    end
  end

  def add_trendline_to_end(total_days, m, b)
    2.upto(total_days+1) do |i|
      @trend_data << m*i + b
    end
#    @trend_data << m*total_days + b
  end

  def calculate_m_and_b
    # The formula for a line of best fit is
    #    y = mx + b
    # where
    #    m = (n(Î£xy) - (Î£x)(Î£y)) / (n(Î£x^2) - Î£(x)^2)
    #    b = Î£y - m(Î£x) / n
    # Remember, Î£ (sigma) is 'sum of,' m is 'slope,' and b is the y-intercept.
    #
    # Set up variables
    n = @data.length
    sigma_xy = 0.0
    sigma_x = 0.0
    sigma_y = 0.0
    sigma_x_squared = 0.0


    # Calculate all the sums
    @data.each_with_index do |y, index|
      @max_hours = y if @max_hours.nil? or @max_hours < y
      x = index + 1
      sigma_xy += (x*y)
      sigma_x += x
      sigma_y += y
      sigma_x_squared += x**2
    end

    # Now that we have our numbers, we can do our calculations
    m = (n*sigma_xy - sigma_x*sigma_y) / (n*(sigma_x_squared) - sigma_x**2)
    b = (sigma_y - m*sigma_x) / n


    return [m, b]
  end

  def is_backlog?
    element.is_product_backlog?
  end

  def dates_and_hours_or_story_points_hash
    hours_or_points_per_day = {}
    caches = StoryAndHourCache.find(:all, :conditions => ["element_id = ? and updated_on <= ?", element.id, DateTime.now])
    unless caches.blank?
      caches.each do |cache|
        hours_or_points_per_day[cache.updated_on] = is_backlog? ? cache.story_points : cache.hours
      end
    end
    return hours_or_points_per_day, hours_or_points_per_day.keys.sort
  end

  def fill_in_blanks(hash)
    return {} if hash.blank?
    date = @start_date
    until date > @last_date
      hash.merge!({date => (hash[date - 1] || 0.0)}) if hash[date].nil?
      date += 1.day
    end
    return hash
  end
end
