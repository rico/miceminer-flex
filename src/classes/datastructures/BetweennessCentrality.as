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
	
	import flash.utils.Dictionary;
	import org.un.cava.birdeye.ravis.graphLayout.data.Edge;
	import org.un.cava.birdeye.ravis.graphLayout.data.IGraph;
	import org.un.cava.birdeye.ravis.graphLayout.data.INode;
	
	/**
	 * The betweenness values for nodes in a <b><a href="http://code.google.com/p/birdeye/wiki/RaVis">RaVis</a></b> graph.
	 * 
	 * <p>For further information about the <i>betweenness</i> values of nodes in a graph, please read this <a href="http://en.wikipedia.org/wiki/Centrality">Wikipedia article</a>.</p>
	 * 
	 * <p>I have adapted the <b>RaVis</b> library for my needs. So this class will not work with the standard library.</p> 
	 * <p>The code for the calculation of the <i>betweenness</i> values is derived form the <b><a href="http://flare.prefuse.org/">flare</a></b> library, since these calculations are not present in <b>RaVis</b> library.</p>
	 */
	public class BetweennessCentrality
	{
		private var _activeNodes:Dictionary;
		private var _activeEdges:Dictionary;
		private var _graph:IGraph;
		private var _betweenenssOfNodes:Dictionary;
		
		/**
		 * All calculations are performed in the constructor and the values get stored in the  <code>betweennessOfNodes</code> property.
		 * 
		 * @param IGraph A <b>RaVis</b> graph object. I've adapted the graph class to meet my requirements. 
		 */
		public function BetweennessCentrality(graph:IGraph)
		{
			_graph = graph;
			_activeNodes = _graph.activeNodes;
			_activeEdges = _graph.activeEdges;
			
			_betweenenssOfNodes = new Dictionary();
			for (var activeNode:Object in _activeNodes)
			{
					_betweenenssOfNodes[activeNode] = 0;
			}	
			
			for (var s:Object in _activeNodes) {
				
				
				var predecessors:Dictionary = new Dictionary();
				//predecessors = fillWithValues([],predecessors,_activeNodes);
				for (var node:Object in _activeNodes)
				{
					predecessors[node] = [];
				}
				
				var paths:Dictionary = new Dictionary();
				for (node in _activeNodes)
				{
					paths[node] = 0;
				}
				paths[s] = 1;
				
				var d:Dictionary = new Dictionary();
				for (node in _activeNodes)
				{
					d[node] = -1;
				}
				d[s] = 0;
				/*trace("=====================================================");
				trace("s: " + s.stringid);*/
				
				var stack:Array = [];
				var queue:Array = [s];
				
				while (queue.length > 0)
				{
					
					var v:INode = queue.shift();
					stack.push(v);
					//trace("v: " + v.stringid + " d[v] => " + d[v]);
					var vneighbours:Array = getNeighbours(v);
					//var vneighbours:Array = getChildren(v, s as INode, d[v]);
					for each( var w:INode in vneighbours )
					{

						// w found for the first time
						if( d[w] < 0)
						{
							queue.push(w);
							d[w] = d[v] + 1;
							//trace("\t" + w.stringid + " d[w] => " + d[w]);
						}
						
						// shortest path to w via v ?						
						if( d[w] == d[v] + 1 )
						{
							paths[w] += paths[v];
							predecessors[w].push(v);
						}
					}
					
				}
				
				var dependency:Dictionary = new Dictionary();
				for (node in _activeNodes)
				{
					dependency[node] = 0;
				}
				
				while ( stack.length > 0)
				{
					w = stack.pop();
					//trace("w: " + w.stringid);
					for each ( v in predecessors[w] )
					{
						//trace("\tv: " + v.stringid);
						dependency[v] += (paths[v] / paths[w]) * (1 + dependency[w]);
						//trace("\tdependency[v] => " + dependency[v]);
					}
					
					if(w.stringid != s.stringid)
					{
						_betweenenssOfNodes[w] += dependency[w];
						//trace("_betweenenssOfNodes[" + w.stringid + "] => " + _betweenenssOfNodes[w]);
						//trace("");
					}
				}
				
			}
		}
		
		/**
		 * The nodes which are neighbours of the node
		 */ 
		private function getNeighbours(forNode:INode):Array
		{
			var neighbours:Array = [];
			
			for each (var edge:Edge in forNode.inEdges) {
				
				if( _activeEdges[ edge ] == edge ) {
					neighbours.push( edge.othernode(forNode) );
				}
				 
			}
			
			return neighbours;
		}
		
		/**
		 * Filing a dictionary with the desired keys (data) and value
		 */
		private function fillWithValues(value:*, dict:Dictionary, data:Dictionary ):Dictionary
		{
			for (var dataSet:Object in data)
			{
				dict[dataSet.stringid] = value;
			}
		
			return dict;
		}
		
		/**
		 * The object keys are visible nodes of the <code>IGraph</code>, the corresponding values
		 * represent the betweenness value as a <code>Number</code>
		 */ 
		public function get betweenenssOfNodes():Dictionary
		{
			return _betweenenssOfNodes;
		}
		

	}
}