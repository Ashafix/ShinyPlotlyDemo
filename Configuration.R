appDir <- "C:/Users/mpeters/Documents/TestObservers"

jsHighLightPoint <- '
var el = document.getElementsByClassName("js-plotly-plot")[{plotNo}];
var highlight_trace = el.data.length -1;
var newPoint = {x: {x},
                y: {y}
               };
if (el.data[highlight_trace].x[0] != newPoint.x || el.data[highlight_trace].y[0] != newPoint.y) 
{
  el.data[highlight_trace].x[0] = newPoint.x;
  el.data[highlight_trace].y[0] = newPoint.y;
  el.data[highlight_trace].visible = true;
  Plotly.redraw(el);
}'
  
  
  