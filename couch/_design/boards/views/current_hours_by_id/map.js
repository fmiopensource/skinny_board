function(doc){
  if(doc.level == 0 && doc.parent_id == doc._id){
    doc.stories && doc.stories.forEach(function(story){
      emit([doc._id, story.id, 0], {
        story_points: story.story_points,
        hours: 0
      });
      story.tasks && story.tasks.forEach(function(task){
				if (task.status_id != 4) { // don't include hours for completed tasks
						emit([doc._id, story.id, task.id], {
							story_points: 0,
							hours: task.hours
						});
				}
      });
    });
  }
}
