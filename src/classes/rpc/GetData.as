package classes.rpc
{
	//import mx.collections.ArrayCollection;
	import classes.GlobalVars;
	import classes.datastructures.Item;
	import classes.events.*;
	import classes.helpers.DateHelpers;
	import classes.helpers.XmlHelper;
	
	import components.popUps.AlertPopUp;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ArrayUtil;
	
	/**
	 * Dispatched when the data for the item is fetched successfully from the database.
	 * 
	 * <p>Along with the event the following data is passed in an array which is the <code>values</code> prooperty of the event:</p>
	 *  	<ul><li><code>event.values[0]</code>: The <code>Item</code> the data has been loaded for</li>
	 * 		<li><code>event.values[1]</code>: The data wrapped in an <code>ArrayCollection</code></li></ul>
	 * 
	 * @see classes.datastructures.Item
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.DATA_LOAD_COMPLETE
	 */
	[Event(name="DataLoadComplete", type="classes.events.ObjectDataEvent")]
	
	
	/**
	 * Dispatched when something in the data fetching process went wrong
	 *
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.LOAD_ERROR_OCCURED
	 */
	[Event(name="LoadErrorOccured", type="classes.events.ObjectDataEvent")]
	
	/**
	 * Dispatched when the <code>cancelGetData()</code> method is called without the <code>event<code> parameter
	 * or when the data loading operation timed out (after 57 seconds).
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.DATA_LOAD_CANCELED
	 */
	[Event(name="DataLoadCanceled", type="classes.events.ObjectDataEvent")]

		
	/**
	 * Get data for an item in the specified date range from the database.
	 * 
	 * <p>The configuration is read from the configuration xml file. Only grids in the &lt;itemsGridsInDateRange&gt; do have data grids</p>
	 * 
	 * @example This is an example for the configuration of the <code>&lt;grid id="miceItem" /&gt;</code> grid which is a child of the &lt;itemsGridsInDateRange&gt; node.
	 * 			In the grid configuration you will find a <code>&lt;dataGrids&gt;</code> node with <code>&lt;id&gt;</code> child nodes.
	 * 
	 * <listing version="3.0">
	 * &lt;dataGrids&gt;
	 *	&lt;id&gt;miceData&lt;/id&gt;
	 *	&lt;id&gt;dirResMice&lt;/id&gt;
	 *	&lt;id&gt;resMice&lt;/id&gt;						
	 * &lt;/dataGrids&gt;
	 * </listing>
	 * 
	 * 		Each of this id node values point to a <code>&lt;grid</code> whith the respective <code>id</code> which is a child of the <code>&lt;dataGrids&gt;</code> node.
	 * 		Taking a closer look at the grid with the id <code>miceData</code> we see the following configuration:
	 * 
	 * <listing version="3.0">  
	 * &lt;grid id ="miceData" where="rfid" header="datasets for mouse" 
	 * 	label="datasets" method="getData" filename="data_for_mouse" initsort="time"&gt;
	 * [...]					
	 * &lt;/grid&gt;	 
	 * </listing>
	 * 
	 * 		The most important attribute of the <code>grid</code> for this class is the <code>method</code> which determines what method to call from the 
	 * 		amfphp service file.
	 * 
	 */
	public class GetData extends EventDispatcher
	{
		
		private var Globals:GlobalVars;
		private var ConfigXML:XML;
		private var _remoteHandlerData:CreateRO;
		private var _dataRpcInfo:Array;		
		private var _dataData:Array;
		private var _method:String;
		private var _gridId:String;
		private var _dateRange:Array;
		private var _item:Item;
		private var _timeOut:Timer;
		private var _timeOutCounter:uint;
		
		/**
		 * Get data for an <code>Item</code> in te specified date range.
		 * 
		 * @param item The <code>Item</code> the data shoul be fetched.
		 * @param dateRange The date range the data should be loaded for
		 * @param singleGrid If the data should be loaded for one grid only. 
		 * The grid the data will be loaded for ist the one spefified in the <code>item.grid</code> property.
		 * This is for example used in the drill down functionality of the charts. 
		 */ 
		public function GetData(item:Item, dateRange:Array, singleGrid:Boolean = false)
		{
			
			this.Globals = GlobalVars.getInstance();
			this.ConfigXML = Globals.ConfigXML;
			
			_dateRange = dateRange;
			_item = item;
			
			_remoteHandlerData = new CreateRO();
        	_dataRpcInfo = new Array();
        	_dataData = new Array();
			
			if(singleGrid) {
				_dataRpcInfo = dataGridRpcInfo();
			} else {
				_dataRpcInfo = dataGridsRpcInfo();
			}
			
			getData();
			
		}
		       
         /**
         * Get data from the database for a selected item
         */ 
        private function getData(event:ResultEvent = null, test:Object = null):void
        {
      
        	//the first time we haven't got any data (called from creatGrids)
        	if(event != null) {
        		var dbData:ArrayCollection = new ArrayCollection( ArrayUtil.toArray(event.result));
 				//this.itemsData.push({id: this.gridId, data:dbData});
 				_dataData[_gridId] =  dbData;
        	}
        	
        	if(_dataRpcInfo.length > 0) {
        		
            	var rpc:Object = _dataRpcInfo.pop();
            	
            	_method = rpc.method;
            	_gridId = rpc.gridId;
            	
            	var field:String = rpc.field;
            	var value:String = rpc.value;
            	var start:String = rpc.start;
            	var end:String = rpc.end;
            	 
            	trace("[GetData] get_dataData:\tgridId: " + _gridId + "\tmethod: " + _method + "\tfield: " + field + "\tvalue: " + value + "\tstart: " + start + "\tend: " + end);
            	
            	var dbMethod:AbstractOperation = _remoteHandlerData.getOperation(_method);
				var dbToken:AsyncToken = dbMethod.send(_gridId, field, value, start, end);	
    			setTimout();
    			
            	dbToken.addResponder(new AsyncResponder(getData, faultHandler));
            	            	
        	} else {
     			//var eventData:ObjectProxy = new ObjectProxy;
     			//eventData.data = this._dataData;
     			//trace("[GetData] data data download complete");
        		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.DATA_LOAD_COMPLETE,this, _item, _dataData));
        		removeTimeout();
        	}

        }
        
        // create array containing the infos for the data rpcs
        // and add it to the RPC Array
        private function dataGridsRpcInfo():Array
        {
        	var _dataRpcInfo:Array = new Array();
        	
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
        		
        		_dataRpcInfo.push({gridId: dataGridId, method: dataGridmethod, field: dataGridWhere, value: _item.id, start: startDate, end: endDate});	// add rpc infos to the  array	
				
    		}

    		//this._dataRpcInfo = _dataRpcInfo;
    		return _dataRpcInfo;
        }
        
        // create array containing the infos for the data rpcs
        // and add it to the RPC Array
        private function dataGridRpcInfo():Array
        {
        	var dataRpcInfo:Array = new Array();
        	
        	// getting dataGrids config (XML)
        	var dataGridXML:XML = XmlHelper.getGridXML( _item.gridId );
        	
        	// getting dateRange
        	var dateRangeF:Array = DateHelpers.formatDate(_dateRange);
        	
        	var startDate:String = dateRangeF[0];
        	var endDate:String = dateRangeF[1];
        	
        	
    		/* var dataGridmethod:String = dataGridXML.@method;
    		var dataGridId:String = dataGridXML.@id;
    		var dataGridWhere:String = dataGridXML.@where; */
    		
    		dataRpcInfo.push({gridId: dataGridXML.@id, method: dataGridXML.@method, field: dataGridXML.@where, value: _item.id, start: startDate, end: endDate});	// add rpc infos to the  array	
				

    		return dataRpcInfo;
        }
        
        // called when a rpc fault occurs
	    private function faultHandler(fault:FaultEvent, test:Object = null):void
	    {
    		//Alert.show("GetData fault: " +fault.fault.faultString, fault.fault.faultCode.toString());
    		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.LOAD_ERROR_OCCURED,this, fault));
		}
		
		/**
		 * Sets a timeout for the operation
		 */
		private function setTimout():void
		{
			if(_timeOut) {
				_timeOutCounter++;
				_timeOut.reset();
			} else {
				_timeOut = new Timer(57000,1);
				_timeOut.start();
				_timeOut.addEventListener(TimerEvent.TIMER, cancelGetData);
				_timeOutCounter = 1;
			}
			
		}
		
		/**
		 * Remove the timeout for the operation
		 */ 
		private function removeTimeout(all:Boolean = false):void
		{
			if( all || _timeOutCounter == 1 ) {
				_timeOut.stop();
				_timeOut.reset();
				_timeOut.removeEventListener(TimerEvent.TIMER,cancelGetData);
				_timeOutCounter = 0;
			} else {
				_timeOutCounter--;
			}
		}
		
		/**
		 * Timeout reached
		 */
		private function timeoutReached(event:TimerEvent):void
		{
			cancelGetData();
			
			event.stopPropagation();
			Globs.broker.dispatchEvent(new Event(EventsGlobals.DATA_LOAD_CANCELED));
			var timeOutAlert:AlertPopUp = AlertPopUp(PopUpManager.createPopUp(Application.application.navigators as DisplayObject, AlertPopUp,true));
			timeOutAlert.alert_text = "The request has timed out.\nThis usually occurs if the requested data volume is to large." + 
					"If the timeout occurs with small data volumes as well, please contact the administrator.";
		}
		
		/**
		 * Cancel operations in progress
		 */
		public function cancelGetData():void
		{
			if(_remoteHandlerData != null)
			{
				_remoteHandlerData.disconnect();
				
			}	
			
			CursorManager.removeBusyCursor();
			removeTimeout(true);
			
		}
		
		
	}
}