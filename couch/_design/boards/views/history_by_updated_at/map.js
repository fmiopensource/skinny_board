function(doc) {
  emit([doc.parent_id, Date.parse(doc.updated_at)], {
     date: doc.updated_at
  });
}