require 'json'
require 'restclient'
require 'date'

require 'partials'
require 'helpers/helpers'
require 'helpers/twitter_helper'
require 'user_session'
require 'authentication'
require 'hash'
require 'couch/couch'
require 'skinny_board'

module Helpers
  module Controller

    include Sinatra::Partials
    include SkinnyBoard::Helpers
    include SkinnyBoard::TwitterHelper
    include SkinnyBoard::Authentication
    include SkinnyBoard::Boards
    include UserSession
    include Couch::DB

    def putsc(text, color='y')
      code = case color
      when 'y' then 33
      when 'r' then 31
      when 'g' then 32
      end
      printf "\033[#{code}m#{text}\033[0m\n\n"
    end

    def get_board_users(board)
      company = Company.find(current_company, :include => :users)
      owner = {"id" => company.owner.id, "name" => company.owner.full_name}

      selected_user_ids = board.users.map(&:id)

      # list of all users less the ones already on the board and the owner
      # collected in [{:id=>.., :name=>}, ...] to match the board
      available_users = company.users.delete_if{|u|
        selected_user_ids.include?(u.id) || u.id == owner.id
      }.collect{|u| {"id" => u.id, "name" => u.full_name}}

      return owner, available_users
    end

  end # Controller
end # Helpers