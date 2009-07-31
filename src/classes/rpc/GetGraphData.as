package classes.rpc
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
	
	import classes.GlobalVars;
	
	/**
	 * Dispatched when the graph data is fetched successfully from the database.
	 * 
	 * @eventType classes.events.EventsGlobals.GRAPH_DATA_LOADED
	 * 
	 * @see classes.events.EventsGlobals
	 */
	[Event(name="GraphDataLoaded", type="classes.events.ObjectDataEvent")]
	
	/**
	 * Dispatched when the edge data is fetched successfully from the database.
	 * 
	 * @eventType classes.events.EventsGlobals.EDGE_DATA_LOADED
	 * 
	 * @see classes.events.EventsGlobals
	 */
	[Event(name="EdgeDataLoaded", type="classes.events.ObjectDataEvent")]
	
	
	/**
	 * Get data for the graph representation, and the edges in the graph representation.  	
	 */	
	public class GetGraphData
	{
		import mx.controls.Alert;
		import mx.rpc.AbstractOperation;
		import mx.rpc.AsyncResponder;
		import mx.rpc.AsyncToken;
		import mx.rpc.events.FaultEvent;
		import mx.rpc.events.ResultEvent;
		import mx.utils.ArrayUtil;
		import classes.events.*;
		import mx.collections.ArrayCollection;
		
		private var ConfigXML:XML;
		private var _eventType:String;
		
		
		public function getGraphData():void
		{}
		
		/**
		 * Get the graph data for the passed year and month.
		 * 
		 * <p>A <code>classes.events.ObjectDataEvent</code> event of type <code>classes.events.EventsGlobals.GRAPH_DATA_LOADED</code> is 
		 * dispatched upon successful data load.</p>
		 * 
		 * <p>The method name is drawn from the <code>&lt;graphData&gt;</code> node attribute <code>method</code>
		 * @example Actual graphData xml configuration:
		 * 
		 * <listing version="3.0">
		 * &lt;graphData limit="3600" method="graphData"&gt;
		 *	[...]
		 * &lt;/graphData&gt;
		 * </listing> 
		 * 
		 * 			In addition to the <code>method</code> attribute a <b>limit</b> attribute is specified, which sets the minimum time (in seconds)
		 * 			two mice must have spent together during the month the data is loaded for.
		 */
		public function getData(year:Number, month:Number):void
		{
			var RO:CreateRO = new CreateRO();
			_eventType = EventsGlobals.GRAPH_DATA_LOADED;
			var Globals:GlobalVars = GlobalVars.getInstance();
			ConfigXML = Globals.ConfigXML;
			
			var methodName:String = ConfigXML..flex..graph.graphData.@method;
			var limit:Number = ConfigXML..flex..graph.graphData.@limit;
			 
			var dbMethod:AbstractOperation = RO.getOperation( methodName );
			var dbToken:AsyncToken = dbMethod.send(year, month, limit);
    			
            dbToken.addResponder(new AsyncResponder(resultHandler, faultHandler));
            
		}
		
		/**
		 * Get the edge data for the passed year and month and the two nodes of the edge.
		 * 
		 * <p>A <code>classes.events.ObjectDataEvent</code> event of type <code>classes.events.EventsGlobals.EDGE_DATA_LOADED</code> is 
		 * dispatched upon successful data load.</p>
		 * 
		 * <p>The method name is drawn from the <code>&lt;edgeData&gt;</code> node attribute <code>method</code>
		 * @example Actual edgeData xml configuration:
		 * 
		 * <listing version="3.0">
		 * &lt;graphData  method="getEdgeData"&gt;
		 *	[...]
		 * &lt;/edgeData&gt;
		 * </listing> 
		 */
		public function getEdgeData(year:Number, month:Number, fromId:String, toId:String):void
		{
			var RO:CreateRO = new CreateRO();
			_eventType = EventsGlobals.EDGE_DATA_LOADED;
			
			var methodName:String = GlobalVars.getInstance().ConfigXML.flex..graph.edgeData.@method;
			 
			var dbMethod:AbstractOperation = RO.getOperation( methodName );
			var dbToken:AsyncToken = dbMethod.send(year, month, fromId, toId);
    			
            dbToken.addResponder(new AsyncResponder(resultHandler, faultHandler));
            
            
		}
		
		private function resultHandler(event:ResultEvent, test:Object = null):void
		{
			
			trace ("[GetNetworkData] resultHandler: valid result");
			//var dbData:Array = ArrayUtil.toArray(event.result);
			var dbData:Array = [event.result];
			Globs.broker.dispatchEvent(new ObjectDataEvent(_eventType,null, dbData));
		}
		
		private function faultHandler(fault:FaultEvent, test:Object = null):void
		{
			Alert.show("[GetNetworkData] fault: " +fault.fault.faultString, fault.fault.faultCode.toString());
			
		}
		
	}
}