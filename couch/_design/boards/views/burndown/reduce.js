function(keys, values, rereduce) {

 rv = {hh:-1, mm:-1, ss:-1, hours: null}
 for (i=0; i<values.length; ++i) {
    var value = values[i];
    if( value.hh > rv.hh ||
       (value.hh == rv.hh && value.mm > rv.mm) ||
       (value.hh == rv.hh && value.mm == rv.mm && value.ss > rv.ss)){
     rv.hh = value.hh;
     rv.mm = value.mm;
     rv.ss = value.ss;
     rv.hours = 0;
    }

    if (value.hh == rv.hh && value.mm == rv.mm && value.ss == rv.ss){
     rv.hours += value.hours
    }
 }
 return rv;
}