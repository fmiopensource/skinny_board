function(doc){
  if(doc.level == 0 && doc._id == doc.parent_id){
    doc.burndown && doc.burndown.forEach(function(point){
      emit(point.key, point.value);
    });
  }
}
