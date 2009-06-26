package classes.helpers
{
	
	import classes.GlobalVars;
	import classes.events.*;
	import classes.rpc.CreateRO;
	
	import components.popUps.ExportPopUp;
	
	import flash.errors.*;
	import flash.external.*;
	
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
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
     * Converts a <code>DataGrid</code> to an associative array and then send it on to the remote export handler
     * defined in the <code>METHOD_NAME</code> constant.
     */
	public class ExcelExport

	{
		private var getDBData:RemoteObject;
		private var _filename:String;
		private var _exportWin:ExportPopUp;
		
		/**
		 * @param dataGrid the <code>AdvancedDataGrid</code> for which we want to export the data.
		 * @param filename The <code>filename</code> the exported file should have.
		 * @param gridId The <code>id</code> of the &lt;grid&gt; in the xml configuration file. 
		 */ 
		public function ExcelExport(dataGrid:DataGrid, filename:String, gridId:String):void
		{
		
			var exportToExcelMethod:String = GlobalVars.getInstance().ConfigXML.flex.helpers.exportToExcel.@method;
			
			
			_filename = filename;
			getDBData = new CreateRO();
			//var xmlData:XML = convertDGtoXML(dataGrid);
			var dbMethod:AbstractOperation = getDBData.getOperation(exportToExcelMethod);
			var gridData:Object = convertDGtoHashMap(dataGrid, gridId);
		   	
		   	var dbToken:AsyncToken = dbMethod.send( gridData , _filename);
		   	 _exportWin = ExportPopUp(PopUpManager.createPopUp(Application.application.navigators, ExportPopUp, true));
		   	 _exportWin.exportLabel = "Exporting to Excel";
		   		
			dbToken.addResponder(new AsyncResponder(DataHandler, faultHandler));
		}
		
        /**
        * Convert a data grid to an xml
        */
        private function convertDGtoHashMap(dataGrid:DataGrid, gridId:String):Object
        {
        	var gridInfo:Object = new Object();

        	var excelData:Array = new Array();
        	// looping through columns
        	for each (var column:DataGridColumn in dataGrid.columns)
        	{
        		excelData[column.dataField] = [];
        		
        		for each (var data:Object in dataGrid.dataProvider)
        		{
        			if(data[column.dataField] != null)
        			{
        				excelData[column.dataField].push(data[column.dataField]);
        			} else {
        				excelData[column.dataField].push('');
        			}	
        		}
        		
        	}
        	
        	
        	gridInfo[gridId] = excelData
        	
        	return gridInfo;
        }
        
	     
        // called to ha ndle rpc results
        private function DataHandler(result:ResultEvent, test:Object = null):void
        {
        	var fileurl:String = result.result.toString();
        	
            //var filename:String = new String(StringUtil.toString(result.result));
    		Globs.broker.dispatchEvent( new ObjectDataEvent(EventsGlobals.EXPORT_COMPLETE,this, fileurl) );
	    }     
        
        // called when a rpc fault occurs
        private function faultHandler(fault:FaultEvent, test:Object = null):void
        {
        	_exportWin.closeThis();
        	trace("excel fault");
            Alert.show( fault.fault.faultString, fault.fault.faultCode.toString() );
	    }     
    
	}
}