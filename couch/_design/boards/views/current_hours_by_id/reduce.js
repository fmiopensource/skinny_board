function(keys, values, rereduce) {
  var output = {
    story_points:0,
    hours:0
  };
  
  for (idx in values) {
    if(values[idx].story_points > 0)
      output.story_points += values[idx].story_points;
    if(values[idx].hours > 0)
      output.hours += values[idx].hours;
  }
  
  return output;
}
