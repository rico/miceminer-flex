package classes.rpc
{
	
	import classes.GlobalVars;
	import classes.events.*;
	import classes.helpers.DateHelpers;
	
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
	 * Dispatched when the items data are fetched successfully from the database
	 *
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.ITEMS_LOAD_COMPLETE
	 */
	[Event(name="ItemsLoadComplete", type="classes.events.ObjectDataEvent")]
	
	/**
	 * Dispatched when the items data in the passed date range are fetched successfully from the database
	 *
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.ITEMS_IN_DATE_RANGE_LOAD_COMPLETE
	 */
	[Event(name="ItemsInDateRangeLoadComplete", type="classes.events.ObjectDataEvent")]
	
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
	 * @eventType classes.events.EventsGlobals.DATA_LOAD_CANCELED
	 * 
	 * @see classes.events.EventsGlobals
	 */
	[Event(name="DataLoadCanceled", type="classes.events.ObjectDataEvent")]
	
	
	/**
	 * Get items (rfids, boxes antennas) data from the database.
	 * 
	 * <p>The configuration is read from the configuration xml file</p> 
	 * 
	 */
	public class GetItems extends EventDispatcher
	{
		
		private var Globals:GlobalVars;
		private var ConfigXML:XML;
		private var _itemsGridsXML:XMLList;
		private var _dataGridsXML:XMLList;	
		private var _remoteHandlerItems:CreateRO;
		private var _itemsRpcInfo:Array;
		private var _itemsData:Array;
		private var _itemsDataInDateRange:Array;
		private var _method:String;
		private var _gridId:String;
		private var _dateRange:Array;
		private var _timeOut:Timer;
		private var _timeOutCounter:uint;
		
		/**
		 * The constructor is called <b>with the dateRange</b> parameter for grids which are childs of the <b>&lt;itemsGridsInDateRange&gt;</b> node,
		 * and <b>without the dateRange</b> parameter for grids which are childs of the <b>&lt;itemsGrids&gt;</b> node.
		 * 
		 * <p>If the <b>dateRange</b> parameter is present, on successfull data load an event with type <b>ItemsInDateRangeLoadComplete</b> is dispatched,
		 * else the event is of type <b>ItemsLoadComplete</b>.
		 * 
		 * @param dateRange If passed the items data in the date range will be loaded, else all items data will be loaded.
		 */
		public function GetItems(dateRange:Array = null):void
		{
			_dateRange = dateRange;
			this.Globals = GlobalVars.getInstance();
			this.ConfigXML = Globals.ConfigXML;
			_remoteHandlerItems = new CreateRO();
			_itemsRpcInfo = new Array();
			
			if( _dateRange == null ) {
				_itemsRpcInfo = itemsGrids();
				_itemsData = new Array();
				getItemsData();
			} else { 
				_itemsRpcInfo = itemsGridsInDateRangeRpcInfo();
				_itemsDataInDateRange = new Array();
				getItemsInDateRangeData();
				
			}
			
		}
		
		
		/* -----------------------------------------------------------------------------------------------
			main functions
		----------------------------------------------------------------------------------------------- */
		
		 // get items in date range data
        private function getItemsData(event:ResultEvent = null, test:Object = null):void
        {	
        	
        	//the first time we haven't got any data (called from creatGrids)
        	if(event != null) {
        		var dbData:ArrayCollection = new ArrayCollection( ArrayUtil.toArray(event.result));
 				//this.itemsData.push({id: this.gridId, data:dbData});
 				_itemsData[_gridId] =  dbData;
        	}
        	
        	if(_itemsRpcInfo.length > 0) {
        		
        		
            	var rpc:Object = _itemsRpcInfo.pop();
            	_method = rpc.method;
            	_gridId = rpc.gridId;
            	var start:String = rpc.start;
            	var end:String = rpc.end;
            	
            	trace("[GetItems] getItemsData:\tgridId: " + _gridId + "\tmethod: " + _method + "\tstart: " + start + "\tend: " + end);
            	
            	var dbMethod:AbstractOperation = _remoteHandlerItems.getOperation(_method);
				var dbToken:AsyncToken = dbMethod.send(_gridId, start, end);
				setTimout();
					
    			
            	dbToken.addResponder(new AsyncResponder(getItemsData, faultHandler));
            	            	
        	} else {
        		
        		// setting items data to the singleton
        		this.Globals.itemsData = _itemsData;
        		//trace("[GetData] items download complete");
        		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.ITEMS_LOAD_COMPLETE,this, _itemsData));
        		removeTimeout();
        	}
		
        }
		 // get items in date range data
        private function getItemsInDateRangeData(event:ResultEvent = null, test:Object = null):void
        {	
        	
        	//the first time we haven't got any data (called from creatGrids)
        	if(event != null) {
        		var dbData:ArrayCollection = new ArrayCollection( ArrayUtil.toArray(event.result));
 				//this.itemsData.push({id: this.gridId, data:dbData});
 				_itemsDataInDateRange[_gridId] =  dbData;
        	}
        	
        	if(_itemsRpcInfo.length > 0) {
        		
            	var rpc:Object = _itemsRpcInfo.pop();
            	_method = rpc.method;
            	_gridId = rpc.gridId;
            	var start:String = rpc.start;
            	var end:String = rpc.end;
            	
            	trace("[GetItems] getItemsInDateRangeData:\tgridId: " + _gridId + "\tmethod: " + _method + "\tstart: " + start + "\tend: " + end);
            	
            	var dbMethod:AbstractOperation = _remoteHandlerItems.getOperation(_method);
				var dbToken:AsyncToken = dbMethod.send(_gridId, start, end);
				setTimout();
    			
            	dbToken.addResponder(new AsyncResponder(getItemsInDateRangeData, faultHandler));
            	            	
        	} else {
        		
        		// setting items data to the singleton
        		this.Globals.itemsDataInDateRange = _itemsDataInDateRange;
        		DateHelpers.setDateRange(_dateRange);
        		//trace("[GetData] items download complete");
        		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.ITEMS_IN_DATE_RANGE_LOAD_COMPLETE,this, _itemsDataInDateRange));
				removeTimeout();
        	}

        }
        
               
         
        
		/* -----------------------------------------------------------------------------------------------
			private functions
		----------------------------------------------------------------------------------------------- */
		
		private function itemsGrids():Array
        {
      	
        	var itemsRpcInfo:Array = new Array();
        	var itemsGridsXML:XMLList = this.ConfigXML..flex.grids.itemsGrids..grid;
	
        	for each(var gridXML:XML in itemsGridsXML) {
        		//trace("gridXML: " + gridXML);
				var method:String = gridXML..@method;
				var gridId:String = gridXML.@id;	// giving the searchGrid an Id				
				
				itemsRpcInfo.push({gridId: gridId, method: method, start: null, end: null});
    		}           
    		
    		//this.ItemsRpcInfo = itemsRpcInfo;	// add rpc infos to the  array
    		return itemsRpcInfo;
        }        
		
		 // create array containing the infos for the items rpcs
		 // and add it to the RPC Array
        private function itemsGridsInDateRangeRpcInfo():Array
        {
      	
        	var itemsRpcInfo:Array = new Array();
        	var itemsGridsXML:XMLList = this.ConfigXML..flex.grids.itemsGridsInDateRange..grid;
        	
        	var dateRangeF:Array = DateHelpers.formatDate(_dateRange);
        	
        	var startDate:String = dateRangeF[0];
        	var endDate:String = dateRangeF[1];
        	
        	
        	for each(var gridXML:XML in itemsGridsXML) {
        		//trace("gridXML: " + gridXML);
				var method:String = gridXML..@method;
				var gridId:String = gridXML.@id;	// giving the searchGrid an Id				
				
				itemsRpcInfo.push({gridId: gridId, method: method, start: startDate, end: endDate});
    		}           
    		
    		//this.ItemsRpcInfo = itemsRpcInfo;	// add rpc infos to the  array
    		return itemsRpcInfo;
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
				_timeOut.addEventListener(TimerEvent.TIMER, timeoutReached);
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
		 * Cancel data load operations in progress.
		 * 
		 */
		public function cancelGetData():void
		{
			
			if(_remoteHandlerItems != null)
			{
				_remoteHandlerItems.disconnect();
			}
		
			CursorManager.removeBusyCursor();
			removeTimeout(true);
			
		}
		
		
	}
}