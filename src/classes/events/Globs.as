package classes.events
{
	/**
	 * Global event handling. 
	 * 
	 * @example Getting items data in a <code>DataMinerComponent</code>
	 * 
	 * <listing version="3.0">
	 * Globs.broker.addEventListener(EventsGlobals.ITEMS_IN_DATE_RANGE_LOAD_COMPLETE,eventHandler);
	 * Globs.broker.addEventListener(EventsGlobals.LOAD_ERROR_OCCURED,errorHandler);
	 * 
	 * var getItems:GetItems = new GetItems(_dateRange);
	 * 
	 * // event handler
	 * private function eventHandler(event:ObjectDataEvent):void
	 * {
	 *		Globs.broker.removeEventListener(EventsGlobals.ITEMS_IN_DATE_RANGE_LOAD_COMPLETE,eventHandler);
	 *		var dbData:Array = event.values[0];
	 * }
	 * 
	 * // error handler
	 * private function errorHandler(event:ObjectDataEvent):void
	 * {
	 *		Alert.show(faultData.fault.faultString + "\n Something went wrong", faultData.fault.faultCode.toString(),4,null,null,alertIcon);
	 *		Globs.broker.removeEventListener(EventsGlobals.LOAD_ERROR_OCCURED,errorHandler);
	 * } 
	 * </listing>
	 * 
	 * @see classes.events.EventsGlobals
	 * @see classes.events.ObjectDataEvent
	 * @see classes.rpc.GetItems
	 */
	public class Globs
	{
		public static var broker:ComBroker = new ComBroker();
	}
}