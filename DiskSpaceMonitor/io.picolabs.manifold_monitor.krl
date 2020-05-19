ruleset io.picolabs.manifold_monitor {
  meta {
    shares __testing, info, getDiskSpaceSub
    use module io.picolabs.wrangler alias Wrangler
    use module io.picolabs.subscription alias sub
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "info" }
      , { "name": "getDiskSpaceSub" }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    THRESHOLD = 90
    info = function() {
      Wrangler:skyQuery(getDiskSpaceSub(){"Tx"}, "io.picolabs.manifold.disk_space_monitor", "info")
    }
    getDiskSpaceSub = function() {
      sub:established().filter(function(x) {
        x{"Tx_role"} == "disk_space_monitor"
      }).head()
    }
    app = { "name" : "Manifold Monitor", "version" : "0.0" };
    bindings = function(){
      {
        //currently no bindings
      };
    }
  }
  rule init {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    event:send({
      "eci": "W1h8HB7RkQBKBRDJDvE1QM", "eid": "subscription",
          "domain": "wrangler", "type": "subscription",
          "attrs": {
             "name"        : Wrangler:name(),
             "picoID"      : meta:picoId,
             "Rx_role"     : "disk_space_monitor",
             "Tx_role"     : "manifold_monitor",
             "Tx_Rx_Type"  : "Manifold_Monitor",
             "channel_type": "Manifold",
             "wellKnown_Tx": meta:eci,
             "Tx_host"     : meta:host
           }
    })
    fired {
      ent:disk := ent:disk.defaultsTo({});
      ent:threshold_violations := ent:threshold_violations.defaultsTo({})
    }
  }
  rule autoAcceptSubscriptions {
    select when wrangler inbound_pending_subscription_added 
      where Tx_Rx_Type == "Manifold_Monitor" || event:attr("rs_attrs"){"Tx_Rx_Type"} == "Manifold_Monitor"
    always {
      raise wrangler event "pending_subscription_approval" attributes event:attrs.klog("sub attrs"); // Simplified and idiomatic subscription acceptance
    }
  }
  
  rule discovery { 
    select when manifold apps 
    send_directive("app discovered...", 
      {
        "app": app, 
        "rid": meta:rid, 
        "bindings": bindings(), 
        "iconURL": "https://manifold.picolabs.io/favicon.png"
      }
    ); 
  }
  
  rule received_threshold_violation {
    select when manifold_monitor threshold_violation
    pre {
      toSend = sub:established().filter(function(x) {
        x{"Tx_role"} == "manifold_pico"
      }).head(){"Tx"}.klog("ECI to send notification");
      picoId = meta:picoId;
      app = app{"name"};
      rid = meta:rid;
      name = Wrangler:name();
      message = event:attr("message");
      attrs = { 
        "picoId" : picoId,
        "thing" : name,
        "app" : app,
        "message" : message,
        "ruleset" : rid
      }
    }
    
    event:send({ "eci" : toSend, "domain" : "manifold", "type" : "add_notification", "attrs" : attrs})
    fired {
      ent:threshold_violations{date} := event:attr(data)
    }
  }
}
