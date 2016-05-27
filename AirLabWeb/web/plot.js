function cleanUp(theId){
//Old way
				/*
var cleanUp = document.getElementsByTagName("svg");
				for (index = 0; index < cleanUp.length; index++) {
				    cleanUp[index].parentNode.removeChild(cleanUp[index]);
				}
*/
				//New way of cleaning up
	var svgPrev = document.getElementById(theId);
	while (svgPrev.firstChild) {
		svgPrev.removeChild(svgPrev.firstChild);
	}
}

function paperToolTip(){
	var prevToolTip = document.getElementById("tooltip");
	if(prevToolTip)prevToolTip.parentNode.removeChild(prevToolTip);

	return d3.select("body")
				.append("div")
				.style("position", "absolute")
				.style("z-index", "10")
				.style("visibility", "hidden")
				.style("width", "300px")
				.style("background-color", "white")
				.attr("id", "tooltip");
}

function prepareNodes(aXesCount, objectsToProcess, variableRadius, variableXAxis, variableYAxis, variableColor){

	//console.log(objectsToProcess);
	var nodes = d3.range(objectsToProcess.length).map(function(index) { 
        		//console.log(index+' '+objectsToProcess[index]);
        		var dic = {};
        		dic.figureType = 'circle';
        		dic.radius = objectsToProcess[index][variableRadius]?objectsToProcess[index][variableRadius]:5;
        		dic.widthX = objectsToProcess[index][variableXAxis]?parseFloat(objectsToProcess[index][variableXAxis]):0;
        		dic.heightY = objectsToProcess[index][variableYAxis]?parseFloat(objectsToProcess[index][variableYAxis]):0;
        		dic.yAxisLabel = variableYAxis;
        		dic.xAxisLabel = variableXAxis;
        		dic.radiusLabel = variableRadius;
        		//dic.color = parseInt(objectsToProcess[index].tubFinishedBy)>0?0:2;
        		dic.color = objectsToProcess[index][variableColor]?parseInt(objectsToProcess[index][variableColor]):0;
        		
        		return dic; 
        	});
		color = d3.scale.category10();
		
		return nodes;
}

function addRadiusLegend(radiusLabel, variableRadius, data, theId){
	if(parseInt(variableRadius) > 2 && data.length > 0){
	
		var legendBox = d3.select("#"+theId)
			.append("svg").attr("width", 200).attr("height", 62).style({'float': 'left'});
		legendBox.append("circle").attr("r", 30).attr("cx", 31).attr("cy", 31).style({'stroke': 'black','stroke-width': 1, 'fill':'white'});
		legendBox.append("circle").attr("r", 20).attr("cx", 31).attr("cy", 21).style({'stroke': 'black', 'stroke-width': 1, 'fill':'white'});
		legendBox.append("circle").attr("r", 10).attr("cx", 31).attr("cy", 11).style({'stroke': 'black', 'stroke-width': 1, 'fill':'white'});
		
		legendBox.append("text")
		.attr("transform", "translate(70, 30)")
		.text(radiusLabel);
	}
}

