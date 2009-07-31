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

	import mx.managers.SystemManager;
		
	/**
	 * Dispatched when the data is fetched successfully from the database.
	 * 
	 * <p>Along with the event the following data is passed in an array which is the <code>values</code> prooperty of the event:</p>
	 *  	<ul><li><code>event.values[0]</code>: The data wrapped in an <code>ArrayCollection</code></li></ul>
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.GENERIC_DATA_LOADED
	 */
	[Event(name="GenericDataLoaded", type="classes.events.ObjectDataEvent")]
	
	
	/**
	 * Dispatched when something in the data fetching process went wrong
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.GENERIC_DATA_LOAD_FAILED
	 */
	[Event(name="GenericDataLoadFailed", type="classes.events.ObjectDataEvent")]
	
	/**	
	 * Pass any valid <code>SQL</code> statement an get the result data wrapped in an <code>ArrayCollection</code>.
	 * 
	 * <p>This Class calls the <b><code>genericSQL</code></b> method from the <code>amfphp</code> service file.
	 */
	public class GenericDataGetter
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
		
		private static const METHOD_NAME:String = "genericSQL";
			
		/**
		 * @param sql valid <code>SQL</code> statement.
		 */
		public function GenericDataGetter(sql:String):void
		{
			var RO:CreateRO = new CreateRO();
			 
			var dbMethod:AbstractOperation = RO.getOperation(METHOD_NAME);
			var dbToken:AsyncToken = dbMethod.send(sql);	
    			
            dbToken.addResponder(new AsyncResponder(GenericDataGetter.resultHandler, GenericDataGetter.faultHandler));
            
		}
		
		public static function resultHandler(event:ResultEvent, test:Object = null):void
		{
			
			trace ("[GenericDataGetter] resultHandler: valid result");
			var dbData:ArrayCollection = new ArrayCollection( ArrayUtil.toArray(event.result));
			Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.GENERIC_DATA_LOADED,null,dbData));
		}
		
		public static function faultHandler(fault:FaultEvent, test:Object = null):void
		{
			Alert.show("[GenericDataGetter] fault: " +fault.fault.faultString, fault.fault.faultCode.toString());
			Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.GENERIC_DATA_LOAD_FAILED,null,fault.fault.faultString));
		}
		
	}
}