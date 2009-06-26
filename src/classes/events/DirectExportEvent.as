package classes.events

{

	import flash.events.Event;
	
	/**
	 * Custom event involved in the  direct <i>Excel</i> export process.
	 * 
	 * @see classes.rpc.ExportData
	 */ 
	public class DirectExportEvent extends Event{
	
		public var data:Object;
		public var values:Array = new Array();
		
		/**
		 * Event type.
		 */
		public static const DIRECT_EXPORT_DATA:String = "directExportData";
		
		public function DirectExportEvent(data:Object)
		{
			super(DIRECT_EXPORT_DATA,true);
			this.data = data;
		}
		
		/**
        * @private
        */
		override public function clone():Event {
			return new DirectExportEvent(data);
		}
	}
}