function addAxes(data, nodes, variableXAxis, variableYAxis, svg, width, height){
	//X and Y axes	
				var margin = 120;
							
				var valsX = [];
				var valsY = [];
				for(var i = 0; i<nodes.length; i++){
					valsX.push(nodes[i].widthX);	
					valsY.push(nodes[i].heightY);
				}
                var minX = d3.min(valsX);
                var maxX = d3.max(valsX);
                var minY = d3.min(valsY);
                var maxY = d3.max(valsY);
                
                var xscale = d3.scale.linear().domain([minX, maxX]).range([margin, width-margin]);
                var yscale = d3.scale.linear().domain([minY, maxY]).range([height - 65, 20]);
				
				if(parseInt(variableXAxis) != 0  && data.length > 0){
				
					var xAxis = d3.svg.axis().scale(xscale).orient("bottom").ticks(Math.min(maxX - minX, 10));
					var xAxisGroup = svg.append("g")
								.attr("class", "axis")
								.attr("transform", "translate(0,"+(height-60)+")")
                              .call(xAxis);	
                   svg.append("text")
				  			 .attr("text-anchor", "end")
				  			 .attr("x", width-margin-300)
				  			 .attr("y", height-20)
				  			 .text(variableXAxis);
				}
				
				if(parseInt(variableYAxis) != 0 && data.length > 0){

					var yAxis = d3.svg.axis().scale(yscale).orient("bottom").ticks(Math.min(maxY - minY, 10));
					var yAxisGroup = svg.append("g")
								.attr("class", "axis")
								.attr("transform", "translate(80, 0) rotate(90)")
                              .call(yAxis);	
                              
					svg.append("text")
					.attr("text-anchor", "end")
					.attr("y", 6)
					.attr("dy", ".75em")
					.attr("transform", "translate(40, 30) rotate(-90)")
					.text(variableYAxis);
				}
		return [xscale, yscale];
	
}

function plotArea(width, height, theId){
	//Plot area
	var svg = d3.select("#"+theId).append("svg")
			.attr("width", width)
			.attr("height", height)
			.style({"float": "center"});
	
	return svg;
}

function applyForce(nodes, width, height, variableXAxis, variableYAxis){
	//Force Don't apply with axis
	var force = d3.layout.force()
		.gravity(0.1)
		.charge(function(d, i) { return -50; })
		.nodes(nodes)
		.size([width, height]);
	if(parseInt(variableXAxis) === 0 && parseInt(variableYAxis) === 0)
	force.start();
	
	return force;
}	

function dragF(width, height){
	var drag1 = d3.behavior.drag()
    .on("drag", function(d,i) {
    	d3.select(this)
    	.attr("cx", function(d,i){
    		var value = d3.mouse(this)[0];
    		if(value < 0 ) value = 0;
    		if(value > width) value = width;
            return value;
        })
        .attr("cy", function(d, i){
	        var value = d3.mouse(this)[1];
    		if(value < 0 ) value = 0;
    		if(value > height) value = height;
            return value;
        })
    });
    return drag1;
}

function draw(nodes, data, tooltip, force, variableXAxis, variableYAxis, svg, xscale, yscale, width, height){
	//Then circles, with mouse on functions
				var drag = dragF(width, height);
				
				svg.selectAll(nodes[0].figureType)
				.data(nodes)
				.enter().append(nodes[0].figureType)
				.attr("cx", function(d, i) { 
						return xscale(d.widthX);						
				  })
				.attr("cy", function(d, i) { 
						return yscale(d.heightY);	

				  })
				.attr("r", function(d, i) {return d.radius;})//{ return d.numberOfAuthors;})
				.attr("x", function(d, i) {return xscale(d.widthX);})//For rect only
				.attr("y", function(d, i) {return yscale(d.heightY);})//For rect only
				.attr("height", function(d, i) {return yscale(d.heightBar);})//For rect only
				.attr("width", function(d, i) {return d.widthBar;})//For rect only
				.on("mouseover", function(d, i) {      
					d3.select(this).transition()        
					.duration(200)      
					.style("opacity", 1);
					
					var obj = data[i];
					var string = '<div style = "padding: 10px;background-color:#eeeeee">';
					for(var i in obj){
						string = string + i + ': ' + obj[i] + '<br>';
					}
					string = string +'</div>'; 
					tooltip.html(string);
					
					return tooltip.style("visibility", "visible");
				})
				.on("mousemove", function(d, i) {      
					
					return tooltip.style("top", (d3.event.pageY+10)+"px").style("left",(d3.event.pageX-150)+"px");      
				})
				.on("mousedown", function(d, i) {      
					
					return tooltip.style("visibility", "hidden");      
				})
				.on("mouseout", function(d, i) {  
					    
					d3.select(this).transition()        
					.duration(200)      
					.style("opacity", .5);					
					
					return tooltip.style("visibility", "hidden");      
				})
				.on("mouseup", function(d,i) {
					//d3.select(this)
					//.attr("cx", function(d,i){
					//	return d3.select(this).attr("x");
					//})
					//.attr("cy", function(d,i){
					//	return d3.select(this).attr("y");
					//})
				})
				.on("dblclick", function(d, i) {   
					//window.location.assign("http://www.ncbi.nlm.nih.gov/pubmed/"+data[i].sciPubmedID, '_blank');
					window.open("http://www.ncbi.nlm.nih.gov/pubmed/"+data[i].sciPubmedID, '_blank');
				})               
				.style("fill", function(d, i) { return color(d.color);})//(i % 10); })
				.attr('opacity', 0.2)
				.call(force.drag)
				.call(drag);
}	

