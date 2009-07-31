package classes.datastructures
{
	/*
		© Rico Leuthold [rleuthold@access.ch] // 2009
		
		This program is free software: you can redistribute it and/or modify
	    it under the terms of the GNU General Public License as published by
	    the Free Software Foundation, either version 3 of the License, or
	    (at your option) any later version.
	
	    This program is distributed in the hope that it will be useful,
	    but WITHOUT ANY WARRANTY; without even the implied warranty of
	    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	    GNU General Public License for more details.
	
	    You should have received a copy of the GNU General Public License
	    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	*/
	
	import classes.helpers.DateHelpers;
	import classes.helpers.NodeBasedMeasures;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	/**
	 * The class acts as an intermediate between the <b><a href="http://code.google.com/p/birdeye/wiki/RaVis">RaVis</a></b> <code>IGraph</code> class
	 * an my own code.
	 * 
	 * <p>In more detail, it stores data states, xml configurations, graph data and so on, so that I'm able to switch between different components of a network.
	 * Component handling is not at all  implemented in <b>RaVis</b>.
	 */
	public class GraphData extends EventDispatcher
	{
		/**
		 * The xml data of the graph:
		 * 
		 * <p>The graph xml data has the following format:</p>
		 * 
		 * <pre><code>
		 * &lt;graph&gt;
		 *	  &lt;Node id="0006B8BEF1" sec="687608" sex="m"/&gt;
		 *	  &lt;Node id="0006CC7125" sec="33378" sex="f"/&gt;
		 *	  &lt;Node id="0006B8BFCF" sec="2907" sex="m"/&gt;
		 *	  
		 *	  &lt;Edge fromID="0006B8BEF1" toID="0006CC7125" sec="10000" count="42" thickness="1" strength="1"/&gt;
		 *	  &lt;Edge fromID="0006CC7125" toID="0006B8BFCF" sec="30000" count="28" thickness="5" strength="5"/&gt;
		 *	  &lt;Edge fromID="0006B8BFCF" toID="0006B8BEF1" sec="40000" count="33" thickness="10" strength="10"/&gt;
		 * &lt;/graph&gt;	
		 * </code></pre>
		 * 
		 * <p>Some explanations of the graph data format.</p>
		 * <ul>
		 * <p>The node names and attributes are <b>cases sensitive</b>.</li>
		 * <li>The root element is called <b>&lt;root&gt;</b></li>
		 * <li>Each <b>&lt;Node&gt;</b> node represents a node in the graph which will be labeled based on the <b>id</b> attribute and colored
		 * based on the <b>sex</b> attribute.<br/> The <b>sec</b> attribute holds the number of seconds, this mouse was recorded beeing in a box during the time range the data was loaded for.</li>
		 * <li>Each <b>&lt;Edge&gt;</b> node defines a connection between two &lt;Node&gt; nodes. Since the graph is unidirectional the order of the <b>fromID</b> and <b>toID</b> attributes don't matter.<br/>
		 * The <b>sec</b> attribute shows the 'strength' of a connection, which is the number of seconds the two mice, specified in the <b>fromID</b> and <b>toID</b> attributes, have spent together in whatever 
		 * box during the time range the data was loaded for.<br/>The <b>count</b> attribute holds the number of distinct meetings the two &lt;Node&gt; nodes  had during the time range the data was loaded for.<br/>
		 * The <b>thickness</b> and <b>strength</b> attributes hold the values of the line thickness when drawing the edge. The maximum value of these attributes is 10, which is given to the edge in the xml data with 
		 * the <b>highest</b> value in the <b>sec</b> attribute. The lowest value is 1 which is given to the which is given to the edge in the xml data with 
		 * the <b>lowest</b> value in the <b>sec</b> attribute. The <b>thickness</b> and <b>strength</b> attribute values for the other edges are interpolated.</li>
		 * </ul>
		 * 
		 * <p>The above graph data would form a triangle.</p>
		 *  
		 */
		public var graphXML:XML;
		
		public var label:String;
		/**
		 * The underlying <b>RaVis</b> <code>IGraph</code> object.
		 */ 
		public var graph:IGraph;
		
		/**
		 * An <code>Array</code> of the nodes within this graph.
		 */
		public var nodes:Array;
		
		/**
		 * The edges within this graph as an <code>XMLListCollection</code>.
		 */
		public var edges:XMLListCollection;
		
		private var _edgesAC:ArrayCollection;
		
		/**
		 * The filter value
		 */
		public var filterValue:Number;
		
		/**
		 * The lowest value of the &lt;Edge&gt; nodes <b>sec</b> attribute
		 */  
		[Bindable]
		public var filterMinimum:Number;
		
		/**
		 * The highest value of the &lt;Edge&gt; nodes <b>sec</b> attribute
		 */
		[Bindable]
		public var filterMaximum:Number;
		
		/**
		 * The layouter state (running or not ) in the visual representation of the data.
		 * 
		 * @default true
		 */
		[Bindable]
		public var layouterRunning:Boolean;
		
		/**
		 * The scale value for the labels in the visual representation of the data.
		 */
		[Bindable]
		public var labelScale:Number;
		
		/**
		 * The zoom value in the visual representation of the data.
		 */
		[Bindable]
		public var zoom:Number;
		
		[Bindable]
		public var rootNode:IVisualNode;
		
		/**
		 * The <a href="http://en.wikipedia.org/wiki/Out-degree">degrees</a> shown (from the <code>rootNode</code>) in the visual representation of the data.
		 */
		[Bindable]
		public var degreesOfSep:Number;
		
		/**
		 * The length of the links (edges) in the visual representation of the data.
		 */
		[Bindable]
		public var linkLength:Number;
		
		/**
		 * If the edge labels showing the value of the <b>sec</b> attribute are shown in the visual representation of the data.
		 * 
		 * @default false
		 */
		[Bindable]
		public var displayEdgeLabels:Boolean;
		
		
		private var _nodeBasedMeasures:Array;
		private var _nodesBetweenness:Dictionary;
		private var _activeNodes:Dictionary;
		private var _graphId:String;
		private var _limit:Number;
		private var _diameter:int;
		
		
		/**
		 * @param label The label for this data.
		 * @param grapXML The xml representation of the graph data.
		 * @param filterProperty The name of the &lt;Node&gt; attribute the filter should work on.
		 * @param limit The limit this data was loaded for
		 * 
		 * @see classes.rpc.GetGraphData
		 */
		public function GraphData(label:String, graphXML:XML, filterProperty:String, limit:Number)
		{
			
			
			this.graphXML = graphXML;
			this.label = label;
			_limit = limit;
			
			var spaces:RegExp = /\s/g;
			_graphId = label.replace(spaces,'_');
			
			this.graph = Graph.createGraph(_graphId,false,graphXML);
			
			// getting component diameter
			_diameter = 0;
			
			for each (var graphNode:INode in graph.nodes)
			{
				var maxDepth:int = graph.getTree( graphNode).maxDepth;
				if( maxDepth > _diameter)
				{
					_diameter = maxDepth; 
				}
			}
			
			degreesOfSep = _diameter;
			
			this.edges = new XMLListCollection( graphXML..Edge);
			this.nodes = new Array()
				
			for each (var node:XML in graphXML..Node) {
				this.nodes[ node.@id] = node;
			}
			
			// Filter values
			filterMinimum = 10000;
			filterMaximum = 0;
			
			// edges values
			_edgesAC = new ArrayCollection();
			for each ( var edge:XML in edges.source ) {
				
				var edgeVal:Number = edge.attribute(filterProperty);
				var duration:String = DateHelpers.secToTime( edge.attribute('sec').toString() ); 
				_edgesAC.addItem( 
				{
					label: label,
					fromID: edge.attribute('fromID').toString(),
					toID: edge.attribute('toID').toString(),
					dt: duration,
					count: edge.attribute('count').toString() 
				} );
				
				filterMinimum = Math.min( edgeVal, filterMinimum);
				filterMaximum = Math.max( edgeVal, filterMaximum) -1;
			}
			
			
			
			filterValue = filterMinimum;
			
			
			// Setting default values
			layouterRunning = true;
			displayEdgeLabels = true;
			updateNodeBasedMeasures(graph.activeNodes);
			
		}
		
		/**
		 * Update the node based measures for the graph data.
		 * 
		 * <p>This is needed when filtering of the data occured.</p>
		 * <p>For each active node in the graph an object is added to the <code>nodeBasedMeasures</code> array. 
		 * The structure of the object is as follows:</p>
		 * 
		 * <pre><code>
		 * var nodeBasedMeasures:Object = {
		 *				label: label, 
		 *				graphId: graphId, 
		 *				rfid: node.stringid, 
		 *				path_length: pathLength,
		 *				clust_coeff: clusteringCoefficient,
		 *				degree: degree,
		 *				betweenness: betweenness
		 *			}	
		 * </code></pre>
		 * 
		 * <p>Some of the values are calculated by methods in the <code>NodesBasedMeasures</code> class.</p>
		 * 
		 * @see classes.helpers.NodeBasedMeasures 
		 *  
		 */
		public function updateNodeBasedMeasures(activeNodes:Dictionary):void
		{
			
			if(activeNodes != null && activeNodes != _activeNodes) {
				
				_activeNodes = activeNodes;
				calcBetweenness();
				var oldNodeMeasures:Array = _nodeBasedMeasures;
				_nodeBasedMeasures = new Array();
				
				for each (var node:INode in activeNodes) {
					
					var betweenness:Number = _nodesBetweenness[node] / 2;
					//trace(node.stringid + ": " + betweenness);
					
					var nodeMeasures:NodeBasedMeasures = new NodeBasedMeasures(node, this.graph);
					
					var nodeBasedMeasures:Object = {
						label: this.label, 
						graphId: this._graphId, 
						rfid: node.stringid, 
						path_length: nodeMeasures.pathLength,
						clust_coeff: nodeMeasures.clusteringCoefficient,
						degree: nodeMeasures.degree,
						betweenness: betweenness
					}								
					
					// Adding the measures to this graph data and the node
					_nodeBasedMeasures.push( nodeBasedMeasures );
					node.nodeBasedMeasures = nodeBasedMeasures; 
				}
				
			} 
			
			dispatchEvent( new Event("updateBinding") );
			
		}
		
		/**
		 * The node based measures for this graph.
		 */
		[Bindable(event="updateBinding")] 
		public function get nodeBasedMeasures():Array
		{
			return _nodeBasedMeasures;
		}
		
		public function get graphId():String
		{
			return _graphId;
		}
		
		/**
		 * The edges within this graph as an <code>ArrayCollection</code>.
		 * 
		 * The objects in the collection have the following properties:
		 * 
		 *<pre>
		 *  var edgeData:Object = {
		 * 		label:String	// this label
		 * 		fromId:String,	// rfid one
		 * 		toID:String,	// rfid two
		 * 		dt:String,		// duration in format hh:mm:ss
		 * 		count:String	// distinct meeting count
		 * }
		 * </pre>
		 * 
		 */
		 public function get edgesAC():ArrayCollection
		 {
		 	return _edgesAC;
		 }
		
		private function calcBetweenness():void
		{
			
			_nodesBetweenness = new Dictionary();
			
			var betweenessCentrality:BetweennessCentrality = new BetweennessCentrality(graph);
			_nodesBetweenness = betweenessCentrality.betweenenssOfNodes;
			
		}
		
		/**
		 * The <a href="http://en.wikipedia.org/wiki/Graph_diameter">diameter</a> of the graph.
		 */
		public function get diameter():int
		{
			return _diameter;	
		}
				
	}
}