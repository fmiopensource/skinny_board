module SkinnyBoard
  module Helpers

    class Flash
      def initialize(store={})
        @store = store
      end
      def [](key)
        @store["flash"].delete(key.to_sym) unless @store["flash"].blank?
      end
      def []=(key, value)
        @store["flash"][key.to_sym] = value unless @store["flash"].nil?
      end
    end

    def board_class(board)
      "board#{' productBacklogBoard' if board['level']==3}"
    end

    def board_description(description='')
      h(description.gsub(/^(.{10}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}) unless description.nil?
    end

    def flash
      Flash.new(session)
    end

    def task_colors(task)
      color = 'Yellow'
      if task['parked']
        color = 'Pink'
      elsif task['tag_list'] =~ /bug/i
        color = 'Red'
      elsif task['tag_list'] =~ /spike/i
        color = 'Brown'
      elsif !task['users'].blank? and task['users'].collect{|user| user['id']}.include?(current_user)
        color = 'Green'
      end
      return color
    end

    def returning(value)
      yield(value)
      value
    end

    def board_users_helper(users, text, &block)
      returning "" do |result|
        users.each do |user|
          result << "<li id=\"user_#{user.id}\">
            <div class=\"name\">#{user.name}</div>
            <a onclick=\"#{block.call(user)}\"href=\"javascript:void(0);\" >#{text}</a>
          </li>"
        end unless users.empty?
      end
    end

    def board_type_helper(selected_id=LEVEL_BOARD)
      [{ :id => LEVEL_BOARD,          :name => "Sprint Backlog"},
       { :id => LEVEL_PRODUCT_BACKLOG,:name => "Product Backlog"}].collect{|type|
        "<input type=\"radio\" value=\"#{type[:id]}\" name=\"element[level]\" id=\"element_level_#{type[:id]}\"
        #{selected_id == type[:id] ? "checked=\"checked\"" : ''} />
        <label for=\"element_level_#{type[:id]}\">#{type[:name]}</label>"
       }.join('')
    end

    def show_boards_link
      params[:show_all] == "true" ?
        '<a href="/boards">Show only active boards</a>' :
        '<a href="/boards?show_all=true">Show all boards</a>'
    end

    def logged_in_links
      "<a href=\"/users/#{session[:user]}/edit\">#{h(session[:user_first_name])}</a>" <<
        " | <a href=\"/users\">users</a> " <<
        " | <a href=\"/logout\">log out</a> | " if logged_in?
    end

    def board_last_modified(board)
      "last modified <b id='board_#{board.id}_modified'>#{DateTime.parse(board['updated_at']).strftime('%b %d/%Y, %I:%M %p')}</b>" unless board['updated_at'].nil?
    end

    def board_start_end_date(board)
      "#{Date.parse(board['start_date']).strftime('%b %d/%y -') unless board['start_date'].nil?}" <<
        "#{Date.parse(board['end_date']).strftime('%b %d/%y') unless board['end_date'].nil?}"
    end

    def board_tabs_new_or_all
      params[:id].nil? ?
        '<a href="/boards/new" class="boardTab">New Board</a>' :
        '<a href="/boards" class="boardTab">Boards</a>'
    end
    
    # Links back to referer or default path
    def link_back_or_default(*args)
      title = args.first
      path = request.env["HTTP_REFERER"] || (args.second || "/boards") #/boards is the default path
      "<a href='#{path}'>#{title}</a>"
    end
    
    def get_board_link(board)
      board.level == 0 ? "/boards/#{board.id}" : "/product_backlog/#{board.id}"
    end

    def task_hours(task)
      "#{task['hours']} hour#{task['hours'] > 1 ? "s" : ""}<br/>" unless task['hours'].blank? or task['hours'] == '*'
    end

    def options_for_select(container, selected = nil)
      return container if String === container

      container = container.to_a if Hash === container
      options_for_select = container.inject([]) do |options, element|
        text, value = element, element
        selected_attribute = ' selected="selected"' if is_selected(value, selected)
        options << %(<option value="#{value}"#{selected_attribute}>#{text}</option>)
      end

      options_for_select.join("\n")
    end

    def is_selected(value, selected)
      case selected
      when nil then value == "*"
      when -1 then value == "?"
      else value == selected.to_s
      end
    end

    #
    # refactor to include other options for:
    # -- needs a custom is_selected and text,value generator
    #
    def options_for_history(container, selected)
      return container if String === container
      container = container.to_a if Hash === container

      options_for_select = container.inject([]) do |options, element|
        text, value = element.value.date, element.id
        selected_attribute = ' selected="selected"' if value == selected
        options << %(<option value="#{value}"#{selected_attribute}>#{text}</option>)
      end

      options_for_select.join("\n")
    end
    
    def board_or_product_backlog_url(level)
      level ||= LEVEL_BOARD
      level == LEVEL_BOARD ? 'http://stage.skinnyboard.local:3000/boards/' : 'http://stage.skinnyboard.local:3000/product_backlog/'
    end

    def story_tag_list(tag_list)
      "<small>Tags: #{h(tag_list)}</small>" unless tag_list.blank?
    end
    
    def textilize(content)
      ActionController::Base.helpers.textilize(content)
    end

    def hours_points_display(value)
      case value
        when nil then "*"
        when -1 then "?"
        else value.to_f.to_s
      end
    end

    def get_hidden_stories(user_id, board_id)
      get_hidden_whatsit(user_id, 'closed_stories', board_id)
    end

    def get_hidden_columns(user_id, board_id)
      get_hidden_whatsit(user_id, 'closed_columns', board_id)
    end

    def get_text_filter(user_id, board_id)
      filters = UserBoardFilter.find(:first, :conditions => { :board_id => board_id, :user_id => user_id})
      return '' if filters.nil?
      filters.text_filter || ''
    end

    def get_hidden_whatsit(user_id, method_name, board_id)
      filters = UserBoardFilter.find(:first, :conditions => { :board_id => board_id, :user_id => user_id})
      return [] if filters.nil?
      filters.send(method_name).keys.map(&:to_s)
    end
    
    def story_columns(stories=[],columns=2)
      stories ||= []
      stories_per_column = stories.length > 0 ? (stories.length / 2.0).ceil : 1
      return {:col_length => stories_per_column,
          :stories => stories.in_groups_of(stories_per_column,false)}
    end
  end # End Module Helpers
end # End Module SkinnyBoard
