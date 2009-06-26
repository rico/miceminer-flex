package classes.rpc
{
	//import mx.collections.ArrayCollection;
	import classes.GlobalVars;
	import classes.datastructures.Item;
	import classes.events.*;
	import classes.helpers.DateHelpers;
	import classes.helpers.XmlHelper;
	
	import components.popUps.ExportPopUp;
	
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	/**
	 * Dispatched when the data is fetched successfully from the database.
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
	 * Dispatched when something in the data fetching process went wrong.
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.LOAD_ERROR_OCCURED
	 */
	[Event(name="LoadErrorOccured", type="classes.events.ObjectDataEvent")] 
		
	/**
	 * Direct Excel export. 
	 * 
	 * <p>Export data for an <code>Item</code> directly to <i>Excel</i> instead of passing it back to <i>miceminer</i> unlike <code>GetData</code>.</p>
	 * 
	 * @see classes.rpc.GetData
	 */
	public class ExportData
	{
		
		private var Globals:GlobalVars;
		private var ConfigXML:XML;
		private var _itemsGridsXML:XMLList;
		private var _dataGridsXML:XMLList;	
		private var _remoteHandlerData:CreateRO;
		private var _dataRpcInfo:Array;	
		private var _dataData:Array;
		private var _method:String;
		private var _gridId:String;
		private var _dataGridsWithSQL:Array;
		private var _exportWin:ExportPopUp;
		private var _getDBData:RemoteObject;
		private var _field:String;
        private var _value:String;
        private	var _start:String;
       	private var _end:String;
       	private var _item:Item;
       	private var _dateRange:Array;
       	private var _header:String;
		private static const METHOD_NAME:String = "directExportData";
		
		/**
		 * @param item The <code>Item</code> the data shoul be exported for
		 * @param dateRange The date range 
		 */
		public function ExportData(item:Item, dateRange:Array):void
		{
			
			this.Globals = GlobalVars.getInstance();
			this.ConfigXML = Globals.ConfigXML;
			_item = item;
			_dateRange = dateRange;
			_header = XmlHelper.getGridXML(item.gridId).@header;
			
			_remoteHandlerData = new CreateRO();
	    	_dataRpcInfo = new Array();
			_dataRpcInfo = dataGridsRpcInfo();
			_dataData = new Array();
			_dataGridsWithSQL = new Array();
			
			getDataData();
	    
		}
		
		
		/* -----------------------------------------------------------------------------------------------
			main functions
		----------------------------------------------------------------------------------------------- */
		       
         /**
         * Get data from the database for a selected item
         */ 
        private function getDataData(event:ResultEvent = null, test:Object = null):void
        {
        	
        	//the first time we haven't got any data (called from createGrids)
        	if(event != null) {
        		_dataGridsWithSQL[event.result.gridId] = event.result.sql; // add the gridId sql pair to the assoc array
        	}
        	
        	if(_dataRpcInfo.length > 0) { // collect the gridIds and their corresponding sql
        		
            	var rpc:Object = _dataRpcInfo.pop();
            	
            	_method = rpc.method;
            	_gridId = rpc.gridId;
            	
            	_field = rpc.field;
            	_value = rpc.value;
            	_start = rpc.start;
            	_end = rpc.end;
            	 
            	trace("[ExportData] getDataData:\tgridId: " + _gridId + "\tmethod: " + _method + "\tfield: " + _field + "\tvalue: " + _value + "\tstart: " + _start + "\tend: " + _end);
            	
            	var dbMethod:AbstractOperation = _remoteHandlerData.getOperation(_method);
            	// with the sixth parameter set to true, we will only receive the sql and the gridId to retreive the data
				var dbToken:AsyncToken = dbMethod.send(_gridId, _field, _value, _start, _end, true);	
    			
            	dbToken.addResponder(new AsyncResponder(getDataData, faultHandler));
            	            	
        	} else { // call the method to collect and export the data 
     			
        		//Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.DATA_LOAD_COMPLETE,this, this.DataData));
        		_remoteHandlerData = new CreateRO();
				dbMethod = _remoteHandlerData.getOperation(METHOD_NAME);
				
				var filename:String = 'data_for_' + _header + '_' + _value + '_from_' + _start + '_to_' + _end; 
				
				dbToken = dbMethod.send( _dataGridsWithSQL, filename);
				
				_exportWin = ExportPopUp(PopUpManager.createPopUp(Application.application.navigators, ExportPopUp, true));
				_exportWin.exportLabel = "Exporting data directly to Excel";
		   		
				dbToken.addResponder(new AsyncResponder(DataHandler, faultHandler));
				
        	}

        }
        
		
		
		
        // create array containing the infos for the data rpcs
        // and add it to the RPC Array
        private function dataGridsRpcInfo():Array
        {
        	var dataRpcInfo:Array = new Array();
        	
        	
        	// getting dataGrids config (XML)
        	var dataGridsXML:XMLList = XmlHelper.getDataGridsXML(_item.gridId);
        	
        	// getting dateRange
        	var dateRangeF:Array = DateHelpers.formatDate(_dateRange);
        	
        	var startDate:String = dateRangeF[0];
        	var endDate:String = dateRangeF[1];
        	
        	for each(var dataGridXML:XML in dataGridsXML) {
        		var dataGridmethod:String = dataGridXML.@method;
        		var dataGridId:String = dataGridXML.@id;
        		var dataGridWhere:String = dataGridXML.@where;
        		
        		dataRpcInfo.push({gridId: dataGridId, method: dataGridmethod, field: dataGridWhere, value: _item.id, start: startDate, end: endDate});	// add rpc infos to the  array	
				
    		}

    		//this.DataRpcInfo = dataRpcInfo;
    		return dataRpcInfo;
        }
        
        /**
        * Result handler
        */
        private function DataHandler(result:ResultEvent, test:Object = null):void
        {
        	var fileurl:String = result.result.toString();
        	
            //var filename:String = new String(StringUtil.toString(result.result));
    		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.EXPORT_COMPLETE,this, fileurl));
	    }   
        
       
        /**
        * Fault handler
        */
	    private function faultHandler(fault:FaultEvent, test:Object = null):void
	    {
    		//Alert.show("GetData fault: " +fault.fault.faultString, fault.fault.faultCode.toString());
    		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.LOAD_ERROR_OCCURED,this, fault));
		}
		
		/**
		 * The method which gets called by this class
		 */
		public function get methodName():String
		{
			return METHOD_NAME;
		}     
	}
}