class FactoryBoy

  require 'restclient'
  require 'json'

  def self.create(doc, parent_id=nil)
    data = RestClient.get "#{COUCHDB_HOST}/_uuids"
    doc_id = JSON.parse(data)["uuids"][0]
    doc["parent_id"] = parent_id || doc_id
    doc["_rev"] = FactoryBoy.write_to_couch(doc, doc_id)
    doc["id"] = doc_id
    doc["_id"] = doc_id
    return doc
  end

  def self.write_to_couch(doc, doc_id)
    data = RestClient.put("#{COUCHDB_HOST}/#{COUCHDB_TEST_DB}/#{doc_id}", doc.to_json)
    JSON.parse(data)["rev"]
  end

end 