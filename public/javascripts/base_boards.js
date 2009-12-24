//includes functionality common to boards and backlogs

$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

$(document).ajaxComplete(function(event, request, settings) {
  try {
    // turn the response into json
    eval("var x=" + request.responseText);

    var errorMessage = '';

    // if request status is not success or there is an error in the response json
    // show the error message
    if( !(request.status == 200 || request.status == 201) || x.error) {
      errrorMessage = x.error;
    }
    $("#flash_error").html(errorMessage);
  } catch(e) {
    
  }
});

  var valid_points = ['*', '0.0', '0.5', '1.0', '2.0', '3.0', '5.0', '8.0', '13.0', '20.0', '40.0', '100.0', '?'];
  var board_users = [];
  var intervalId;

  function loadUsers(){
    if (board_id) {
      try{
        $.getJSON('/api/boards/' + board_id + '/users', function(data){
          if(data.ok == true)
            board_users = data.users;
          else
            board_users = [];
        });
      } catch(e) {
        board_users = [];
      }
    }
    else
      board_users = [];
  }
  loadUsers();

var sammy_helpers = {
      hours_points_display: function(value){
        switch(value){
          case null:return "*";
          case -1:  return "?";
          default:  return value.toFixed(1);
        }
      },
      move_user_permission: function(user_id, dest, link_text){
        var li = $('#user_' + user_id);
        var name = li.find('div').text();
        var method = link_text == 'Add To Board' ? 'put' : 'delete'
        var new_li = '<div class="name">' + name + '</div>' +
          "<a href=\"javascript:void(0);\" onclick=\"javascript:app.runRoute('" +
            method + "', '#/users/" + user_id + "');\">" + link_text + "</a>"
        dest.append('<li id="user_' + user_id + '">' + new_li + '</li>');
        li.remove();
      },
     board_date_display: function(board_date){
       board_date = new Date(board_date);
       var months = new Array(12);
       months[0] = "Jan";
       months[1] = "Feb";
       months[2] = "Mar";
       months[3] = "Apr";
       months[4] = "May";
       months[5] = "Jun";
       months[6] = "Jul";
       months[7] = "Aug";
       months[8] = "Sep";
       months[9] = "Oct";
       months[10] = "Nov";
       months[11] = "Dec";
       var formatted_date = months[board_date.getMonth()] + ' ' + board_date.getDate() + '/' + board_date.getFullYear() + ', ';
       formatted_date += board_date.getHours() > 12 ? board_date.getHours() - 12 : board_date.getHours();
       formatted_date += ":" + board_date.getMinutes() + ' ' + (board_date.getHours >= 12 ? "PM" : "AM");
       return formatted_date;
     }
    }
    
// common events
var tab_close = function(e, data){
      var id = data['id'];
      $.ajax({
          type: 'DELETE',
          url: '/tabs/' + id,
          success: function(){
            $('#container_tab_board_' + id).remove();
            if (id == board_id) {
              window.location = "/boards";
            }
          },
          error: function(){
            alert('something terrible has happened.');
          }
      });
    }

var task_ui_cancel = function(e, data){
      var id = data['id'];
      $('#element_' + id + '_edit').hide().html('');
      $('#element_' + id).show();
      app.setLocation('#/');
    };

var story_ui_cancel = function(e, data){
      var id = data['id'];
      $('#story_' + id + '_edit').hide().html('');
      $('#story_' + id + '_display').show();
      app.setLocation('#/');
    };

var check_for_updates = function(){ with(this) {
    if (board_id){
      $.ajax({
        type: 'GET',
        dataType: 'json',
        url: '/api/boards/' + board_id + '/revision',
        success: function(data){
          if(data.ok && data.revision != board_rev) {
            $('#notifier').show();
            clearInterval(intervalId);
          }
        }
      });
     }
    }};
// end common events

