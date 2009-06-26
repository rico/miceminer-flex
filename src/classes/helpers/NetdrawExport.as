package classes.helpers
{
	
	import classes.events.*;
	import classes.rpc.CreateRO;
	
	import components.popUps.ExportPopUp;
	
	import flash.errors.*;
	import flash.external.*;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	/**
	 * Dispatched when the export is successful.
	 * 
	 * <p>Along with the event the following data is passed in an array which is the <code>values</code> property of the event:</p>
	 *  	<ul><li><code>event.values[0]</code>: The <code>url</code> of the exported <code>.vna</code> file,</li></ul>
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.EXPORT_COMPLETE
	 */
	[Event(name="ExportComplete", type="classes.events.ObjectDataEvent")] 
	
	
	/**
     * Export graph data in xml format to the <b><a href="http://www.analytictech.com/Netdraw/netdraw.htm">netdraw</a> VNA</b> file format. The actual format conversion is made 
     * by the remote export handler defined in the <code>METHOD_NAME</code> constant.  
     */
	public class NetdrawExport

	{
		private var getDBData:RemoteObject;
		private var _exportWin:ExportPopUp;
		
		/**
		 * The remote method this class uses.
		 */
		public static const METHOD_NAME:String = "exportToNetdraw"; 
		
		public function NetdrawExport(graphData:XML, filename:String):void
		{
		
			getDBData = new CreateRO();
			//var xmlData:XML = convertDGtoXML(dataGrid);
			var dbMethod:AbstractOperation = getDBData.getOperation(METHOD_NAME);
		   	var dbToken:AsyncToken = dbMethod.send( graphData , filename);
		   	_exportWin = ExportPopUp(PopUpManager.createPopUp(Application.application.navigators, ExportPopUp, true));
		   	_exportWin.exportLabel = "Exporting to Netdraw";
		   	dbToken.addResponder(new AsyncResponder(DataHandler, faultHandler));				
		}
        
	     
        // called to handle rpc results
        private function DataHandler(result:ResultEvent, test:Object = null):void
        {
        	var fileurl:String = result.result.toString();
        	
            //var filename:String = new String(StringUtil.toString(result.result));
    		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.EXPORT_COMPLETE,this, fileurl));
	    }     
        
        // called when a rpc fault occurs
        private function faultHandler(fault:FaultEvent, test:Object = null):void
        {
        	_exportWin.closeThis();
        	trace("netdraw fault");
            Alert.show(fault.fault.faultString, fault.fault.faultCode.toString());
	    }     
    
	}
}