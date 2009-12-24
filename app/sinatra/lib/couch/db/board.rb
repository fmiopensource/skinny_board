module Couch
  module DB

    def get_boards
      # get the boards
      data = RestClient.get "#{server}/_design/boards/_view/current_by_updated_at?startkey=[#{current_user}]&endkey=[#{current_user},%7B%7D]"
      boards = JSON.parse(data)["rows"].reverse! # this is needed since the list is sorted the wrong way but breaks with descending=true

      # small hack - map functions don't return an '_id' so we manually inject
      boards.each do |board|
        board.merge!('_id' => board.id)
      end
      return boards
    end

    def get_board_metric(id)
      data = RestClient.get "#{server}/_design/boards/_view/current_hours_by_id?group=true&startkey=[%22#{id}%22]&endkey=[%22#{id}%22,%7B%7D]&group_level=1"
      JSON.parse(data)["rows"].first["value"]
    end

    def get_board(id, options={})
      options[:with_history] ||= false

      board = nil
      begin
        board = get_doc(id)
      rescue
        # eat it - its already nil
      end


      # TODO - refactor history out of here, belongs 1 level up
      # in the controller - this should only get the board

      begin
        if options[:with_history]
          board["history"] = get_board_history(board.parent_id)
        else
          # explicitly clear history, because it's an attribute of board docs,
          # and, so, is fetched with an ordinary get_doc
          board.delete("history")
        end
      rescue
        # eat it
      end

      # badge
      # TODO - badge here is kind of dumb, refactor it to somewhere
#      board["value"] = {
#        "title" => board.title,
#        "description" => board.description,
#        "hours" => board.hours,
#        "story_points" => board.story_points,
#        "start_date" => board.start_date,
#        "end_date" => board.end_date,
#        "updated_at" => board.updated_at,
#        "level" => board.level
#      } unless board.nil?

      return board
    end

    #
    # {"id":"#{old_id}","key":["#{head_id}",#{unix_time_updated_at}],"value":null},
    #
    def get_board_history(id)
      data = RestClient.get "#{server}/_design/boards/_view/history_by_updated_at?startkey=[%22#{id}%22,%7B%7D]&endkey=[%22#{id}%22]&descending=true"
      JSON.parse(data)["rows"]
    end

    def get_board_revision(id)
      data = RestClient.get "#{server}/_design/boards/_view/latest_revision?key=%22#{id}%22"
      rows = JSON.parse(data)["rows"]
      rows.empty? ? [] : rows.first["value"]
    end

    def get_burndown_points(id, updated_at)
      date = Date.parse(updated_at)
      # javascript uses base 0 month, ruby uses base 1 so -1
      data = RestClient.get "#{server}/_design/boards/_view/burndown?group=true&startkey=[%22#{id}%22]&endkey=[%22#{id}%22,#{date.year},#{date.month-1},#{date.day}]"
      JSON.parse(data)["rows"]
    end

    def save_board(board, options={})
      options[:no_copy] ||= false

      if board["_id"].nil?
        board["parent_id"] = board["_id"] = get_uuids.first
      elsif !options[:no_copy]
        data = copy_doc(board, (options[:copy_id] || get_uuids.first))
      end

      board.merge!("id" => board["_id"])
      save_doc(board, data)
    end

  end
end
