# AidData

This bar chart is based on Mike Bostock's [Bar Chart](https://observablehq.com/@d3/bar-chart). The tooltip implementation and design is based on Jianan Li's [Basic Tooltip](https://observablehq.com/@jianan-li/basic-tooltip). The design of the chart was suggested by an exercise in Enrico Bertini and Cristian Felix's course [Information Visualization: Advanced Techniques](https://www.coursera.org/learn/information-visualization-advanced-techniques).

The dataset comes from the [AidData Core Research Release, Version 3.1](https://www.aiddata.org/data/aiddata-core-research-release-level-1-3-1). 

## Dynamic Axis Orientation Switching

For this chart, I wanted to implement axis orientation switching based on data. For values of net donations greater than zero, the country names appear on the left side of the y-axis. For values of net donations less than zero, the country names appear on the right side of the y-axis. Labels on the y-axis never interfer with the direction of the bars as they dynamically "dodge" them.

A version of this visualization can also be viewed at [https://observablehq.com/@toltman/aiddata-bar-chart](https://observablehq.com/@toltman/aiddata-bar-chart).

``setYaxisDirection`` is the function that dynamically switches the orientation of the y-axis.

The function takes 3 parameters, the data, the ``selection`` of the y-axis group and a function. The function will receive your data element and should return ``true`` if you want the orientation of this tick to be reversed. In my implementation I wanted the axis reversed if the net donations for this country was less than zero. Therefore, I passed 
```
d => d.net_donations < 0
```
as my argument.
