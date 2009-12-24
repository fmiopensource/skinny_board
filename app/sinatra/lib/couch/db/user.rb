module Couch
  module DB
    def get_users(board_id)
      data = RestClient.get "#{server}/_design/users/_view/allowed_by_board_id?key=%22#{board_id}%22"
      rows = JSON.parse(data)["rows"]
      rows.empty? ? [] : rows[0]["value"]
    end

    # this could make use of caching here, or on the server with an etag but for now do it each
    # time. optimize later, not first!
    def board_user_authorized?(board_id, user_id=current_user)
      data = RestClient.get "#{server}/_design/boards/_view/current_by_updated_at?startkey=[#{user_id},%22#{board_id}%22]&endkey=[#{user_id},%22#{board_id}%22,%7B%7D]"
      JSON.parse(data)["rows"].length != 0 # parse could be removed for speed, but then depends on string structure
    end
    end
end