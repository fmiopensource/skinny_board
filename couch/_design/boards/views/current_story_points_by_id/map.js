function(doc){
  if(doc.level == 0 && doc.parent_id == doc._id){
    doc.stories && doc.stories.forEach(function(story){
      emit([doc._id, story.id], story.story_points);
    });
  }
}
