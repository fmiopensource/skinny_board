$(function() {

    scrollableTabs();
    buildStoryToggles();
    bindHistoryDropdown();
    bindSortableElements();
    bindBoardTitleDefault();

    if ($('#appBoardScreen').length > 0){
      activateStoryFilter();
      bindDraggableTasks();
    }
    else if ($('#boards').length > 0)
      activateBoardFilter();
    $(".sortable").disableSelection();

    // jQuery extensions
    jQuery.fn.exists = function() { return (this.length > 0); };
});

function showHideBoardStories(board_id, isBacklog)
{
  if ($('#sortable_elements_' + board_id).is(':visible'))
    collapseBoardBadge(board_id, isBacklog);
  else
    expandBoardBadge(board_id, isBacklog);
}

function expandBoardBadge(board_id, isBacklog){
  $($('#board_' + board_id).find('.showHideImg')[0]).attr('src', "/images/arrowOpen.png");
  $('#sortable_elements_' + board_id).fadeIn();
}

function collapseBoardBadge(board_id, isBacklog){
  $($('#board_' + board_id).find('.showHideImg')[0]).attr('src', "/images/arrowClosed.png");
  $('#sortable_elements_' + board_id).fadeOut();
}

function sortablify(board_id) {
  var lists=$("#sortable_elements_" + board_id + " .sortable");
  $(lists).sortable({
    connectWith: lists,
    stop: function(event, ui)
    {
      var ids = [];
      var sortable_div = $("#sortable_elements_" + board_id);
      $("ol > li", sortable_div).each(function(){
        ids.push($(this).attr('id').split("_")[1]);
      });

      // correct ol numbering
      $("#list_1_" + board_id).attr("start", $("#list_0_" + board_id + " li").length + 1);

      var json_array = $.map(ids,function(n) {
        return '"'+n+'"';
      });

      var to_post = {
        stories: '['+json_array+']'
      };

      $.ajax({
        type: "POST",
        url: "/boards/priorities/" + board_id + "/update",
        data: to_post,
        error: function() {
          alert("An error occurred, Skinnyboard.com will refresh your list for you to try again");
        }
      });
      alignSortableLists(board_id);
    }
  });
}

function scrollableTabs(){
  $('#right_scroll').bind('click', tabScroller);
  $('#left_scroll').bind('click', tabScroller);
}

function alignSortableLists(id){
  console.log("Inside alignSortableStories with [ ID -- "+id+" ]");
  var elements = [];
  var lists = $("#list_0_"+id+", #list_1_"+id);
  lists.each(function(){
    $(this).children().each(function(){
      elements.push($(this));
    })
    $(this).children().remove();
  })
  var leftHalfCount = Math.ceil(elements.length / 2);
  for(var i = 0; i < leftHalfCount; i++){
    $("#list_0_"+id).append(elements[i]);
  }
  for(var i = leftHalfCount; i < elements.length; i++){
    $("#list_1_"+id).append(elements[i]);
  }
}

function bindSortableElements(){
  $(".sortable_elements").each(function(){
  var board_id=$(this).attr("id").replace("sortable_elements_","");
  var sortable_div=$(this);
  var lists="#" + $(this).attr("id") + " .sortable";
  $(lists).sortable({
    connectWith: lists,
    stop: function(event, ui)
    {
      var ids = [];
       $("ol > li", sortable_div).each(function(){
          ids.push($(this).attr('id').split("_")[1]);
      });

      var json_array = $.map(ids,function(n) {
        return '"'+n+'"';
      });

      var to_post = {
        stories: '['+json_array+']'
        };


      $.ajax({
        type: "POST",
        url: "/boards/priorities/" + board_id + "/update",
        data: to_post,
        error: function() {
          alert("An error occurred, Skinnyboard.com will refresh your list for you to try again");
          //refresh
        }
      });
      alignSortableLists(board_id);
    }
  });
});
}

function tabScroller(event) {
  var size_of_tabs = "131"; // size of tabs is 130. Needs the extra pixel for white padding.
  var mathum = "-";

  if(event.target.id == "left_scroll")
    mathum = "+";

  var container = $('#scrollable_tabs_container');
  var children = container.children().length;
  children -= 4; // There are 5 tabs displayed.  5 - 1 = 4
  var max_move_to = size_of_tabs * children * -1;

  var current_left = parseInt(container.css('left'));

  var to_move_to = eval(current_left + mathum + size_of_tabs);

  if(to_move_to < 1 && to_move_to > max_move_to)
    container.css('left', to_move_to + 'px');
}

function buildStoryToggles() {
  //row toggle
  $('a.storyRowToggle').each(function(link){
    $(this).bind('click', function(link){
      toggleStoryRow($(this).closest("div.tableRow").attr('id').split("_")[1]);
    });
  });
}

function toggleStoryRow(id) {
  var opening = /Closed/.test($('#priorityLink_' + id).attr('src'));
  if ( opening )
    showStoryRow(id);
  else
    hideStoryRow(id);

  $.post('/filters',
    {
      story_id: id,
      is_open: opening,
      board_id: board_id
    },
    function(data){
    },
    "script"
  );

}

function showHideBoards(){
  $('.board').each(function(board){
    if ($('.boardFOOTER').is(':visible'))
      goTiny();
    else
      goBig();
  });
}

function goTiny() {
  $('#showHideImg').attr('src', '/images/arrowClosed.png');
  $('.boardFOOTER').each(function(){
    $(this).slideUp();
  });
  $('#burndown_report').animate({
    left: '-20px',
    top: '-20px'
  });
  // $('#birds_eye_report').animate({
  //   left: '55px',
  //   top: '-53px'
  // });
  $('#boardCardFooter').animate({
    left: "0px",
    top: "-50px"
  });

  $('.board .dates').each(function(date){
    $(this).fadeOut();
  });

  $('.board .description').each(function(description){
    $(this).fadeOut();
  });
  $('.board').each(function(board){
    $(this).animate({
      height: '60px'
    });
  });
  $('#appScreen').animate({
    marginTop: '220px'
  });
  $('#appScreenBoardsEdit').animate({
    marginTop: '60px'
  });
  $('#bulkMenu').animate({
    top: '200px'
  });
}

