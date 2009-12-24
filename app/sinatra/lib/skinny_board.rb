# To change this template, choose Tools | Templates
# and open the template in the editor.

module SkinnyBoard
  module Boards
    def new_element()
      now = Time.now.strftime("%Y/%m/%d %H:%M:%S %z")
      return {
        "created_at"  => now,
        "updated_at"  => now,
        "creator_id"  => current_user,
        "parked"      => false
      }
    end

    def new_board(element)
      board = new_element
      board.merge!({
          "story_points"  => 0,
          "hours"         => 0,
          "level"         => element.level.to_i,
          "title"         => element.title,
          "description"   => element.description,
          "stories"       => [],
          "start_date"    => element.start_date,
          "end_date"      => element.end_date,
          "users"         => element.users,
          "is_public"     => element.is_public,
          "twitter"       => element.twitter
        })

      if board.level == LEVEL_PRODUCT_BACKLOG
        board.merge!({
            "board_ids" => []
          })
      end
      board
    end

    def new_story(board_id, element)
      new_element.merge({
          "story_points"  => hours_points_converter(element.story_points),
          "parent_id"     => board_id,
          "board_id"      => board_id,
          "level"         => LEVEL_STORY,
          "status_id"     => STATUS_ACTIVE,
          "title"         => element.title,
          "description"   => element.description,
          "tag_list"      => element.tag_list,
          "position"      => element.position,
          "hours"         => 0
        })
    end

    def new_task(board_id, story_id, element)
      new_element.merge({
          "hours"       => hours_points_converter(element.hours),
          "parent_id"   => story_id,
          "board_id"    => board_id,
          "level"       => LEVEL_TASK,
          "status_id"   => STATUS_TODO,
          "description" => element.description,
          "tag_list"    => element.tag_list,
          "position"    => element.position,
          "users"       => element.users
        })
    end

    def create_board(params)
      params["level"] = params.level.to_i == 0 ? LEVEL_BOARD : LEVEL_PRODUCT_BACKLOG
      if params.level == LEVEL_PRODUCT_BACKLOG
        params["board_ids"] = []
      else
        params.delete("board_ids")
      end

      params["title"] = "My #{params.level == 0 ? 'Board' : 'Backlog'} - #{Time.now.strftime("%Y/%m/%d")}" if params.title.blank?

      # get the users - owner and current - use find_all to get arrays
      # which are easier to work with later and don't require error handling
      # use uniq to catch owner == current
      company = Company.find_all_by_id(current_company)
      users = User.find_all_by_id(current_user)
      users << company.first.owner unless company.empty?
      params["users"] = users.uniq.map{|u|{"id" => u.id, "name" => u.full_name}}

      params["is_public"] = params.is_public == "1"
      
      if params.twitter.nil?
        params["twitter"] = {"tweet" => false}
      else
        params["twitter"]["tweet"] = params.twitter.tweet == "1"
      end
      
      return new_board(params)
    end

    #
    # move _id assignment somewhere else -- this should just construct the
    # hash.  Assigning id could happen in a add_story_to_board function
    # higher up.  Otherwise you can get a db error creating the hash
    # -- same for _task
    #
    def create_story(board, params)
      params["position"] = board.stories.empty? ? 1 : board.stories.length + 1
      return new_story(board.id, params).merge({"id" => get_uuids.first})
    end

    def create_task(story, params)
      params["position"] = story.tasks.empty? ? 1 : story.tasks.length + 1
      creator = User.find(params["created_by"])
      change_doc = write_doc({"_id" => get_uuids.first,
          "changes" => ["#{creator.full_name} created this task #{Time.now.strftime("%Y/%m/%d %I:%M:%S %p")}"]})

      return new_task(story.board_id, story.id, params).merge({"id" => get_uuids.first, "change_doc_id" => change_doc.id})
    end

    def update_task(story, task_id, params)
      
      # this will need to be updatable after for story priority
      position = params.keys.include?("position") ? position.to_i : nil
      # find and update
      task = get_element(story.tasks, task_id, position)
      task.merge!({
          "updated_at"  => Time.now.strftime("%Y/%m/%d %H:%M:%S %z"),
          "updated_by"  => current_user
        })

      #duping here because we don't care that the updated_by/at changed
      old_task = task.dup

      # check what were passed and add it in
      {"hours" => ->(hours){hours_points_converter(hours)},
        "parked" => ->(parked){parked == "1" ? true : false},
        "description" => nil,
        "tag_list" => nil,
        "status_id" => ->(id){
          result = id.to_i
          result = 4 if result > 4
          result = 1 if result < 1
          return result
        },
        "users" => ->(users){ users},
        "position" => ->(p){p.to_i}
      }.each{|key, value| task[key] = value.nil? ? params[key] :
          value.call(params[key]) if params.keys.include?(key)}
        
      changes = []
      old_task.diff(task).keys.each do |key|
        if key == "status_id"
          changes << "status from #{STATUS_CODES[old_task[key]]} to #{STATUS_CODES[task[key]]}"
        elsif key == "users"
          changes << "users from #{extract_user_names(old_task[key])} to #{extract_user_names(task[key])}"
        else
          changes << "#{key.gsub(/_/, ' ')} from #{old_task[key].blank? ? "nothing" : old_task[key]} to #{task[key].blank? ? "nothing" : task[key]}"
        end
        
      end
      unless changes.blank?
        user = User.find(current_user)
        message = "#{user.full_name} changed #{changes.to_sentence} #{Time.now.strftime("%Y/%m/%d %I:%M:%S %p")}"

        # This nil check is for current tasks, that were not created with uuids
        # TODO - Remove this check when it becomes obsolete
        if task.change_doc_id.blank?
          change_doc = write_doc({"_id" => get_uuids.first, "changes" => ["Autogenerated change log #{Time.now.strftime("%Y/%m/%d %I:%M:%S %p")}"] })
          task["change_doc_id"] = change_doc["id"]
        end
        change_doc = get_doc(task.change_doc_id)
        change_doc.changes << message
        write_doc(change_doc)
      end

      return task
    end

    def extract_user_names(users)
      result = users.collect{|u| u["name"]}.to_sentence
      result.blank? ? "unassigned" : result

    end

    def update_story(board, story_id, params)
      # sanitize user inputs
      sanitized_params = {
        "position" => params.position.to_i,
        "story_points" => hours_points_converter(params.story_points),
        "updated_at" => Time.now.strftime("%Y/%m/%d %H:%M:%S %z"),
        "updated_by" => current_user || 0,
        "parked" => (params.parked == "1" ? true : false),
        "title" => params.title,
        "description" => params.description,
        "tag_list" => params.tag_list
      }

      # find and update
      story = get_element(board.stories, story_id, sanitized_params.position - 1)
      story.merge!(sanitized_params)
      # TODO - this should work like task so we dont get bad data

      return story
    end

    def board_edit(board, params)
      # sanitize user input
      sanitized_params = {
        "updated_at" => Time.now.strftime("%Y/%m/%d %H:%M:%S %z"),
        "updated_by" => current_user || 0,
        "title" => params.element.title.blank? ?
          "My #{params.level == 0 ? 'Board' : 'Backlog'} - #{Time.now.strftime("%Y/%m/%d")}" :
          params.element.title,
        "description" => params.element.description,
        "start_date" => params.element.start_date.blank? ? nil : Date.parse(params.element.start_date),
        "end_date" => params.element.end_date.blank? ? nil : Date.parse(params.element.end_date),
        "is_public" => params.element.is_public == "1" ? true : false,
        "twitter" => params.twitter.nil? ? nil : {
          "tweet" => params.twitter.tweet == "1" ? true : false,
          "username" => params.twitter.username,
          "password" => params.twitter.password
        }
      }
      # TODO - this should work like task so we dont get bad data
      board.merge(sanitized_params)
    end

    def get_element(container, id, index=nil)
      !index.nil? && index > -1 && index < container.length && container[index].id == id ?
        container[index] :
        container.select{|item| item.id == id }.first
    end

    def get_user_ids_from_users(users)
      return [] if users.blank?
      users.collect{|user| user.id}
    end

    def update_board(board, options={})
      options[:reindex] ||= false
      options[:add_up_tasks] ||= false
      options[:add_up_stories] ||= false
      options[:reindex_tasks] ||= false
      
      if options[:reindex] || options[:add_up_tasks] ||
          options[:add_up_stories] || options[:reindex_tasks]

        story_points = 0.0
        hours = 0.0

        board.stories.each_with_index do |story, i|
          story["position"] = (i + 1) if options[:reindex]

          if options[:add_up_stories]
            story_points += story.story_points 
          end unless (story.story_points.nil? || story.story_points <= 0)

          if options[:add_up_tasks] || options[:reindex_tasks]
            sum = 0.0

            story.tasks.each_with_index{|task, i|
              task["position"] = (i + 1) if options[:reindex_tasks]
              if options[:add_up_tasks]
                sum += task.hours
              end unless (task.hours.nil? || task.hours <= 0 || task.status_id == 4)
            } unless story.tasks.empty?
            
            if options[:add_up_tasks]
              story["hours"] = sum
              hours += sum
            end
          end
        end unless board.stories.empty?

        board["story_points"] = story_points if options[:add_up_stories]
        board["hours"] = hours if options[:add_up_tasks]
      end
      
      board["updated_at"] = Time.now.strftime("%Y/%m/%d %H:%M:%S %z")
      board["updated_by"] = current_user

      # remove the image, its no longer valid
      board["burndown_image_path"] = nil

      # save the board, capturing the new rev
      board["_rev"], success = save_board(board, :copy_id => options[:copy_id])

      return success
    end

    def get_burndown_image(board)

      # get the points
      rows = get_burndown_points(board.id, board.updated_at)
      points = flatten_points(rows) unless rows.empty?

      if rows.blank?
        board["burndown_image_path"] = BURNDOWN_NO_IMAGE
      else
        # make the dates
        key = rows[0]["key"]
        start_date = Date.parse(board.start_date.blank? ?
            "#{key[1]}/#{key[2] + 1}/#{key[3]}" : board.start_date)

        end_date = Date.parse(board.end_date) unless board.end_date.blank?

        # fake element - for now to reuse existing code - refactor out later
        element = SkinnyBoard::FakeElement.new(board.id, start_date, end_date)
        burndown = Burndown.new(:element => element,
          :start_date => start_date,
          :end_date => end_date, :last_date => end_date)

        # get the image - store the path
        board["burndown_image_path"] = burndown.generate(points)
        board["burndown_points"] = points
      end
        # save WITHOUT copy
        save_board(board, :no_copy => true)
    end

    #
    # {"key":["12594",2009,9,1],"value":{"hh":10,"mm":10,"ss":0,"hours":49.5}}
    # 
    def flatten_points(rows)
      returning Hash.new do |points|
        rows.each do |row|
          key = row["key"]
          date = Date.parse("#{key[1]}/#{key[2] + 1}/#{key[3]}")
          points[date] = row.value.hours
        end
      end
    end
    
    def reorder_stories(board)
      board.stories.each_with_index do |story, i|
        board["stories"][i]["position"] = i + 1
      end
    end

    def hours_points_converter(value)
      case value
      when "?" then -1
      when "*" then nil
      else value.to_f
      end
    end
  end # module Boards

  # Use to fake an old board for the burndown
  # should be removed when that code is refactored to work
  # with the new boards
  class FakeElement
    attr_accessor :id, :board_start_date, :end_date
    def initialize(id, start_date, end_date)
      @id = id
      @board_start_date = start_date
      @end_date = end_date
    end
    def is_product_backlog?
      false
    end
  end
end # module SkinnyBoard

