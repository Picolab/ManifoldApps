ruleset io.picolabs.weather {
  meta {
    shares __testing, getCurrent, getData
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "getCurrent" }
      , { "name": "getData" }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    
    //getCurrent = function() {
      //http:get("https://manifold.picolabs.io:9090/sky/cloud/NDUTywTKJwDH5Y9wdgXUoo/com.example.weather/getCurrent"){"content"}.decode()
    //}
    
    getData = function() {
      http:get("https://manifold.picolabs.io:9090/sky/cloud/NDUTywTKJwDH5Y9wdgXUoo/com.example.weather/getData"){"content"}.decode()
    }
    
    app = { "name" : "Weather", "version" : "0.0" };
    bindings = function(){
      {
        //currently no bindings
      };
    }
  }
  
  rule discovery { select when manifold apps send_directive("app discovered...", {"app": app, "rid": meta:rid, "bindings": bindings(), "iconURL": "https://image.flaticon.com/icons/svg/1802/1802025.svg"} ); }
}
