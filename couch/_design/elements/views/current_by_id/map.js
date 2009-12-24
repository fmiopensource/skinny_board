function(doc){
  if(doc.level == 0 && doc.parent_id == doc._id){
    doc.stories && doc.stories.forEach(function(story){
      story.tasks && story.tasks.forEach(function(task){
        emit(task.id, task);
      });
      story.tasks = [];
      emit(story.id, story);
    });
  }
}
