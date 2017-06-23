library(htmltools)
library(d3r)

browsable(
  tagList(
    tags$script(
      HTML(paste0(readLines("./build/d3-flattree.js"), collapse="\n"))
    ),
    tags$script(HTML(
'
console.log(d3.flattree([["A",null],["A","A.1",20],["A","A.2",30]], [0,1]))
console.log(
  d3.flattree([
    {grp:"A"},
    {grp:"A", subgrp:"A.1", value:20},
    {grp:"A", subgrp:"A.2", value:30}
  ], ["grp", "subgrp"])
);
'   
    )),
    d3_dep_v4()
  )
)

library(treemap)
rhd <- random.hierarchical.data(children.root=2)

browsable(
  tagList(
    tags$script(
      HTML(paste0(readLines("./build/d3-flattree.js"), collapse="\n"))
    ),
    d3_dep_v4(),
    tags$script(HTML(
sprintf(
'
var dat_v = %s;
var dat_r = %s;
',
jsonlite::toJSON(rhd, dataframe="values"),
jsonlite::toJSON(rhd, dataframe="rows")
)
    ))
  )
)

browsable(
  tagList(
    tags$script(
      HTML(paste0(readLines("./build/d3-flattree.js"), collapse="\n"))
    ),
    tags$script(
      HTML(sprintf('var data=%s', jsonlite::toJSON(rhd, dataframe="rows"))
    )),
    tags$script(HTML(
'
var d3h = d3.flattree(data, ["index1","index2","index3"]);
d3h.sum(function(d) {
  return d.values ? d.values.x || 0 : 0;
});

var d3t = d3.treemap().size([400,400])(d3h);
var svg = d3.select("body").append("svg")
  .style("height", 400)
  .style("width", 400);

var cell = svg.selectAll("g")
  .data(d3t.leaves());

cell = cell.enter().append("g").merge(cell);

cell
  .attr("transform", function(d) { return "translate(" + d.x0 + "," + d.y0 + ")"; });
var color = d3.scaleOrdinal(d3.schemeCategory20);
cell.append("rect")
  .attr("id", function(d) { return "rect-" + d.id; })
  .attr("width", function(d) { return d.x1 - d.x0; })
  .attr("height", function(d) { return d.y1 - d.y0; })
  .style("fill", function(d) { return color(d.parent.data.key) });

'   
    )),
  d3_dep_v4()
  )
)


browsable(
  tagList(
    tags$div(
      style="width:50%; float:left;",
      DT::datatable(rhd, width="90%")
    ),
    tags$div(
      style="width:50%; float:left;",
      tag("svg", list(id="tree"))
    ),
    tags$script(
      HTML(paste0(readLines("./build/d3-flattree.js"), collapse="\n"))
    ),
    tags$script(
      HTML(sprintf('var data=%s', jsonlite::toJSON(rhd, dataframe="rows")))
    ),
    tags$script(HTML(
'
var d3h = d3.flattree(data, ["index1","index2","index3"]);
d3h.sum(function(d) {return d.x});

var d3t = d3.tree().size([500,350])(d3h);
var svg = d3.select("svg#tree")
  .style("height", 600)
  .style("width", 400);

var g = svg.append("g")
  .attr("transform", "translate(20,20)");


var node = g.selectAll(".node")
  .data(d3t.descendants())
  .enter().append("g")
    .attr("class", function(d) { return "node" + (d.children ? " node--internal" : " node--leaf"); })
    .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

node.append("circle")
  .attr("r", 2.5);
node.append("text")
  .style("text-anchor", "end")
  .style("font-size", "75%")
  .text(function(d) {
    return d.data.key; 
  })
node.append("path")
  .attr("d", )

'   
    )),
    d3_dep_v4()
  )
)

tm <- treemap(rhd, index=c('index1','index2','index3'), vSize='x')$tm

browsable(
  tagList(
    tags$script(
      HTML(paste0(readLines("./build/d3-flattree.js"), collapse="\n"))
    ),
    tags$script(
      HTML(sprintf('var data=%s', jsonlite::toJSON(tm, dataframe="rows"))
      )),
    tags$script(HTML(
      '
      var d3h = d3.flattree(data, ["index1","index2","index3"]);
      d3h.sum(function(d) {
        return d.values ? d.values.vSize || 0 : 0;
      });
      
      var d3t = d3.treemap().size([400,400])(d3h);
      var svg = d3.select("body").append("svg")
        .style("height", 400)
        .style("width", 400);
      
      var cell = svg.selectAll("g")
        .data(d3t.descendants().slice(0));
      
      cell = cell.enter().append("g").merge(cell);
      
      cell
      .attr("transform", function(d) { return "translate(" + d.x0 + "," + d.y0 + ")"; });
      var color = d3.scaleOrdinal(d3.schemeCategory20);
      cell.append("rect")
      .attr("id", function(d) { return "rect-" + d.id; })
      .attr("width", function(d) { return d.x1 - d.x0; })
      .attr("height", function(d) { return d.y1 - d.y0; })
      .style("fill", function(d) {
        return d.depth < 1 ? "none" : color(d.data.values.index1)
      })
      .style("stroke", "black");
      
      '   
    )),
  d3_dep_v4()
  )
)

dt1 = htmlwidgets::onRender(
  DT::datatable(tm[,1:4], option = list(paging=FALSE), width="90%"),
'
function(el,x) {
  $("tbody tr", el).on("mouseover", function() {
    var api = $("table", el).DataTable();
    var dat = api.row(this).data();
    var key_to_find = dat.slice(1,4)
      .reverse()
      .filter(function(d) {
        return d !== null;
      })[0];
    d3.selectAll("svg g.node").each(function(d) {
      if(d.data.key && d.data.key === key_to_find) {
        d3.select(this).style("fill", "red");
      }
    });
  })

  $("tbody tr", el).on("mouseout", function() {
    d3.selectAll(".node").style("fill", "");
  })
}
'
)




browsable(
  tagList(
    tags$style("table {font-size: 0.75em;} td {line-height:.75em;}"),
    tags$div(
      style="width:50%; float:left;",
      dt1
    ),
    tags$div(
      style="width:50%; float:left;",
      tag("svg", list(id="tree"))
    ),
    tags$script(
      HTML(paste0(readLines("./build/d3-flattree.js"), collapse="\n"))
    ),
    tags$script(
      HTML(sprintf('var data=%s', jsonlite::toJSON(tm, dataframe="rows")))
    ),
    tags$script(HTML(
      '
      var d3h = d3.flattree(data, ["index1","index2","index3"]);
      d3h.sum(function(d) {return d.x});
      
      var d3t = d3.tree().size([500,350])(d3h);
      var svg = d3.select("svg#tree")
      .style("height", 600)
      .style("width", 400);
      
      var g = svg.append("g")
      .attr("transform", "translate(20,20)");
      
      
      var node = g.selectAll(".node")
      .data(d3t.descendants())
      .enter().append("g")
      .attr("class", function(d) { return "node" + (d.children ? " node--internal" : " node--leaf"); })
      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });
      
      node.append("circle")
      .attr("r", 2.5);
      node.append("text")
      .style("text-anchor", "end")
      .style("font-size", "75%")
      .text(function(d) {
      return d.data.key; 
      })
      node.append("path")
      .attr("d", )
      
      '   
    )),
    d3_dep_v4()
  )
)
