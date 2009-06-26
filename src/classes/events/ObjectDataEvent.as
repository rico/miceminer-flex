package classes.events

{

	import flash.events.Event;
	
	/**
	 * Used in the global event handling to handle the data loading processes.
	 * 
	 * @see classes.events.EventsGlobals
	 * @see classes.rpc.GetData
	 * @see classes.rpc.GetItems
	 * @see classes.rpc.ExportData
	 * @see classes.rpc.DateRange
	 * @see classes.rpc.GenericDataGetter
	 * @see classes.rpc.GetDataByMethod
	 * @see classes.rpc.GetGraphData
	 */  
	public class ObjectDataEvent extends Event
	{
		/**
		 * Instance of the class dispatching the event.
		 */	
		public var instance:Object;
		
		/**
		 * Event values.
		 * 
		 * Usually one of the parameters is the data object and when getting data for an object another one is an <code>Item</code>
		 * instance.
		 * 
		 * @see classes.datastructures.Item
		 * @see classes.events.EventsGlobals
		 * @see classes.rpc.GetData
	 	 * @see classes.rpc.GetItems
	 	 * @see classes.rpc.ExportData
	 	 * @see classes.rpc.DateRange
	 	 * @see classes.rpc.GenericDataGetter
	 	 * @see classes.rpc.GetDataByMethod
	 	 * @see classes.rpc.GetGraphData
		 */
		public var values:Array = new Array();
		
		/**
		 * @param type One of the constants defined in <code>classes.events.EventsGlobals</code>.
		 * @param instance Instance of the class creating the event.
		 * @param args Parameters of the event.
		 * 
		 * @see classes.events.EventsGlobals
		 */
		public function ObjectDataEvent(type:String, instance:Object, ... args)
		{
			super(type);
			this.instance = instance;
			this.values = args;
		}
		
		/**
        * @private
        */
		override public function clone():Event 
		{
			return new ObjectDataEvent(type, instance);
		}
	}
}
