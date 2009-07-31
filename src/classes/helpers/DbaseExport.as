package classes.helpers
{
	
	import classes.GlobalVars;
	import classes.events.*;
	import classes.rpc.CreateRO;
	
	import components.popUps.ExportPopUp;
	import components.popUps.NoDataPopUp;
	
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
	 *  	<ul><li><code>event.values[0]</code>: The <code>url</code> of the exported <code>Excel</code> file,</li></ul>
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.EXPORT_COMPLETE
	 */
	[Event(name="ExportComplete", type="classes.events.ObjectDataEvent")] 
	
	
	 /**
     * Export the antenna data for a mouse within a given time period to a dBase (.dbf) file.
     *
     */
	public class DbaseExport

	{
		private var getDBData:RemoteObject;
		private var _filename:String;
		private var _exportWin:ExportPopUp;
		
		/**
		 * @param rfid The rfid to export the data for
		 * @param from The start day of the chosen period
		 * @param to The end day of the chosen period 
		 */ 
		public function DbaseExport(rfid:String, from_date:String, to_date:String):void
		{
		
			var exportToDbfMethod:String = GlobalVars.getInstance().ConfigXML.flex.helpers.exportToDbase.@method;
			getDBData = new CreateRO();
			
			var dbMethod:AbstractOperation = getDBData.getOperation(exportToDbfMethod);
		   	var dbToken:AsyncToken = dbMethod.send(rfid, from_date, to_date);
		   	
		   	_exportWin = ExportPopUp(PopUpManager.createPopUp(Application.application.navigators, ExportPopUp, true));
			_exportWin.exportLabel = "Exporting Data for rfid " + rfid +  " as dbase File";
		   		
			dbToken.addResponder(new AsyncResponder(DataHandler, faultHandler));
		}
        
	     
        /**
        * @private
        * 
        * Success handler.
        */
        private function DataHandler(result:ResultEvent, test:Object = null):void
        {

        	if(result.result == null) {
        		_exportWin.closeThis();
        		var noDataPop:NoDataPopUp = NoDataPopUp(PopUpManager.createPopUp(Application.application.navigators, NoDataPopUp, false));
				noDataPop.noDataLabel = "No data found for the selected parameters";
        	} else{
        		var fileurl:String = result.result.toString(); 	
        		Globs.broker.dispatchEvent( new ObjectDataEvent(EventsGlobals.EXPORT_COMPLETE,this, fileurl) );
        	}
        	
    		
	    }     
        
        /**
        * @private
        * 
        * Fault handler.
        */
        private function faultHandler(fault:FaultEvent, test:Object = null):void
        {
        	_exportWin.closeThis();
        	trace("excel fault");
            Alert.show( fault.fault.faultString, fault.fault.faultCode.toString() );
	    }     
    
	}
}