// user functions
var update_board_users = function(){ with(this){
      var user_id = params['user_id'];
      var context = this;
      if (board_id){
        $.ajax({
          type: 'PUT',
          url: '/boards/' + board_id + '/users/' + user_id,
          dataType: 'json',
          success: function(data){
            if(data.ok == true){
              context.move_user_permission(user_id, $('#available_users'), 'Remove From Board');
            }
          }
        });
      }
      return false;
    }};

  var remove_user_from_board = function(){with(this){
      var user_id = params['user_id'];
      var context = this;
      $.ajax({
        type: 'DELETE',
        dataType: 'json',
        url: '/boards/' + board_id + '/users/' + user_id,
        success: function(data){
          if(data.ok == true){
            context.move_user_permission(user_id, $('#no_access_users'), 'Add To Board');
          }
        }
      });

      return false;
    }};
  // end user functions

  // story functions
  var get_new_story = function(){ with(this) {
      var new_story = { action: "#/stories",
        method: 'post',
        id: board_id,
        type: 'story',
        element: {id : '0'}
      }
      this.partial('/templates/edit.html.erb', new_story, function(html){
        $('#story_new').html(html).show();
        $('#element_title').example("Story Title");
      });

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

            context.partial('/templates/story.html.erb', data.story, function(html){
                $('#story_' + story_id + '_display').html(html).show();
                $('#story_' + story_id + '_edit').hide();
            });
            
            $('#total_story_points_' + board_id).html(context.hours_points_display(data.board.story_points));
            $('#story_' + story_id + '_points').html(data.story.story_points);
            $('#board_' + board_id + '_modified').html(context.board_date_display(data.story.updated_at));

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

 var add_story = function(){ with(this) {
      var context = this;
      $.post('/api/boards/' + board_id + '/stories', params.toHash(), function(data){
        if(data.ok == true) {
          board_rev = data.board.rev;

          data.story.color = 'Yellow'
          data.story.story_points = context.hours_points_display(data.story.story_points);
          data.story.hours = context.hours_points_display(data.story.hours);
          if ($('.sortable_elements').length > 0){
            context.partial('/templates/mini_story_badge.html.erb', data, function(html){
              var sortables = $('ol.sortable');
              $(sortables[sortables.length - 1]).append("<li id='item_" + data.story.id + "'>" + html + "</li>");
              sortablify(board_id);
              alignSortableLists(board_id);
            });
          }
          else {
            context.partial('/templates/storyrow.html.erb', data.story, function(html){
              $('#storiesContainer').append(html);
            });
          }
          $('#total_story_points_' + board_id).html(context.hours_points_display(data.board.story_points));
          $('#board_' + board_id + '_modified').html(context.board_date_display(data.story.updated_at));
        } else {
          // figure out how to raise an error damnit!
        }
      }, 'json');

      return false;
    }};

  var delete_story = function(){ with(this){
      var context = this;
      if( confirm('Are you sure?')){
        var story_id = params['story_id'];
        $.ajax({
          type: 'DELETE',
          dataType: 'json',
          url: '/api/boards/' + board_id + '/stories/' + story_id,
          success: function(data){
            board_rev = data.board.rev;
            $('#story_' + story_id + '_tableRow').remove();
            $('#item_' + story_id).remove();
            alignSortableLists(board_id);
            $('#total_story_points_' + board_id).html(context.hours_points_display(data.board.story_points));
            $('#total_hours_remaining_' + board_id).html(context.hours_points_display(data.board.hours));
            $('#board_' + board_id + '_modified').html(context.board_date_display(new Date()));
          },
          error: function(){
            alert('something terrible has happened.');
          }
      });}

      return false;
    }};

 var reprioritize = function(){ with(this){
      var story_board = params['board_id'];
      var context = this;

      $.post('/api/boards/' + board_id + '/stories/' + story_id + '/tasks', params.toHash(), function(data){
        if(data.ok == true){
          board_rev = data.board.rev;

          context.partial('/templates/task.html.erb', data.task, function(html){
            $('#story_' + story_id + '_1').append(html);
          });

          app.setLocation('#/');
        } else {
          // figure out how to raise an error damnit!
        }
      }, 'json');

      return false;
    }};
// end story functions

// board functions
 var get_burndown = function(){ with(this){
      $.getJSON('/api/boards/' + (params['id'] || board_id) + '/burndown', function(data){
        if(data.ok == true){
          $('#burndown_dialog').html('<img src="' + data.burndown.image_path + '" />');
					 $('#burndown_dialog').dialog({
							autoOpen: false,
							modal: true,
							draggable: true
						});
          $('#burndown_dialog').dialog('open');
        } else {
          alert("There was an error accessing the burndown");
        }
      });
    }};
// end board functions
