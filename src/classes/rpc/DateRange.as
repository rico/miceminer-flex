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
	
	import classes.helpers.DateHelpers;
	
	/**
	 * Dispatched when the data is fetched successfully from the database.
	 * 
	 * <p>Along with the event the following data is passed in an array which is the <code>values</code> prooperty of the event:</p>
	 *  	<ul><li><code>event.values[0]</code>: The data wrapped in an <code>ArrayCollection</code></li></ul>
	 * 
	 * @see classes.events.ObjectDataEvent
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.DATE_RANGE_LOADED
	 */
	[Event(name="DateRangeLoaded", type="classes.events.ObjectDataEvent")]
	
	
	/**
	 * Get's the date range of the data in the database. 
	 * 
	 * <p>This class calls the method to get the date range specified in the xml configuration file.</p>
	 * @example Here's how the configuration looks at the moments:
	 *  
	 * <listing version="3.0">
	 * &lt;dateRange method="dbDateRange"&gt;
	 *		&lt;min_field&gt;box_in&lt;/min_field&gt;
	 *		&lt;max_field&gt;box_out&lt;/max_field&gt;				
	 * &lt;/dateRange&gt;</listing>
	 *  
	 */
	public class DateRange
	{
		import mx.controls.Alert;
		import mx.rpc.AbstractOperation;
		import mx.rpc.AsyncResponder;
		import mx.rpc.AsyncToken;
		import mx.rpc.events.FaultEvent;
		import mx.rpc.events.ResultEvent;
		import mx.utils.ArrayUtil;
		
		import classes.GlobalVars;
		import classes.events.*;
		import classes.helpers.XmlHelper;
		
		public static function getDateRange():void
		{
			var Globals:GlobalVars = GlobalVars.getInstance();
			var ConfigXML:XML = Globals.ConfigXML;
			var method:String = ConfigXML..dateRange.@method;
			var min_field:String = ConfigXML..dateRange.min_field;
			var max_field:String = ConfigXML..dateRange.max_field;
			
			var RO:CreateRO = new CreateRO();
			 
			var dbMethod:AbstractOperation = RO.getOperation(method);
			var dbToken:AsyncToken = dbMethod.send(min_field, max_field);	
    			
            dbToken.addResponder(new AsyncResponder(DateRange.resultHandler, DateRange.faultHandler));
            
		}
		
		public static function resultHandler(event:ResultEvent, test:Object = null):void
		{
			
			var Globals:GlobalVars = GlobalVars.getInstance();
			Globals.dateRange = new Array();
			var dbrangeUts:Array = new Array();
			
			for (var i:String in event.result) {
				// AS timestamps are millisecond based, PHP timestamps are in seconds since epoch
				var phputs:Number = event.result[i];
				var asuts:Number = phputs * 1000;
				 
				dbrangeUts.push(asuts);
			}
		 
		 	var dbRangeDates:Array = [new Date(dbrangeUts[0]), new Date(dbrangeUts[1])];
			DateHelpers.setDbRange(dbRangeDates);
			Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.DATE_RANGE_LOADED,null,dbRangeDates));
		}
		
		public static function faultHandler(fault:FaultEvent, test:Object = null):void
		{
			Alert.show("GetDateRange fault: " +fault.fault.faultString, fault.fault.faultCode.toString());
		}
		
	}
}