function goBig(){
  $('#showHideImg').attr('src', '/images/arrowOpen.png');
  $('.boardFOOTER').each(function(){
    $(this).slideDown();
  });
  $('#burndown_report').animate({
    left: '0px',
    top: '0px'
  });
  $('#boardCardFooter').animate({
    left: "0px",
    top: "0px"
  });

  $('.board .dates').each(function(date){
    $(this).fadeIn();
  });

  $('.board .description').each(function(description){
    $(this).fadeIn();
  });
  $('.board').each(function(board){
    $(this).animate({
      height: '140px'
    });
  });
  $('#appScreenBoardsEdit').animate({
    marginTop: '160px'
  });
}

function showHideStory(story_id) {
  if ($($('#story_' + story_id + ' .storyDetails')[0]).is(":visible"))
    collapseStoryBadge(story_id);
  else
    expandStoryBadge(story_id);
}

function collapseStoryBadge(story_id){
  $('#story_' + story_id).find('#showHideImg').attr('src', "/images/arrowClosed.png");
  $($('#story_' + story_id + ' .storyDetails')[0]).fadeOut();
}

function expandStoryBadge(story_id){
  $('#story_' + story_id).find('#showHideImg').attr('src', "/images/arrowOpen.png");
  $($('#story_' + story_id + ' .storyDetails')[0]).fadeIn();
}

function activateStoryFilter(){
  if ($("#clear_filter").length > 0) {
    $('#clear_filter').bind("click", function(){
      $("#story_filter").val("");
      storyFilter();
      return false;
    });
  }

  if ($("#story_filter").length > 0) {
    $("#story_filter").keyup(storyFilter);
  }
}

function storyFilter(){
  $('#storiesContainer').find(".story").each(function(story_cell){
    var story_id = $(this).attr("id").split("_")[1];
    hideStoryRow(story_id);
    $(this).find(".indexcardContent p").each(function(task){
      var task_filter = new RegExp($('#story_filter').val(), "i");
      if ($(this).html().match(task_filter)){
        showStoryRow(story_id);
        return false;
      }
    });
  })

 if (storyFilter != null){
   $.post(
     "/filters",
     {text_filter: $('#story_filter').val(),
      board_id: board_id},
      function(data){ 
        var ok = data;
      }
   );
 }
}


function hideStoryRow(id){
  $('#priorityLink_' + id).attr('src', '/images/priorityLinkClosed.jpg');
  $('#story_' + id + '_row').hide();
}

function showStoryRow(id){
  $('#priorityLink_' + id).attr('src', '/images/priorityLink.jpg');
  $('#story_' + id + '_row').show();
}

function activateBoardFilter(){
  if ($("#clear_filter").length > 0) {
    $('#clear_filter').bind("click", function(){
      $("#board_filter").attr("value", "");
      boardFilter();
    });
  }

  if ($("#board_filter").length > 0) {
    $("#board_filter").bind("keyup", boardFilter);
  }
}

function boardFilter(){
  $('#boards').find(".board").each(function(board){
    $(this).find(".boardLEFT p").each(function(text){
      $(this).closest(".board").hide();
      var task_filter = new RegExp($('#board_filter').val(), "i");
      if ($(this).html().match(task_filter)){
        $(this).closest(".board").show();
        return false;
      }
    });
  });
}

function bindDraggableTasks(){
  $('.draggable').each(function(task){
    $(this).draggable({
      revert: 'invalid',
      handle: '.moveTask'
    });
  });

  $('.droppable').each(function(column){
    $(this).droppable({
     hoverClass: 'ui-state-active',
     accept: '#' + $(this).closest(".story").attr("id") + ' .draggable',
     drop: function(ev, ui) {
       var parent_id = $(this).attr('id').split('_')[1];
       var task_id = ui.draggable.attr('id').split('_')[1];
       var status_id = $(this).attr('id').split('_')[2];
       app.runRoute('put', '#/stories/' + parent_id + '/tasks/' + task_id,
               {'element[status_id]': status_id })
     }
    });
  });
}


function setBoardTotalStoryPoints(board_id){
  var sum = 0.0;
  $$('.points').each(function(div){
    sp = parseFloat(div.innerHTML);
    if( !isNaN(sp))
      sum += sp;
  });
  $('total_story_points_' + board_id).innerHTML = '<p>' + sum + '<p>'
}

function bindBoardTitleDefault()
{
  if ($('#element_title').length > 0)
    {
      var date = new Date();
      var day = date.getDate();
      if (day < 10)
        day = "0" + day;
      $('#element_title').example("My Board - " + date.getFullYear() + "/" + (date.getMonth() + 1 )+ "/" + day);
    }
}

function bindHistoryDropdown(){

  //dropdown history
    $(".dropdown dt a").click(function() {
        $(".dropdown dd ul").slideDown("slow");
    });

    $(".dropdown dd ul li a").click(function() {
        var text = $(this).html();
        $(".dropdown dt a span").html(text);
        $(".dropdown dd ul").slideUp("slow");

    });

    function getSelectedValue(id) {
        return $("#" + id).find("dt a span.value").html();
    }

    $(document).bind('click', function(e) {
        var $clicked = $(e.target);
        if (! $clicked.parents().hasClass("dropdown"))
            $(".dropdown dd ul").hide();
    });
  ////////////////
}
