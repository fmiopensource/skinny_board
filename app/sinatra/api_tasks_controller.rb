class ApiTasksController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/api_helper'
  require 'couch/db/board'
  require 'couch/db/story'
  require 'couch/db/user'
  require 'couch/db/task'

  helpers do
    include ::Helpers::API
  end
  
  get '/api/boards/:id/stories/:story_id/tasks/:task_id' do
    wrapper do

      task = get_task(params[:id], params[:story_id], params[:task_id])
      {
        "ok" => true,
        "task" => task
      }
    end
  end

  post '/api/boards/:id/stories/:story_id/tasks' do
    cud_wrapper(get_board(params[:id])) do |board|

      story = get_element(board.stories, params[:story_id])

      # get user hashes from user_ids supplied
      params[:element]["users"] = []
      if params[:element].has_key?("user_ids")
        uids = params[:element][:user_ids].values
        board.users.each do |user|
          params[:element]["users"] << user if uids.include?(user.id.to_s)
        end

      end

      # create task
      task = create_task(story, params[:element].merge("created_by" => current_user))
      task.update({"color" => task_colors(task)})
    
      # update the board and story
      story["tasks"] ||= []
      story.tasks << task
      update_board(board, :add_up_tasks => true)

      update_twitter(task, "created", board)

      status 201
      # return json
      {
        "ok" => true,
        "task" => task,
        "story" => {
          "hours" => story.hours
        },
        "board" => {
          "hours" => board.hours,
          "rev" => board._rev
        }
      }
    end
  end

  put '/api/boards/:id/stories/:story_id/tasks/:task_id' do
    cud_wrapper(get_board(params[:id])) do |board|
      if params[:element].nil?
        status 400
        result = {
          "ok" => false,
          "error" => "no element provided"
        }

      else
        begin
          story = get_element(board.stories, params[:story_id])
          old_task = get_element(story.tasks, params[:task_id]).clone

          if params[:element]["status_id"] != old_task.status_id.to_s
            params[:element]["users"] = old_task.users
          else
            params[:element]["users"] = []
            if params[:element].has_key?("user_ids")
              uids = params[:element][:user_ids].values
              board.users.each do |user|
                params[:element]["users"] << user if uids.include?(user.id.to_s)
              end
            end
          end
          task = update_task(story, params[:task_id], params[:element])
          story.tasks[task.position-1] = task
          # update board -- needs error handling for failed
        end while update_board(board, :add_up_tasks => true, :reindex_tasks => true) == false

        # email assigned users if saved successfully
        notify_assigned(old_task, task, params)

        update_twitter(task, old_task.status_id == task.status_id ? "updated" : "movement", board)

        # we don't want the textile format save in couch, thus we modify the hash after everything else has been saved
        task.update({"description" => textilize(task.description), "color" => task_colors(task) })


        # Users is just id and name, no avatar.  avatars require a file type and some other info
        # specific to the user object to generate the URL so we just do a find and pull whatever
        # is currently stored for the users's avatar in AR.  Only need to do this if there is one
        # user assigned, if there's more than 1 it just displays the multi user avatar
        if task.users.length == 1
          user = User.find(task.users[0].id)
          task.users[0].merge!("avatar_url" => user.avatar_url)
        end

        status 200
        result = {
          "ok" => true,
          "task" => task,
          "board" => {
            "hours" => board.hours,
            "rev" => board._rev
          },
          "story" => {"hours" => story.hours}
        }
      end

      # return json
      result
    end
  end

  delete '/api/boards/:id/stories/:story_id/tasks/:task_id' do
    cud_wrapper(get_board(params[:id])) do |board|
      error = ''
      # find and delete the task
      if board.stories.empty?
        error = 'no stories found - so no tasks'

      else
        story = board.stories.select{ |s| s.id == params[:story_id] }.first
        if story.nil?
          error = 'story not found'
        elsif story.tasks.empty?
          error = 'story has no tasks'
        else
          story.tasks.delete_if{|t| t.id == params[:task_id]}

          # update board
          board.stories[Integer(story.position) -1] = story
          update_board(board, :reindex => false, :add_up_stories => false, :add_up_tasks => true)
        end
      end

      # return json
      (error.blank? ? {
          "ok" => true,
          "board" => {
            "hours" => board.hours,
            "rev" => board._rev
          },
          "story" => {
            "hours" => story.hours
          }
        } : {"ok"=> false, "error" => error})
    end
  end

  get '/api/boards/:id/tasks/:task_id/history' do
    wrapper do
      messages = get_doc(params[:task_id])
      response['Content-Type'] = 'application/json'
      {
        "ok" => true,
        "messages" => messages.changes.reverse
      }
    end
  end

end
