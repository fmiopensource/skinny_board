module SkinnyBoard
  module ProductBacklog
    def update_or_create_board(backlog, board={}, stories=[])
      new_board = board["_id"].nil?
      board_copy_id, backlog_copy_id = get_uuids(2)

      board = find_or_create_board(board, backlog)
      transfer_elements!(backlog, stories, board)
      update_board(board, {:copy_id => board_copy_id, :add_up_stories => true})
      backlog["boards"] ||= []
      backlog["boards"] << board["_id"] if new_board

      update_board(backlog, {:copy_id => backlog_copy_id, :add_up_stories => true})

      update_previous_backlog(backlog_copy_id, board["_id"], board_copy_id) unless new_board

      # update the board id for transferred stories
      board.stories.map! { |story|
        story.merge({ "board_id" => board["_id"], "parent_id" => board["_id"]})
      }
      save_board(board)

      return board_copy_id, backlog_copy_id, board
    end

    def update_previous_backlog(id, replace_board_id, with_board_id)
      backlog = get_board(id)
      unless backlog.nil?
        backlog["boards"] = replace_element(backlog["boards"], replace_board_id, with_board_id)
        save_doc(backlog, :no_copy => true)
      end
    end

    def replace_element(target, replace, with)
      index = target.index(replace)
      target[index] = with if index
      return target
    end

    def transfer_elements!(source, elements, destination, key="stories")
      destination ||= {}
      destination[key] ||=[]
      destination[key] += elements
      source[key] -= elements
    end

    def find_or_create_board(board={}, backlog=nil)
      if board["_id"].nil?
        board["title"] ||= "My Board - #{Time.now.strftime("%Y/%m/%d")}"
        board["level"] = LEVEL_BOARD

        # get attributes PB
        unless backlog.nil?
          board = backlog.merge(board)

          # get rid of ids from the PB - board needs its own
          %w(_id _rev stories boards).each{|attr| board.delete(attr)}
        end

        create_board(board)

        # restore the users keeping defaults if there are none
        board["users"] = backlog["users"] unless backlog.nil? || backlog["users"].nil?

        return board

      else
        get_board(board["_id"])

      end
    end
  end # ProductBacklog
end # SkinnyBoard
