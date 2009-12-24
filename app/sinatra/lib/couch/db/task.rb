module Couch
  module DB

    def get_task(board_id, story_id, task_id)
      data = RestClient.get "#{server}/_design/tasks/_view/current_by_board_id_story_id?key=[%22#{board_id}%22,%22#{story_id}%22,%22#{task_id}%22]"
      rows = JSON.parse(data)["rows"]
      rows.empty? ? nil : rows[0]["value"]
    end
  
  end
end
