require 'json'
require 'restclient'
require 'date'

require 'authentication'
require 'hash'
require 'couch/couch'
require 'skinny_board'
require 'product_backlog'
require 'helpers/twitter_helper'

module Helpers
  module API

    include SkinnyBoard::Authentication
    include SkinnyBoard::Boards
    include SkinnyBoard::ProductBacklog
    include Couch::DB
    include SkinnyBoard::TwitterHelper

    def authorize
      if !logged_in?
        throw :halt, [401, {"ok" => false, "error" => "you are not logged in"}.to_json]
      elsif !authorized?(params[:id])
        throw :halt, [403, {"ok" => false, "error" => "you are not authorized to do this"}.to_json]
      end
    end

    def notify_assigned(old_task, task, options={})
      options[:notify] ||= 'no'

      # only tasks can be assigned
      unless options[:notify] == 'no'

        old_users = get_user_ids_from_users(old_task.users)
        new_users = get_user_ids_from_users(task.users)

        if options[:notify] == 'all'
          user_ids = new_users - [current_user]
          Notifier.deliver_user_assignment(user_ids, task.description, task.board_id.to_i, current_user) unless user_ids.empty?
        else
          user_ids = new_users - old_users - [current_user]
          Notifier.deliver_user_assignment(user_ids, task.description, task.board_id.to_i, current_user) unless user_ids.empty?
        end
      end
    end

    def cud_wrapper(board, options={})
      raise ArgumentError, 'board not found.' if board.nil?
      options[:authorize] ||= true
      options[:content_type] ||= 'application/json'

      begin
        response['Content-Type'] = options[:content_type]
        authorize if options[:authorize]

        raise SecurityError, 'Board not editable.' if board.id != board.parent_id
        ({"ok" => true}.merge(yield(board))).to_json

      rescue ArgumentError => e
        throw :halt, [404, {"ok" => false, "error" => "#{e}"}.to_json]

      rescue SecurityError => e
        throw :halt, [403, {"ok" => false, "error" => "#{e}"}.to_json]

      rescue Exception => e
        throw :halt, [500, {"ok" => false, "error" => "#{e}"}.to_json]
        
      end
    end

    def wrapper(options={})
      options[:authorize] ||= true
      options[:content_type] ||= 'application/json'
      begin
        response['Content-Type'] = options[:content_type]
        authorize if options[:authorize]
        ({"ok" => true}.merge(yield)).to_json
      rescue Exception => e
        puts "wrapper error #{e}"
        throw :halt, [500, {"ok" => false, "error" => "#{e}"}.to_json]
      end
    end
  end # API
end # Helpers