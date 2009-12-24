function(doc){
  if((doc.level == 0 || doc.level == 3) && doc.parent_id == doc._id){
    doc.stories && doc.stories.forEach(function(story){

      emit([doc._id, story.id], story);
    });
  }
}
