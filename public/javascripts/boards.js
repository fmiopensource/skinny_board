var get_new_task = function(){ with(this) {
      var story_id = params['story_id'];
      var new_task = { action: "#/stories/" + story_id + "/tasks",
        method: 'post',
        id: story_id,
        type: 'task',
        element: {id : '0'},
        board_users: board_users
      }

      this.partial('/templates/edit_task.html.erb', new_task, function(html){
        $('#story_' + story_id + '_new_task').html(html).show();
      });

      return false;
    }};

  var get_edit_task = function(){ with(this) {
      var story_id = params['story_id'];
      var task_id = params['task_id'];
      var context = this;

      var task = { action: '#/stories/' + story_id + '/tasks/' + task_id,
        method: 'put',
        id: task_id,
        story_id: story_id,
        type: 'task',
        board_users: board_users
      }

      $.getJSON('/api/boards/' + board_id + '/stories/' + story_id + '/tasks/' + task_id, function(data){
        if(data.ok == true){
          task.element = data.task;
          context.partial('/templates/edit_task.html.erb', task, function(html){
            $('#element_' + task_id + '_edit').html(html).show();
          });
          $('#element_' + task_id).hide();
        } else {
          // figure out how to raise an error damnit!
        }
      });

      return false;
    }};

  var get_task_history = function(){ with(this){
        $.getJSON("/api/boards/" + board_id + "/tasks/" + params["id"] + "/history", function(data){
          if (data.ok == true)
          {
            //Do response
            var history = $("#task_history");

            // Building this into an html var because the div was trying to self
            // close if it's assigned right into the dom
            var html = '<div style="max-height: 500px;">'
            history.html('');

            $.each(data.messages, function() {
              html += "<li>" + this + "</li>";
            });
            
            html += ("</div>");
            history.html(html);

            if (data.messages == null || data.messages == [])
              history.html('No history for this task');
          $("#task_history").dialog('open');
          }
        });
    }};

