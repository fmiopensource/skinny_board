module SkinnyBoard
  module TwitterHelper
    def update_board_twitter(board, action)
      return unless (!board.twitter.blank? && board.twitter.tweet)
      send_twitter_update(board.twitter["username"], board.twitter["password"],
          "Board #{action} by #{User.find(current_user).first_name} - #{board.title}")
    end

    def update_twitter(element, action, board)
      user = User.find(current_user)
      return true if ((board && board.twitter && !board.twitter.tweet)  && (user.twitter_login.blank? && user.twitter_password.blank?))
      personal_tweet(action, element, board, user) unless (user.twitter_login.blank? || user.twitter_password.blank?)
      if board && board.twitter #ugly fix
        if board.twitter.tweet and !board.twitter.username.blank?
          board_tweet(action, element, board, user.full_name)
        end
      end

    end

    def crypto_key
      EzCrypto::Key.with_password "password", "system salt"
    end

    def send_twitter_update(username, password, message)
      begin
        client = Twitter::Client.new(:login => username, :password => password)
        client.status(:post, message)
      rescue Twitter::RESTError => re
        putsc re
        case re.code
        when '400'
          flash[:error] = "Twitter denied the attempt to post"
        when '503'
          flash[:error] = "Twitter appears to be down"
        when '401'
          flash[:error] = "Please make sure you have entered valid Twitter credentials"
        end
      end
    end
    
    def personal_tweet(action, element, board, user)
        message  =""
        if action == 'movement'
          message = "Moved #{twitterify_element(element)} to #{element_status(element)}"
        else
          message = "#{action.capitalize} #{twitterify_element(element)}"
        end
        unless board.blank?
          message += " on #{board.title}"
        else
          message += " on #{element.title}"
        end
        
        send_twitter_update(user.twitter_login, crypto_key.decrypt64(user.twitter_password), message)
    end

    def board_tweet(action, element, board, user_name)
        message = "#{element_type(element).capitalize} #{twitterify_element(element)} "
        if action == 'movement'
          action = "moved to #{element_status(element)}"
        end
        message += " #{action} by #{user_name}"
        if element.level == LEVEL_STORY
          message += ", #{element.story_points || 'no'} points"
        elsif element.level == LEVEL_TASK
          message += ", #{element.hours || 'no'} hours"
        end
        send_twitter_update(board.twitter.username, board.twitter.password, message)
    end

    def twitterify_element(element)
      info = ""
      info += "#{element.title} - " unless element.title.blank?
      info +="#{element.description[0,75]}"
      info += '...' if element.description.length > 75

      info
    end

    def element_type(element)
      case element.level
      when LEVEL_STORY
        "story"
      when LEVEL_TASK
        "task"
      end
    end

    def element_status(element)
      case element.status_id
      when STATUS_TODO
        "to do"
      when STATUS_IN_PROCESS
        "in process"
      when STATUS_TO_VERIFY
        "to verify"
      when STATUS_DONE
        "done"
      end
    end
  end # End Module Helpers
end # End Module SkinnyBoard
