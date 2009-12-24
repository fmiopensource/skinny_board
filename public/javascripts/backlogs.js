var create_new_board_from_backlog = function(){ with(this) {
          var story_ids = jQuery.makeArray($("#backlog_stories .bulkCheckBox:checked").map(function() {
            return "stories[]=" + $(this).attr("id").toString();
          }));
          var board_name = $("#new_sprint_name").val();
          $.ajax({
            type: 'POST',
            url: '/api/product_backlogs/' + params['id'] + '/board',
            data: story_ids.join("&") + "&title=" + board_name,
            dataType: 'json',
            success: function(data){
              if(data.ok == true){
                if(data.new_board) {
                  $("#boards_containers").append(data.new_board.value);
                  $("#move_to_sprint").append(
                    "<option value=\"" + data.new_board.id + "\">" + data.new_board.title + "</option>");
                  sortablify(data.new_board.id);
                }
                if (data.updated_backlog) {
                  $("#sortable_elements_" + data.updated_backlog.id).replaceWith(data.updated_backlog.value);
                  sortablify(data.updated_backlog.id);
                }
              }
            }
          });
          return false;
        }};

var move_stories_to_sprint = function(){ with(this) {
          var story_ids = jQuery.makeArray($("#backlog_stories .bulkCheckBox:checked").map(function() {
            return "stories[]=" + $(this).attr("id").toString();
          }));

          // var sprint = $("#move_to_sprint").val().trim();
					var sprint = jQuery.trim($("#move_to_sprint").val());

          $.ajax({
            type: 'PUT',
            url: '/api/product_backlogs/' + params['id'] + '/board',
            data: story_ids.join("&") + "&sprint_id=" + sprint,
            dataType: 'json',
            success: function(data){
              if(data.ok == true){
	              if (data.updated_board) {
									$("#sortable_elements_" + data.updated_board.id).remove();
                  $("#board_" + data.updated_board.id).replaceWith(data.updated_board.value);
                  sortablify(data.updated_board.id);
                }
							  if (data.updated_backlog) {
								  $("#board_" + data.updated_backlog.id).replaceWith(data.updated_backlog.badge);
                  $("#sortable_elements_" + data.updated_backlog.id).replaceWith(data.updated_backlog.value);
                  sortablify(data.updated_backlog.id);
                }
              }
            }
          });
          return false;
        }};

var bulk_delete_stories = function(){ with(this){
          var story_ids = jQuery.makeArray($("#backlog_stories .bulkCheckBox:checked").map(function() {
            return "stories[]=" + $(this).attr("id").toString();
          }));

          $.ajax({
            type: 'DELETE',
            url: '/api/product_backlogs/' + params['id'] + '/story',
            data: story_ids.join('&'),
            dataType: 'json',
            success: function(data){
              if(data.ok == true){
                $('#board_' + data.updated_backlog.id).replaceWith(data.updated_backlog.badge);
                $('#sortable_elements_' + data.updated_backlog.id).replaceWith(
                  data.updated_backlog.value);
                sortablify(data.updated_backlog.id);
              }
            }
          });
      }};

var add_story = function(){ with(this) {
      var context = this;
      $.post('/api/boards/' + board_id + '/stories', params.toHash(), function(data){
        if(data.ok == true){
          board_rev = data.board.rev;

          data.story.color = 'Yellow'
          data.story.story_points = context.hours_points_display(data.story.story_points);

          if (data.updated_backlog) {
							$('#board_'+data.updated_backlog.id).replaceWith(data.updated_backlog.badge);
              $("#sortable_elements_" + data.updated_backlog.id).replaceWith(data.updated_backlog.value);
              sortablify(data.updated_backlog.id);
          }
        }
        else {
          // figure out how to raise an error damnit!
        }
      }, 'json');

      return false;
    }};

  var get_story_edit = function(){ with(this) {
      var context = this;
      var story_board_id = params['board_id'];
      var story_id = params['story_id'];
      var story = { action: '#/boards/' + story_board_id + '/stories/' + story_id,
        method: 'put',
        id: story_id,
        type: 'story'
      }

      $.ajax({
        type: 'GET',
        url: '/api/boards/' + story_board_id + '/stories/' + story_id,
        dataType: 'json',
        success: function(data){
          if(data.ok == true){
            story.element = data.story;
            context.partial('/templates/edit.html.erb', story, function(html){
              $('#story_' + story_id + '_edit').html(html).show();
              $('#story_' + story_id + '_display').hide();
              $('#story_' + story_id + '_edit input#element_title').example("Story " + data.story.position);
              });
            }
          },
          error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#flash_error").html('Something terrible has happened: ' + textStatus);
          }
        });

      return false;
    }};

  var update_story = function(){ with(this){
      var context = this;
      var story_board_id = params['board_id'];
      var story_id = params['story_id'];
      var story = {
        description:  params['element[description]'],
        story_points: params['element[story_points]'],
        tag_list: params['element[tag_list]'],
        title: params['element[title]'],
        position: params['element[position]']
      }

      // check for parked - something weird there...

      $.ajax({
        type: 'PUT',
        url: '/api/boards/' + story_board_id + '/stories/' + story_id,
        data: story,
        dataType: 'json',
        success: function(data){
          if(data.ok == true){

            board_rev = data.board.rev;
            data.story.color = 'Yellow';
            data.story.story_points = context.hours_points_display(data.story.story_points);

            context.partial('/templates/mini_story_badge.html.erb', data, function(html){
                  $('#story_' + story_id).replaceWith(html);
                  showHideStory(story_id);
            });
            
            $('#total_story_points_' + board_id).html(context.hours_points_display(data.board.story_points));
            $('#story_' + story_id + '_points').html(data.story.story_points);

            app.setLocation('#/');

                
          } else {
            // display an error message to the user
            alert('did not get an ok');
          }
        },
        error: function(){
          alert('something terrible has happened');
        }
      });

      return false;
    }};

  var app = new Sammy.Application(function() { with(this) {

    helpers(sammy_helpers);

    get('#/', function(){return false;});

    // events
    bind('task-ui-cancel', task_ui_cancel);
    bind('story-ui-cancel', story_ui_cancel);
    bind('tab-close', tab_close);
    bind('check-for-updates', check_for_updates);
    // end events

    //
    // story routes
    //
    get('#/stories/new', get_new_story);
    get('#/boards/:board_id/stories/:story_id/edit', get_story_edit);
    put('#/boards/:board_id/stories/:story_id', update_story);
    post('#/stories', add_story);
    route('delete', '#/stories/:story_id', delete_story);
    // story routes end

    // product backlog routes
    post('#/product_backlogs/:id/board', create_new_board_from_backlog);
    put('#/product_backlogs/:id/board', move_stories_to_sprint);
    route('delete', '#/product_backlogs/:id/story', bulk_delete_stories);
    // end product backlog routes

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
      width: 400,
      modal: true,
      resizable: false,
      draggable: false,
      title: "Task History",
      close: function(){app.setLocation('#/');}
    });
    intervalId = setInterval("app.trigger('check-for-updates')", 60000);
  });
