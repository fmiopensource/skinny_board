function(doc){
  if(doc.level == 0 && doc._id == doc.parent_id){
    emit(doc._id, doc.users)
  }
}
