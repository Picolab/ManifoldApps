ruleset auroraAccess {
  meta {
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "hello", "type": "world" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
  }
  
  rule setRegisteredFlag {
    select when owner no_such_owner_id
    
    fired {
      ent:newSub := true;
    }
  }
  
  rule pollIfNewSub {
    select when auroraPoll newSub
    
    send_directive("newSub", {"value": ent:newSub });
    fired {
      ent:newSub := false;
    }
  }
  
  rule intialization {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    
    always {
      ent:newSub := false;
    }
  }
}
