d3.csv("country_data.csv").then(showData);

function showData(data) {
  // filter countries with only $1B + or - net donations
  data = data.filter((d, i, e) => i < 10 || i > e.length - 1 - 10);

  let config = getBarChartConfig();
  let scales = getBarChartScales(data, config);

  drawAxes(data, scales, config);
  drawBars(data, scales, config);
}

function getBarChartConfig() {
  let width = 500;
  let height = 600;
  let margin = {
    top: 30,
    bottom: 20,
    left: 10,
    right: 10,
  };

  let bodyHeight = height - margin.top - margin.bottom;
  let bodyWidth = width - margin.left - margin.right;

  let container = d3.select("#chart1");
  container.attr("width", width).attr("height", height);

  return { width, height, margin, bodyHeight, bodyWidth, container };
}

function getBarChartScales(data, config) {
  let { bodyHeight, bodyWidth } = config;
  let max = d3.max(data, (d) => +d.net_donations);
  let min = d3.min(data, (d) => +d.net_donations);
  let y0 = Math.max(Math.abs(min), Math.abs(max));

  let xScale = d3.scaleLinear().range([0, bodyWidth]).domain([-y0, y0]);

  let yScale = d3
    .scaleBand()
    .range([0, bodyHeight])
    .domain(data.map((d) => d.country))
    .padding(0.2);

  return { xScale, yScale };
}

function drawBars(data, scales, config) {
  let { margin, container } = config;
  let { xScale, yScale } = scales;
  let body = container
    .append("g")
    .style("transform", `translate(${margin.left}px, ${margin.top}px)`);

  let bars = body.selectAll(".bar").data(data);

  bars
    .enter()
    .append("rect")
    .attr("height", yScale.bandwidth())
    .attr("x", (d) => xScale(Math.min(0, d.net_donations)))
    .attr("y", (d) => yScale(d.country))
    .attr("width", (d) => Math.abs(xScale(d.net_donations) - xScale(0)))
    .attr("class", "bar")
    .style("fill", (d) => {
      return d.net_donations > 0 ? "#1f77b4" : "#ff7f0e";
    })
    .on("mouseover", function (event, d) {
      showTooltip(d3.format("$0.2s")(d.net_donations).replace(/G/, "B"), [
        event.pageX,
        event.pageY,
      ]);
    })
    .on("mousemove", function (event) {
      d3.select("#tooltip")
        .style("top", event.pageY - 10 + "px")
        .style("left", event.pageX + 10 + "px");
    })
    .on("mouseout", function () {
      d3.select("#tooltip").style("visibility", "hidden");
    });
}

function showTooltip(text, coords) {
  d3.select("#tooltip")
    .text(text)
    .style("top", coords[1] + "px")
    .style("left", coords[0] + "px")
    .style("visibility", "visible");
}

function drawAxes(data, { xScale, yScale }, { margin }) {
  let yAxis = d3.axisLeft(yScale);
  let xAxis = d3
    .axisTop(xScale)
    .ticks(5)
    .tickFormat((d) => d3.format("$0.1s")(d).replace(/G/, "B"));

  d3.select("#xAxis")
    .attr("transform", `translate(${margin.left},${margin.top})`)
    .call(xAxis);

  gYAxis = d3
    .select("#yAxis")
    .attr("transform", `translate(${xScale(0) + margin.left}, ${margin.top})`)
    .call(yAxis);

  setYAxisOrientation(data, gYAxis, (d) => d.net_donations < 0);
}

function setYAxisOrientation(data, yAxisGroup, reverseDirection) {
  let textAnchor = yAxisGroup.attr("text-anchor");
  let reverseTextAnchor = textAnchor == "start" ? "end" : "start";
  yAxisGroup.selectAll(".tick").each(function (d, i) {
    let tick = d3.select(this);
    let tickSize = tick.select("line").attr("x2");
    let tickTextX = tick.select("text").attr("x");
    tick
      .attr(
        "text-anchor",
        reverseDirection(data[i]) ? reverseTextAnchor : textAnchor
      )
      .select("line")
      .attr("x2", reverseDirection(data[i]) ? -tickSize : tickSize);
    tick
      .select("text")
      .attr("x", reverseDirection(data[i]) ? -tickTextX : tickTextX);
  });
}
