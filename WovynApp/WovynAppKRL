ruleset io.picolabs.wovynApp {
  meta {
    name "Manifold WovenApp"
    description <<
        Provides basic Wovyn device shadow for a pico.
    >>
    author "TEDRUB"
    shares __testing, tile
  }
  global {
    // ---------- Manifold Configuration/Dependencies 
    app = { "name":"woven",
            "version":"0.0", 
            "img":"https://www.google.com/url?sa=i&rct=j&q=&esrc=s&source=images&cd=&cad=rja&uact=8&ved=0ahUKEwiU7I3fy-bWAhUkxVQKHZB9C_kQjRwIBw&url=https%3A%2F%2Fangel.co%2Fwovyn&psig=AOvVaw3dPAw4DnQChcEx5KCvoO2x&ust=1507743301206369"
            /*pre: , ..*/};
    jsx = "
          <div className={'my-pretty-chart-container'}>
            <Chart
              chartType='ScatterChart'
              data={[['Age','Weight'], [8,12], [4,5.5]]}
              options={{}}
              graph_id='ScatterChart'
              width='100%'
              height='400px'
              legend_toggle
            />
          </div>
          ";
    tile = function() {
      jsx;
    }
    // ---------- 
    __testing = { "queries": [ { "name": "__testing" }
                             ]
                , "events": [ { "domain": "example", "type": "example", "attrs": [ "example" ] }
                            ]
                }

  }
  // ---------- Manifold required API event calls  
  rule discovery { select when manifold apps send_directive("app discovered...", {"app": app, "rid": meta:rid, "tile": tile()}); }
  rule tile { select when manifold tile send_directive("retrieved tile ", {"app": tile()}); }
  // ---------- 

  // ---------- woven rules 
  rule initialize { // when app installed......
    select when wrangler ruleset_added where rids >< meta:rid noop() 
  }

  // ---------- 
}
