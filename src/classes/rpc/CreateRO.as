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
		
	import mx.controls.Alert;
	import classes.GlobalVars;
	import classes.events.*;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	import classes.GlobalVars;
	
	/**
	 * Dispatched when something in the data fetching process went wrong
	 *
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.LOAD_ERROR_OCCURED
	 */
	[Event(name="LoadErrorOccured", type="classes.events.ObjectDataEvent")]
	
	/**
	 * Creates a RemoteObject configured based on the xml information found in the
	 * configuration file. 
	 * 
	 * @example The xml configuration for the miceminer project running on my laptop looks like this:</p>
	 * <listing version="3.0">
	 * &lt;remoting>
	 *		&lt;ro id="getDBData">
	 *			&lt;source>miceMiner.Mice&lt;/source>
	 *			&lt;destination>amfphp&lt;/destination>
	 *		&lt;/ro>
	 *	&lt;/remoting&gt;</listing>
	 * 
	 * The <code>destination</code> matches a node's <code>&lt;destination&gt; id</code> found in the <b>services-config.xml</b>.  
	 * The <code>source</code> defines the filename which contains the <i>amfphp</i> functions (services).
	 *
	*/
	public class CreateRO extends RemoteObject
	{
		
		private var ConfigXML:XML;
		
        public function CreateRO()
        {
        	
			ConfigXML = GlobalVars.getInstance().ConfigXML;	// load the main configuration file
			
			var ServiceName:String = ConfigXML..flex.remoting.ro[0].@id;
        	var ServiceXML:XMLList = ConfigXML..flex.remoting.ro.(attribute("id") == ServiceName);
        		
        	this.destination = ServiceXML..destination.toString();
        	this.source = ServiceXML.source.toString();
        	this.showBusyCursor = true;
        	this.addEventListener(FaultEvent.FAULT,this.faultHandler);
        	
        }
        
        // called when a rpc fault occurs
        private function faultHandler(fault:FaultEvent, test:Object = null):void
        {
            //Alert.show(fault.fault.faultString, fault.fault.faultCode.toString());
            Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.LOAD_ERROR_OCCURED,this, fault));
	    }   	
	}
}