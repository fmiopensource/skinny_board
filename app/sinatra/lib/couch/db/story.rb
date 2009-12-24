module Couch
  module DB

    def get_story(board_id, story_id)
      data = RestClient.get "#{server}/_design/stories/_view/current_by_board_id?key=[%22#{board_id}%22,%22#{story_id}%22]"
      rows = JSON.parse(data)["rows"]
      rows.empty? ? nil : rows[0]["value"]
    end

    #returns stories for board_id. Returns {":id"=>story_obj, etc...}
    def get_stories(board_id)
      data = RestClient.get "#{server}/_design/stories/_view/current_by_story_id?startkey=[%22#{board_id}%22]&endkey=[%22#{board_id}%22,%7B%7D]"
      stories = JSON.parse(data)["rows"]

      returning Hash.new do |stories_hash|
        stories.collect{|story| stories_hash[story["value"][0]]=story["value"][1]}
      end
    end

  end
end