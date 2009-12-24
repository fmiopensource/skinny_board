function(doc){
  if(doc.level == 0){
    var date = new Date(doc.updated_at)
    doc.stories && doc.stories.forEach(function(story){
      story.tasks && story.tasks.forEach(function(task){
        emit([doc.parent_id, date.getFullYear(),
          date.getMonth(),date.getDate()], {
          hh:date.getHours(), mm:date.getMinutes(),
          ss:date.getSeconds(), hours:task.hours
        });
      });
    });
  }
}
