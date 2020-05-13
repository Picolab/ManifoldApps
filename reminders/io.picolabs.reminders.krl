ruleset io.picolabs.reminders {
  meta {
    shares __testing, schedule, reminders, timestampCompare, time
    use module io.picolabs.wrangler alias Wrangler
    use module io.picolabs.subscription alias sub
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "schedule" }
      , { "name": "reminders" }
      , { "name": "time" }
      ] , "events":
      [  { "domain": "reminder", "type": "add_reminder", "attrs": [ "message" ] }
      , { "domain": "reminder", "type": "remove_reminder", "attrs": [ "id" ] }
      ]
    }
    
    app = {"name":"reminders","version":"0.0"/* img: , pre: , ..*/};
    bindings = function(){
      {
        //currently no bindings
      };
    }
    
    time = function() {
      time:now();
    }
    
    schedule = function () {
      schedule:list();
    }
    
    reminders = function() {
      ent:reminderStore.defaultsTo([]).filter(function(x) {
        timeHasNotPassed(x.values().head(){"time"})
      });
    }
    
    timeHasNotPassed = function(time2) {
      time1 = time:now();
      year1 = time1.substr(0,4).as("Number");
      month1 = time1.substr(5,2).as("Number");
      day1 = time1.substr(8,2).as("Number");
      hour1 = time1.substr(11,2).as("Number");
      minute1 = time1.substr(14,2).as("Number");
      second1 = time1.substr(17,2).as("Number");
      millisecond1 = time1.substr(20,3).as("Number");
      timeMs1 = year1 * 32140800000 + month1 * 2678400000 + day1 * 86400000
        + hour1 * 3600000 + minute1 * 60000 + second1 * 1000 + millisecond1;
      
      year2 = time2.substr(0,4).as("Number");
      month2 = time2.substr(5,2).as("Number");
      day2 = time2.substr(8,2).as("Number");
      hour2 = time2.substr(11,2).as("Number");
      minute2 = time2.substr(14,2).as("Number");
      second2 = time2.substr(17,2).as("Number");
      millisecond2 = time2.substr(20,3).as("Number");
      timeMs2 = year2 * 32140800000 + month2 * 2678400000 + day2 * 86400000
        + hour2 * 3600000 + minute2 * 60000 + second2 * 1000 + millisecond2;
      
      timeMs2 > timeMs1
    }
  }
  
  rule discovery { select when manifold apps send_directive("app discovered...", {"app": app, "rid": meta:rid, "bindings": bindings(), "iconURL": "https://image.flaticon.com/icons/svg/1182/1182714.svg"} ); }
  
  rule add_reminder {
    select when reminder add_reminder
    
    pre {
      time = time:add(time:new(event:attr("time")), {"hours" : 6 });
      message = event:attr("message");
      title = event:attr("title");
    }
    
    if time && message then noop();
    
    fired {
      schedule reminder event "notify" at time attributes event:attrs.put("time", time);
      raise reminder event "store_reminder" attributes event:attrs.put("time", time);
    }
  }
  
  rule remove_reminder {
    select when reminder remove_reminder
    
    pre {
      id = event:attr("id");
    }
    
    if id then schedule:remove(id);
    
    fired {
      ent:reminderStore := ent:reminderStore.filter(function(x) {
        x.keys().head() != id
      })
    }
  }
  
  rule store_reminder {
    select when reminder store_reminder
    
    pre {
      time = event:attr("time");
      message = event:attr("message");
      title = event:attr("title");
      id = schedule:list().filter(function(x) {
        x{"at"} == time
      }).head(){"id"}.klog("id");
      reminder = {}.put(id, {"time" : time, "message" : message, "title" : title})
    }
    
    if time && message && id then noop();
    
    fired {
      ent:reminderStore := ent:reminderStore.defaultsTo([]).append(reminder)
    }
    
  }
  
  rule notify {
    select when reminder notify
    
    pre {
      message = event:attr("message");
      toSend = sub:established().filter(function(x) {
        x{"Tx_role"} == "manifold_pico"
      }).head(){"Tx"}.klog(toSend);
      picoId = meta:picoId;
      app = "Reminder";
      rid = meta:rid;
      name = Wrangler:name();
      attrs = { 
        "picoId" : picoId,
        "thing" : name,
        "app" : app,
        "message" : message,
        "ruleset" : rid
      }
    }
    
    if picoId && app && rid && name && message && toSend then 
      event:send({ "eci" : toSend, "domain" : "manifold", "type" : "add_notification", "attrs" : attrs})
    
  }
}
