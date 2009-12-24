module Couch
  module DB

    def server
      "#{COUCHDB_HOST}/c#{current_company}"
    end

    def copy_doc(doc, copy_id)
      data = RestClient::Request.execute(
        :method => 'COPY',
        :url => "#{server}/#{doc._id}",
        :headers => {'Destination' => "#{copy_id}"})
      return JSON.parse(data).merge({"_id" => copy_id})
    end

    # could add cache to this to make it faster
    def get_uuids(count=1)
      url = "#{COUCHDB_HOST}/_uuids"
      url << "?count=#{count}" if count > 1

      data = RestClient.get url
      JSON.parse(data)["uuids"]
    end

    # TODO: refactor-rename to clarify that this is only for saving board docs
    def save_doc(doc, copied_board = nil)
      begin
        url = "#{server}/#{doc._id}"
        url << "?rev=#{doc._rev}" unless doc._rev.nil?

        data = RestClient.put(url, doc.to_json)
      rescue
        RestClient.delete("#{server}/#{copied_board._id}?rev=#{copied_board.rev}") unless copied_board.nil?
        return nil, false
      end
      return JSON.parse(data)["rev"], true
    end

    def write_doc(doc)
      data = RestClient.put("#{server}/#{doc["_id"]}", doc.to_json)
      return JSON.parse(data)
    end

    def get_doc(id)
      begin
        data = JSON.parse(RestClient.get "#{server}/#{id}")
        data.merge!("id" => data["_id"])
      rescue
        nil
      end
    end

    def get_docs(ids)
      begin
        data = RestClient.post("#{server}/_design/docs/_view/get_docs_by_ids", {:keys => ids}.to_json)
        docs=(JSON.parse(data)).rows.map(&:value)
        docs.each do |board|
          board.merge!('id' => board["_id"])
        end
      rescue
        nil
      end
    end
  end
end
