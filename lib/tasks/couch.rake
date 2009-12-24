DB = "http://localhost:5984/fluidmedia"
require 'restclient'

namespace :couchdb do

  desc "Drop and re-create the CouchDB database, loading the design documents after creation"
  task :reset => [:drop, :create, :load_design_docs]

  desc "Create a new version of the CouchDB database"
  task :create do
    begin
      printf 'Creating db for you...'
      RestClient.put(ENV['db'] || DB, { })
      printf "\033[32mdone\033[0m\n"
    rescue
      printf "\033[31moops!\nHope you didn't need that DB, cause I couldn't create it.\033[0m\n"
    end
  end

  desc "Delete the current the CouchDB database"
  task :drop do
    begin
      printf "Deleting db for you..."
      RestClient.delete(ENV['db'] || DB)
      printf "\033[32mdone\033[0m\n"
    rescue
      printf "\033[31moops!\nI couldn't delete that DB.  Let's just pretend this never happened.\033[0m\n"
    end
  end

  require 'couch_design_docs'

  desc "Load (replacing any existing) all design documents"
  task :load_design_docs do
    begin
      printf "Loading _design doc for you..."
      CouchDesignDocs.upload_dir(ENV['db'] || DB, "couch/_design")
      printf "\033[32mdone\033[0m\n"
    rescue
      printf "\033[31moops!\nHope you didn't need those design docs, cause I couldn't add them.\033[0m\n"
    end
  end
end