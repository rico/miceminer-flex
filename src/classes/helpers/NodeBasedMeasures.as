package classes.helpers
{
	
	import flash.utils.Dictionary;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.Edge;
	import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
	
	/**
	 * Provides methods to calculate node based measures for a node in a graph.
	 * 
	 * @see classes.datastructures.GraphData
	 */
	public class NodeBasedMeasures
	{
		
		private var _vnode:IVisualNode;
		private var _node:INode;
		private var _vgraph:IVisualGraph;
		private var _graph:IGraph;
		private var _pathLength:Number;
		private var _clustCoefficient:Number;
		private var _degree:uint;
		private var _normalizedEdges:Dictionary;
		public var 	id:String;
		 
		/**
		 * @param node A <b><a href="http://code.google.com/p/birdeye/wiki/RaVis">RaVis</a></b> <code>INode</code> object;
		 * @param node A <b><a href="http://code.google.com/p/birdeye/wiki/RaVis">RaVis</a></b> <code>IGraph</code> object;
		 */
		public function NodeBasedMeasures(node:INode, graph:IGraph)
		{
		
			_node = node;
			_graph = graph;
			
			_pathLength = pathLengthCalc();
			_clustCoefficient = clusteringCoefficientCalc();
			_degree = degreeCalc();
			
			id = node.stringid;
			
		}

		/**
		 *	The mean of the shortet path lengths from this node to all other nodes.
		 */
		public function get pathLength():Number
		{
			return _pathLength;
		}
		
		private function clusteringCoefficientCalc():Number
		{
			
			var clustCoeff:Number = 0;
			var nodes:Array = getNeighbours(_node);
			//nodes.push(_node);
			
			// calculate only for active nodes
			
			
			if(nodes.length == 1)
			{
				return 0;	
			}
			
			var possibleEdges:Number = 2 / ( nodes.length * (nodes.length -1) );
			
			var i:uint;
			var j:uint;
			var trianglesSum:Number = 0;
			
			for  (i = 0; i < nodes.length -1; i++) {
				
				for (j=i+1; j < nodes.length; j++) {
					
					var edge_iToj:IEdge = _graph.getEdge(nodes[i],nodes[j]);
					
					// if the edge between nodes[i] and nodes[j] exits (and is active = not filtered), we have a triangle
					// _node, nodes[i], node[j]
					if( edge_iToj != null && _graph.activeEdges[edge_iToj] == edge_iToj) {
						trianglesSum += 1;
					} 
					
				}	
			}
			
			clustCoeff = possibleEdges * trianglesSum;
			
			// if(_node.stringid == '0006CC74B1') {
			/* trace("node: " + _node.stringid);
			trace("possEdges: " + possibleEdges.toFixed(5));
			trace("trianglesSum: " + trianglesSum.toFixed(5));
			trace("ClustCoeff: " + clustCoeff.toFixed(5));
			trace("all"); */
			//}
			
			return clustCoeff;
		}
		
		/**
		 * <a href="http://en.wikipedia.org/wiki/Clustering_coefficient">Clustering coefficient</a> of the node.
		 */
		public function get clusteringCoefficient():Number
		{
			return _clustCoefficient;
		}
		
		/**
		 * <a href="http://en.wikipedia.org/wiki/Out-degree">Degree</a> of the node.
		 */
		public function get degree():uint
		{
			return _degree;
		}
		
		private function degreeCalc():uint
		{
			var degreeVal:uint = 0;
			
			for each (var edge:Edge in _node.inEdges) {
				
				if( _graph.activeEdges[ edge ] == edge ) {
					degreeVal++;
				}
				 
			}
			
			return degreeVal;
		}
		
		private function get vnode():IVisualNode
		{
			return _vnode;
		}
		
		/**
		 * The neighbors of the node which are the nodes with degree one from the node
		 */ 
		public function getNeighbours(forNode:INode):Array
		{
			var neighbours:Array = [];
			
			for each (var edge:Edge in forNode.inEdges) {
				
				if( _graph.activeEdges[ edge ] == edge ) {
					neighbours.push( edge.othernode(forNode) );
				}
				 
			}
			
			
			return neighbours;
			
		}
		
		/**
		 * Get the mean path lenth
		 */
		private function pathLengthCalc():Number
		{
			
			var activeNodes:Dictionary = _graph.activeNodes;
			var activeEdges:Dictionary = _graph.activeEdges;
			
			var stack:Array = [_node];
			
			var visited:Object = new Object();
			visited[_node.stringid] = node;
			var distance:uint = 0;
			var distances:Dictionary = new Dictionary();
			distances[_node] = 0;
			
			while (stack.length > 0) {
				
				var node:INode = stack.shift();
				var neighbors:Array = [];
				neighbors = getNeighbours(node);
				
				for each (var neighbor:INode in neighbors) {
					
					if( !visited.hasOwnProperty(neighbor.stringid)) {
						distances[neighbor] = distances[node] + 1;
						visited[neighbor.stringid] = neighbor;
						stack.push(neighbor);
					}
				}
				
			}
			
			var node_count:uint = 0;
			var distances_sum:uint = 0;
			
			for (var pathnode:Object in distances) {
				if (distances[pathnode] > 0) {
					distances_sum += distances[pathnode];
					node_count++; 
				}
				
			}
			
			return (distances_sum/node_count);
			
		}
		
	}	
}