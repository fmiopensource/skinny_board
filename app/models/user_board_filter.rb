require 'yaml'

class UserBoardFilter < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  def self.add_story_filter(story_id, user_id, is_open, board_id)
    is_open = is_open.to_bool if is_open.is_a?(String)
    add_new_filter(board_id, user_id, story_id, :closed_stories, is_open)
  end

  def self.add_status_filter(status_id, user_id, board_id, is_open)
    is_open = is_open.to_bool if is_open.is_a?(String)
    add_new_filter(board_id, user_id, status_id, :closed_columns, is_open)
  end

  def self.add_text_filter(text, user_id, board_id)
    update_filter(user_id, board_id, :text_filter, text)
  end

  def self.update_viewed_boards(user_id, board_id, viewed_boards)
    update_filter(user_id, board_id, :viewed_boards, viewed_boards)
  end

  def closed_stories
    hash_getter(:closed_stories)
  end

  def closed_columns
    hash_getter(:closed_columns)
  end

  def text_filter
    hash_getter(:text_filter)
  end

  def viewed_boards
    hash_getter(:viewed_boards)
  end

private
  def hash_getter(key)
    return {} if self.filters.nil?
    begin
      hash = YAML::load( self.filters )
      return {} if hash[key].nil?
      hash[key]
    rescue
      return {}
    end
  end

  def self.add_new_filter(board_id, user_id, id_to_save, key, is_open)
    ub_filter = UserBoardFilter.find_or_create_by_board_id_and_user_id(board_id, user_id)
    filter = get_filters(ub_filter)
    # Since the default state is "Open", only have records for the "Closed" state
    filter = set_state(filter, key, id_to_save, is_open)
    save_filter(ub_filter, filter)
  end

  def self.get_filters(ub_filter)
    if ub_filter.filters.blank?
      filter = { :closed_stories => {}, :closed_columns => {}, :text_filter => '', :viewed_boards => [] }
    else
      filter = YAML::load( ub_filter.filters )
    end
    return filter
  end

  def self.set_state(hash, key, id, is_open)
    id = id.to_s
     if is_open
      hash[key].delete(id)
    else
      hash[key][id] = 1
    end
    hash
  end

  def self.update_filter(user_id, board_id, key, value)
    ub_filter = UserBoardFilter.find_or_create_by_board_id_and_user_id(board_id, user_id)
    filter = get_filters(ub_filter)
    filter[key] = value
    save_filter(ub_filter, filter)
  end

  def self.save_filter(ub_filter, filter)
    ub_filter.filters = filter.to_yaml
    ub_filter.save
    return filter
  end
end