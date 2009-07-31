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
	 * @eventType classes.events.EventsGlobals.GET_DATA_BY_METHOD_RESULT
	 */
	[Event(name="GetDataByMethodResult", type="classes.events.ObjectDataEvent")]
	
	
	/**
	 * Dispatched when something in the data fetching process went wrong
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.GET_DATA_BY_METHOD_FAULT
	 */
	[Event(name="GetDataByMethodFault", type="classes.events.ObjectDataEvent")]
	
	/**
	 * Get data based on the method name.
	 * 
	 */
	public class GetDataByMethod
	{
		import mx.controls.Alert;
		import mx.rpc.AbstractOperation;
		import mx.rpc.AsyncResponder;
		import mx.rpc.AsyncToken;
		import mx.rpc.events.FaultEvent;
		import mx.rpc.events.ResultEvent;
		import mx.utils.ArrayUtil;
		import mx.collections.ArrayCollection;
		import classes.events.*;
		
		/**
		 * @param method The method name which must exist in the amfphp service file.   
		 * @param parameters an associative of the service parameters array in the form:
		 * 	 <code>parameters['param_name'] = param_value</code>
		 */
		public function GetDataByMethod(method:String, parameters:Array):void
		{
			var RO:CreateRO = new CreateRO();
			
			var dbMethod:AbstractOperation = RO.getOperation(method);
				 
			var dbToken:AsyncToken = dbMethod.send(parameters);	
    			
            dbToken.addResponder(new AsyncResponder(this.resultHandler, this.faultHandler));
            
		}
		
		private function resultHandler(event:ResultEvent, token:Object = null):void
		{
			
			//trace ("[GetDataByMethod] resultHandler: valid result");
			
			if( event.result is Array ) {
			
				var dbData:ArrayCollection = new ArrayCollection( ArrayUtil.toArray(event.result) );
				Globs.broker.dispatchEvent( new ObjectDataEvent(EventsGlobals.GET_DATA_BY_METHOD_RESULT,null,dbData) );
			} else {
				Globs.broker.dispatchEvent( new ObjectDataEvent(EventsGlobals.GET_DATA_BY_METHOD_RESULT,null,event.result.toString()) );
			}
		}
		
		private function faultHandler(fault:FaultEvent, token:Object = null):void
		{
			Alert.show("[GetDataByMethod] fault: " + fault.fault.faultString, fault.fault.faultCode.toString());
			Globs.broker.dispatchEvent( new ObjectDataEvent(EventsGlobals.GET_DATA_BY_METHOD_FAULT,null,fault.fault.faultString) );
		}
		
	}
}