var add_task = function(){ with(this){
      var story_id = params['story_id'];
      var context = this;
			var element_data;

			if($("#new_element_"+story_id).exists) {
				element_data = $('#new_element_'+story_id).serialize();
			}else {
				element_data = params.toHash();
			}

      $.post('/api/boards/' + board_id + '/stories/' + story_id + '/tasks', element_data, function(data){
        if(data.ok == true){
          board_rev = data.board.rev;
          data.task.color = data.task.color || 'Yellow';
          data.task.hours = context.hours_points_display(data.task.hours);

          context.partial('/templates/task.html.erb', data.task, function(html){
            $('#story_' + story_id + '_1').append(html);
          });
          $('#story_hours_' +  story_id).html(context.hours_points_display(data.story.hours));
          $('#total_hours_remaining_' +  board_id).html(context.hours_points_display(data.board.hours));


          $('#board_' + board_id + '_modified').html(context.board_date_display(data.task.created_at));
          setTimeout(bindDraggableTasks, 500); // This doesn't seem to be binding properly unless it is delayed
          app.setLocation('#/');
        } else {
          // figure out how to raise an error damnit!
        }
      }, 'json');
      return false;
    }};

  var update_task = function(){ with(this){
      var story_id = params['story_id'];
      var task_id = params['task_id'];
      var context = this;
      var element_data;
      if ($("#new_element_" + task_id).length)
        element_data = $("#new_element_" + task_id).serialize();
      else
        element_data = context.params.toHash();
      $.ajax({
        type: 'PUT',
        url: '/api/boards/' + board_id + '/stories/' + story_id + '/tasks/' + task_id,
        data: element_data,
        dataType: 'json',
        success: function(data){
          if(data.ok == true){
            board_rev = data.board.rev;
            data.task.color = data.task.color || 'Yellow';

            data.task.hours = context.hours_points_display(data.task.hours);

            context.partial('/templates/task.html.erb', data.task, function(html){
              $('#element_' + task_id + '_move').replaceWith(html);
              $('#total_hours_remaining_' + board_id).html(context.hours_points_display(data.board.hours));
              $('#story_hours_' + story_id).html(context.hours_points_display(data.story.hours));

              // are we moving?
              currentClass = $('#element_' + task_id + '_move').parents().filter('.tableCell').attr('class');
              newClass = 'tableCell ' + data.task.status_id;
              if((currentClass != newClass) || ('tableCell ' + params['element[status_id]'] != currentClass)){
                // This is a patch job for drag and drop as it is assigning left css values which causes
                // some pretty screwed up display issues
                $('#element_' + task_id + '_move').attr('style', "position: relative");

                $('#story_' + story_id + '_' + data.task.status_id).append($('#element_' + task_id + '_move'));
              }
              $('#board_' + board_id + '_modified').html(context.board_date_display(data.task.updated_at));
            });
            setTimeout(bindDraggableTasks, 500); // This doesn't seem to be binding properly unless it is delayed
            app.setLocation('#/');
          } else {
            alert('something terrible has happened in success')
          }
        },
        error: function(){
          alert('something terrible has happened in error');
        }
      });
      return false;
    }};

  var delete_task = function(){ with(this){
      var context = this;
      if( confirm('Are you sure?')){
        var story_id = params['story_id'];
        var task_id = params['task_id'];

        $.ajax({
          type: 'DELETE',
          dataType: 'json',
          url: '/api/boards/' + board_id + '/stories/' + story_id + '/tasks/' + task_id,
          success: function(data){
            board_rev = data.board.rev;

            $('#element_' + task_id + '_move').remove();
            $('#story_hours_' +  story_id).html(context.hours_points_display(data.story.hours));
            $('#total_hours_remaining_' +  board_id).html(context.hours_points_display(data.board.hours));
            $('#board_' + board_id + '_modified').html(context.board_date_display(new Date()));
          },
          error: function(){
            alert('something terrible has happened.');
          }
      });}

      return false;
    }};

  var app = new Sammy.Application(function() { with(this) {

    helpers(sammy_helpers);

    get('#/', function(){return false;});

    //
    // events
    //
    bind('task-ui-cancel', task_ui_cancel);
    bind('story-ui-cancel', story_ui_cancel);
    bind('tab-close', tab_close);
    bind('check-for-updates', check_for_updates);
    // end events

    //
    // user routes
    //
    put('#/users/:user_id', update_board_users);
    route('delete', '#/users/:user_id', remove_user_from_board);
    // end user routes

    //
    // story routes
    //
    get('#/stories/new', get_new_story);
    get('#/boards/:board_id/stories/:story_id/edit', get_story_edit);
    put('#/boards/:board_id/stories/:story_id', update_story);
    put('#/stories/:story_id', update_story);
    post('#/stories', add_story);
    route('delete', '#/stories/:story_id', delete_story);
    // story routes end

    //
    // task routes -- look for refactoring with stories
    //
    get('#/stories/:story_id/tasks/new', get_new_task);
    get('#/stories/:story_id/tasks/:task_id/edit', get_edit_task);
    get("#/task/:id/history", get_task_history);
    post('#/stories/:story_id/tasks', add_task);
    put('#/stories/:story_id/tasks/:task_id', update_task);
    route('delete', '#/stories/:story_id/tasks/:task_id', delete_task);
    // task routes end

    // priorities routes
    post('#/boards/priorities/:board_id/edit', reprioritize);

    // end priorities routes

    // burndown routes
    route('get', '#/burndown/:id', get_burndown);
    // burndown routes end
  }});
  
  $(function() {
    app.run('#/');
    $("#burndown_dialog").dialog({ 
      autoOpen: false,
      bgiframe: true,
      modal: true,
      zIndex: 999999,
      width: 'auto',
      minWidth: 800,
      minHeight: 600,
      resizable: false,
      draggable: true,
      close: function(){app.setLocation('#/');}
    });
    $("#task_history").dialog({
      autoOpen: false,
      zIndex: 999999,
      width: 500,
      modal: true,
      resizable: false,
      draggable: false,
      title: "Task History",
      close: function(){app.setLocation('#/');}
    });
    intervalId = setInterval("app.trigger('check-for-updates')", 60000);

    $("a.storyColumnToggle").bind("click", function() {
          column=$(this).attr("class").split(" ")[1];
          $(".tableCell." + column).toggle();
        });
  });

//})(jQuery);
