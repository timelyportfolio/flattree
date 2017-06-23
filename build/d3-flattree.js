(function (global, factory) {
	typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('d3-hierarchy'), require('d3-collection')) :
	typeof define === 'function' && define.amd ? define(['exports', 'd3-hierarchy', 'd3-collection'], factory) :
	(factory((global.d3 = global.d3 || {}),global.d3,global.d3));
}(this, (function (exports,d3Hierarchy,d3Collection) { 'use strict';

function find_null_key(arr) {
  var idx = -1;
  arr.forEach(function(d, i) {
    if(d.key === 'null') {
      idx = i;
    }
  });
  return idx;
}

function find_null_item(arr, cols) {
  var idx = -1;
  if(Object.keys(arr[0]).indexOf('values') > -1) {return idx;}
  arr.forEach(function(d,i) {
    if(
      cols.slice(0, cols.length - 1).reduce(
        function(left, right) {
          left.push(d[right] || null);
          return left;
        },
        []
      ).filter(function(dd) {
        return dd === null;
      }).length > 0
    ) {
      idx = i;
    }
  });
  return idx;
}

function get_leaf_data(arr) {
  if(Object.keys(arr).indexOf('key') > -1 && Object.keys(arr).indexOf('values') > -1) {
    return get_leaf_data(arr.values[0]);
  }
  return arr;
}

function is_leaf(list) {
  return (
    Object.keys(list).indexOf('key') > -1 &&
      Object.keys(list).indexOf('values') > -1
  );
}

function recurse(list, hier_cols, level) {
  if(is_leaf(list)) {
    // use this to track if data found
    var data_found = false;
    
    list.data = {};
    
    // if 'key' at node level then no data
    //   meaning no na/null for this node
    if(Object.keys(list).indexOf('key') > -1) {
      list.data.key = list.key;
    }
    
    var idx;
    
    if(!data_found) {
      // key 'null' is indicator of data values
      idx = find_null_key(list.values);
      // if we find 'null' key then promote data and remove 'null' item
      if(idx > -1) {
        list.data.values = get_leaf_data(list.values[idx]);
        list.data.key = list.key;
        list.values.splice(idx,1);
        data_found = true;
      }
    }
    
    if(!data_found) {
      idx = find_null_item(list.values, hier_cols, level);
      if(idx > -1) {
        list.data.values = list.values[idx];
        list.data.key = list.key;
        list.values.splice(idx,1);
        data_found = true;
      }
    }

    
    list.values.map( function(x) {
      recurse(x, hier_cols, level+1);
    });
  }
}

function promote(parent) {
  if(parent.depth === 0) {return}
  if(!parent.children) {return}

  var idx_null = parent.children.map(function(d,i){
    if(!d.data.key || d.data.key === 'null') {return i}
  }).filter(function(d){return d})[0];
  
  if(!idx_null) {return}
  
  parent.data.values = parent.children[idx_null].data.values;
  parent.children.splice(idx_null,1);
  if(parent.children.length === 0) {
    delete parent.children;
  }
}

var flattree = function(dat, hier_cols) {
  // if only one hier column given then duplicate
  //  for proper functionality
  if(!Array.isArray(hier_cols)) {
    hier_cols = [hier_cols];
  }
  var nester = hier_cols.slice(0,hier_cols.length-1).reduce(
    function(left,right) {
      return left.key(function(d){return d[right] ? d[right] : null});
    },
    d3Collection.nest()
  );
    
  var dn = nester.entries(dat);

  dn.map(function(x) {recurse(x,hier_cols,1);});
  var dh = d3Hierarchy.hierarchy(
    {key:'root', values:dn},
    function(d) {return d.values}
  );
  
  dh.eachAfter(function(d) {
    if(d.data.data) {
      d.data = d.data.data;
    } else {
      // at child and for consistency
      //  make data an object with key and values
      if(d.depth > 0) {
        var key = d.data[hier_cols.slice(d.depth - 1)];
        d.data = {
          key: key,
          values: d.data
        };
      }
    }
    
    // find children with key undefined and remove
    //  promote data to this level
    promote(d);
  });

  delete dh.data;
  dh.data = {};

  return dh;
};

exports.flattree = flattree;

Object.defineProperty(exports, '__esModule', { value: true });

})));
