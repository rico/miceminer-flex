package classes.helpers
{
	import classes.events.*;
	import classes.rpc.CreateRO;
	
	import components.popUps.ExportPopUp;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.graphics.ImageSnapshot;
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
	 *  	<ul><li><code>event.values[0]</code>: The <code>url</code> of the exported <code>.png</code> file.</li></ul>
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.EXPORT_COMPLETE
	 */
	[Event(name="ExportComplete", type="classes.events.ObjectDataEvent")]
	
	
	/**
 	 * Exports a <code>UIComponent</code> as a <code>.png</code> file.
 	 *  
 	 * @param component the UIComponent which should get transformed to an <code>png</code> image file.
 	 * @param filename the name of the file to generate . 
 	 */
	public class PngExport
	{
		
		private var getDBData:RemoteObject;
		private var _filename:String;
		private var _exportWin:ExportPopUp;
		
		private static const METHOD_NAME:String = "exportToPng";
		
		public function PngExport(snapshot:ImageSnapshot, filename:String)
		
		{
			_exportWin = ExportPopUp(PopUpManager.createPopUp(Application.application.navigators, ExportPopUp, true));
		   	_exportWin.exportLabel = "Exporting as Image";
		   	 
			var stringEncoded:String = ImageSnapshot.encodeImageAsBase64(snapshot);
			
			getDBData = new CreateRO();
			var dbMethod:AbstractOperation = getDBData.getOperation(METHOD_NAME);
		   	
		   	var dbToken:AsyncToken = dbMethod.send( stringEncoded, filename);
		   	 	
			dbToken.addResponder(new AsyncResponder(DataHandler, faultHandler)); 
			
		}
		
		 // called to handle rpc results
        private function DataHandler(result:ResultEvent, test:Object = null):void
        {
        	var fileurl:String = result.result.toString();
        	
            //var filename:String = new String(StringUtil.toString(result.result));
    		Globs.broker.dispatchEvent( new ObjectDataEvent(EventsGlobals.EXPORT_COMPLETE,this, fileurl) );
	    }     
        
        // called when a rpc fault occurs
        private function faultHandler(fault:FaultEvent, test:Object = null):void
        {
        	trace("png export fault");
            Alert.show(fault.fault.faultString, fault.fault.faultCode.toString());
            _exportWin.closeThis();
	    }     
		
		

	}
}