function plotWithDataRadiusXYAndColor(data, variableRadius, variableXAxis, variableYAxis, variableColor, theId){
				
		cleanUp(theId);
		
		if(data.length == 0)return;
		
		//var width = window.innerWidth * 0.8,
		//height = 470;

		var width = $("#"+theId).width();
		var height = $("#"+theId).height();		
			
		//Here I do all the mapping, and transfer scales here too
		var aXesCount = parseInt(variableXAxis)+parseInt(variableYAxis);//Pick only 40 nodes for random sampling
		var objectsToProcess = aXesCount!=0?data.length:Math.min(40, data.length); 
		var subArray = [];
		if(aXesCount == 0){
			for(var i = 0; i<objectsToProcess; i++){
				subArray.push(data[Math.floor(Math.random()*data.length)]);
			}
		}
		
		var nodes = prepareNodes(aXesCount, data, variableRadius, variableXAxis, variableYAxis, variableColor);
		//console.log(nodes);
		addRadiusLegend(nodes[0].radiusLabel, variableRadius, data, theId);
		var svg = plotArea(width, height, theId);
		var force = applyForce(nodes, width, height, variableXAxis, variableYAxis);												
		var scales = addAxes(data, nodes, variableXAxis, variableYAxis, svg, width, height);
		var xscale = scales[0];
		var yscale = scales[1];				
		
		var tooltip = paperToolTip();
		draw(nodes, data, tooltip, force, variableXAxis, variableYAxis, svg, xscale, yscale, width, height);
		
		

/*
		d3.selectAll("circle").style("fill", function() {
			return "hsl(" + Math.random() * 360 + ",100%,50%)";
		});
*/

		if(parseInt(variableXAxis) === 0 && parseInt(variableYAxis) === 0){
			force.on("tick", function(e) {
				var q = d3.geom.quadtree(nodes),
				i = 0,
				n = nodes.length;
	
				while (++i < n) q.visit(collide(nodes[i]));
				
				svg.selectAll("circle")
				.attr("cx", function(d) { return d.x; })
				.attr("cy", function(d) { return d.y; });
			});
		}
		

		//Play
		/*
svg.on("mousemove", function() {
		  var p1 = d3.mouse(this);
		  root.px = p1[0];
		  root.py = p1[1];
		  force.resume();
		});
*/
		

		function collide(node) {
			var r = node.radius + 16,
			nx1 = node.x - r,
			nx2 = node.x + r,
			ny1 = node.y - r,
			ny2 = node.y + r;
			return function(quad, x1, y1, x2, y2) {
				if (quad.point && (quad.point !== node)) {
					var x = node.x - quad.point.x,
					y = node.y - quad.point.y,
					l = Math.sqrt(x * x + y * y),
					r = node.radius + quad.point.radius;
					if (l < r) {
						l = (l - r) / l * .5;
						node.x -= x *= l;
						node.y -= y *= l;
						quad.point.x += x;
						quad.point.y += y;
					}
				}
				return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
			};
		};
}