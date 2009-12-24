function(doc){
  if( (doc.level == 0 || doc.level == 3) && doc.parent_id == doc._id){
    emit(doc._id, doc._rev);
  }
}