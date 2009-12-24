function(doc){
  if((doc.level == 0 || doc.level == 3) && doc.parent_id == doc._id){
    for (i=0; i < doc.stories.length; i++)
      emit([doc._id,doc.stories[i].position],[doc.stories[i].id, doc.stories[i]]);
  }
}