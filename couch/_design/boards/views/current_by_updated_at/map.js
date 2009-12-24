function(doc){
  if( (doc.level == 0 || doc.level == 3) && doc.parent_id == doc._id){
    doc.users.forEach(function(user){
      emit([user.id, doc._id, Date.parse(doc.updated_at)], {
        title: doc.title,
        description: doc.description,
        hours: doc.hours,
        story_points: doc.story_points,
        start_date: doc.start_date,
        end_date: doc.end_date,
        updated_at: doc.updated_at,
        level: doc.level,
        story_points: doc.story_points,
        hours: doc.hours
      });
    });
  }
}
