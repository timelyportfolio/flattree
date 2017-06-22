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
  arr.forEach(function(d,i) {
    if(
      cols.reduce(
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
  return (Object.keys(list).indexOf('key') > -1 && Object.keys(list).indexOf('values') > -1)
}

function recurse(list, hier_cols) {
  if(is_leaf(list)) {
    // key 'null' is indicator of data values
    var idx = find_null_key(list.values);
    // if we find 'null' key then promote data and remove 'null' item
    if(idx > -1) {
      list.data = get_leaf_data(list.values[idx]);
      list.values.splice(idx,1);
      list.values.map(function(x) {recurse(x,hier_cols);});
    } else {
      idx = find_null_item(list.values, hier_cols);
      if(idx > -1) {
        list.data = list.values[idx];
        list.values.splice(idx,1);
        list.values.map(function(x) {recurse(x,hier_cols);});
      }
    }
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

  dn.map(function(x) {recurse(x,hier_cols);});
  var dh = d3Hierarchy.hierarchy({key:'root', values:dn}, function(d) {return d.values});
  
  dh.each(function(d) {
    if(d.data.data) {
      d.data = d.data.data;
    }
  });

  delete dh.data;
  dh.data = {};

  return dh;
};

exports.flattree = flattree;

Object.defineProperty(exports, '__esModule', { value: true });

})));
