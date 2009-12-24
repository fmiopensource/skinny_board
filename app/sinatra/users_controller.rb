class SinatraUsersController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/controller_helper'
  require 'couch/db/board'
  require 'couch/db/user'

  helpers do
    include ::Helpers::Controller
  end
  
  put '/boards/:id/users/:user_id' do
    login_required
    authorization_required(params[:id])

    result = {}
    user_id = params[:user_id].to_i

    begin
      board = get_board params[:id], :with_history => false

      raise "User id not provided." if user_id == 0
      raise "User already in the list." unless board.users.select{|u| u.id == user_id}.empty?

      user = User.find_by_id_and_company_id(user_id, current_company)
      raise "User not found." if user.nil?

      user = {:id => user.id, :name => user.full_name}
      board.users ||= []
      board.users << user
      save_board(board, :no_copy => true)

      status 200
      result = {
        "ok" => true,
        "user" => user
      }

    rescue Exception => e
      status 400
      result = { "ok" => false, "error" => "#{e}"}

    end

    response['Content-Type'] = 'application/json'
    result.to_json
  end

  delete '/boards/:id/users/:user_id' do
    login_required
    authorization_required(params[:id])
    
    result = {}
    user_id = params[:user_id].to_i

    begin
      raise "User id not provided." if user_id == 0
      raise "Can't delete company owner." if user_id == Company.find_by_id(current_company, :include => :owner).owner_id

      board = get_board params[:id], :with_history => false
      raise "User is not in the list." if board.users.empty? || board.users.select{|u| u.id == user_id}.empty?

      board.users.delete_if{|u| u.id == user_id}
      save_board(board, :no_copy => true)

      result = {
        "ok" => true
      }

    rescue Exception => e
      status 400
      result = { "ok" => false, "error" => e.message}

    end

    response['Content-Type'] = 'application/json'
    result.to_json

  end
  
end
