## Purpose

`flattree` converts a tree in flat table form into a [`d3-hierarchy`](https://github.com/d3/d3-hierarchy).

## Reason

In the R package [`d3r`](https://github.com/timelyportfolio/d3r), I have a converter to go from `data.frame` to `d3-hierarchy`.  Recently, I needed this functionality all in JavaScript to hack a hierarchical sort into `datatables`.

## Example

Below are some very simplified examples.

### tree as array of arrays

```
d3.flattree([["A",null],["A","A.1",20],["A","A.2",30]], [0,1])
```

### tree as array of objects

```
d3.flattree(
  [
    {grp:"A"},
    {grp:"A", subgrp:"A.1", value:20},
    {grp:"A", subgrp:"A.2", value:30}
  ],
  ["grp", "subgrp"]
)
```

### live use for treemap

[bl.ocks](https://bl.ocks.org/timelyportfolio/24ee2544ba12c8b7dedf4a472fb784de)