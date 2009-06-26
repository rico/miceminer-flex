package classes.components
{
	import classes.datastructures.Item;
	import classes.events.ChangeHeaderEvent;
	import classes.events.ChangeLabelEvent;
	import classes.events.CompBuiltEvent;
	import classes.events.DirectExportEvent;
	import classes.events.LoadDataEvent;
	import classes.helpers.DataHelpers;
	import classes.helpers.DateHelpers;
	import classes.helpers.ExcelExport;
	
	import components.charts.ChartsComponent;
	import components.navigators.GridsNavigator;
	import components.popUps.CopiedToClipboardPopUp;
	import components.popUps.NoDataPopUp;
	import components.renderers.DirectExportRenderer;
	import components.renderers.GetDataRenderer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.containers.HDividedBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.DataGridEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	import mx.states.RemoveChild;
	import mx.states.SetProperty;
	import mx.states.State;
	import mx.utils.ObjectUtil;
	
	/**
	 * Dispatched when the component is ready.
	 * 
	 * @eventType classes.events.CompBuiltEvent.GENERIC_DATA_LOADED
	 */
	[Event(name="Grid", type="classes.events.CompBuiltEvent")]
	
	/**
	 * Dispatched when the columns of the grid are created.
	 * 
	 * @eventType flash.events.Event
	 */
	[Event(name="columnsCreated", type="flash.events.Event")]
	
	
	/**
	 * Dispatched to initialise the data load process.
	 * 
	 * @eventType classes.events.LoadDataEvent.LOAD_DATA
	 */
	[Event(name="loadData", type="classes.events.LoadDataEvent")]
	
	/**
	 * Shows an <code>ArrayCollection</code> of data either as a <code>DataGrid</code> or as a chart.
	 * 
	 * <p>The configuration for this component is fully based on the xml configuration file.</p>
	 */
	public class Grid extends Canvas
	{
		[Bindable]
		private var _dbData:ArrayCollection; 
   		private var _item:Item;
   		private var _xmlConfig:XML;
   		private var _isChildOf:UIComponent;
		private var _filterInformation:Array;
		private var _actualSortGridColumnIndex:uint;
		private var _activeSortGridColumn:DataGridColumn;
		private var	_initsort:String;
		private var	_name:String;
		private var _header:String;
		private var	_filename:String;
		private var _searchGrid:DataGrid;
		private var _searchCharts:ChartsComponent;
		private var _multiSort:Sort;
		private var _mainBox:HDividedBox;
		private var _gridView:State;
		private var _splitView:State;
		private var _chartView:State;
		private var _removeSearchCharts:RemoveChild;
		private var _removeSearchGrid:RemoveChild;
		private var _filterLabel:String;
		private var _searchGridFullWidth:SetProperty;
		private var _searchGridHalfWidth:SetProperty;
		private var _searchChartFullWidth:SetProperty;
		private var _searchChartHalfWidth:SetProperty;
		private var _searchChartSelectedItem:SetProperty;
		private var _zeroDataPop:NoDataPopUp;
		private var _enableGetData:Boolean = false;
		private var _searchGridReady:Boolean;
		private var _searchChartsReady:Boolean;
		private var _itemRenderer:*;
		
		/**
		 * Holds information about the actual filter settings (like the column to filter, and the filter values) for this <code>Grid</code>.
		 * 
		 * <p>The object is actually an element of the <code>labelColName Array</code>.</p>
		 * 
		 * @see classes.components.DataFilterBox
		 */
		public var activeFilter:Object;
		
		/**
		 * Holds a reference of the <code>GridsNavigator</code> component which is the parent of this <code>Grid</code>.
		 */
		public var parentGridsNavigator:GridsNavigator;
		
		
		/**
		 * @param xmlConfig The xml configuration for the <code>&lt;grid&gt;</code>
		 * @param item An instance on an <code>Item</code> if this <code>Grid</code> shows data for an item.
		 */
		public function Grid(xmlConfig:XML, item:Item = null)
		{
			// properties
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
			clipContent = false;
			
			// init variables
			_xmlConfig = xmlConfig;
			_item = item;
			
			id = _xmlConfig.@id;	
			_initsort = _xmlConfig.@initsort;
			_name = _xmlConfig.@label;
			_header = _xmlConfig.@header;
			_filename = _xmlConfig.@filename;
			
			_dbData = new ArrayCollection();
			_multiSort = new Sort();
			
			// adding main component
			_mainBox = new HDividedBox();
			_mainBox.percentHeight = 100;
			_mainBox.percentWidth = 100;
			_mainBox.horizontalScrollPolicy = "off";
			_mainBox.verticalScrollPolicy = "off";
			_mainBox.styleName = "gridsComp";
			
			addChild(_mainBox);

			
			/*
			 	build component contents
			*/
			
			// search grid setup and configuration
			buildSearchGrid();
			
			// search chart setup and configuration
			buildSearchCharts();
			
			// adding states
			addStates();
			
		}
		
		
		/**
		 * Usually called from a <code>GridsNavigator</code> component when this <code>Grid</code> got focus.
		 *
		 * <p>Dispatches a <code>ChangeHeaderEvent</code> with this <code>Grid</code> as argument,
		 * so that the <code>DataFilerBox</code> updatedes to this <code>Grid</Grid>.</p>  
		 *
		 * @see classes.components.DataFilterBox
		 * @see classes.events.ChangeHeaderEvent
		 */
		public function focus():void
		{
			dispatchEvent(new ChangeHeaderEvent(this));
		}
		
		////////////////////////////////////////////////////////////////
		// SORT STUFF
		//////////////////////////////////////////////////////////////// 
		
		/**
		 * Add sort field for each of the searchGrid columns.
		 */ 
		private function initSort():void
		{
			_multiSort.fields = [];
			
			for each (var column:DataGridColumn in _searchGrid.columns) {
				// add the needed sort
				var sort:String = _xmlConfig.col.(@field == column.dataField).@sort; 
				switch(sort) {
						case "numeric":
							column.sortCompareFunction = numericSort;
							_multiSort.fields.push( new SortField(column.dataField, true,false,true) );
						break;
						case "date":
							//GridColumn.sortCompareFunction = dateSortFunction;
							_multiSort.fields.push( new SortField(column.dataField, true) );
						break;
						// alphanum and unrecognized sort values
						default:
							_multiSort.fields.push( new SortField(column.dataField,true) );
						break;
														
					}
			}
			
			_dbData.sort = _multiSort;
			_dbData.refresh();
		}
		
		/**
		 * Sets the sort info for actual column.
		 */
		private function sortInfo(event:DataGridEvent):void
		{
			_actualSortGridColumnIndex = event.columnIndex;
			_activeSortGridColumn = _searchGrid.columns[_actualSortGridColumnIndex];
		}
		
		/**
		 * Numeric sort function.
		 * 
		 */
		private function numericSort(a:Object, b:Object):int
		{
			return ObjectUtil.numericCompare( 
												new Number(a[_activeSortGridColumn.dataField]), 
												new Number(b[_activeSortGridColumn.dataField]) 
											); 
		}
		
		////////////////////////////////////////////////////////////////
		// EVENT LISTENERS
		////////////////////////////////////////////////////////////////

		/**
		 * Creation complete handler.
		 */
		private function compReady(event:FlexEvent):void
		{
			if(_searchGridReady && _searchChartsReady) {
				currentState = "gridView";
				dispatchEvent(new CompBuiltEvent(CompBuiltEvent.GRID, this));	
			}
		}
		
		/**
		 * Shows data on double click
		 */
		private function showData(event:MouseEvent):void
		{
			
			var item:Object = event.target.data;
			
			if( item.hasOwnProperty('data_count') ) {
			
				// check if null data
				if(item.data_count == 0) {
					
					_zeroDataPop = NoDataPopUp(PopUpManager.createPopUp(this, NoDataPopUp, false));
					_zeroDataPop.noDataLabel = "No data for " + item.id;
					
				} else {
				
					// event dispatching for the dataTab
					_item = new Item(item, this.id);
					
					dispatchEvent(new LoadDataEvent(LoadDataEvent.LOAD_DATA, new Item(item, this.id) ));
				}
			}				
		}
		
		/**
		 * Export the data to excel.
		 * 
		 * <p>If the component is in chart view and the visible (active) chart holds a <code>CustPieChart</code> an export grid containing
		 * the grouped data can be added in the xml-configuration for the <code>CustPieChart</code>.</p>
		 *
		 * <p>The available fields in the grouped data are: <code>label, field </code>and </code>count</code>, where label and field contain the same values.</p>
		 *  
		 *  @example This is an example for the configuration of the <code> pieChart &lt;id="antToBoxDataChart"/&gt;</code>.
		 * The <code>exportGrid</code> part is used to generate the Excel file for the export.
		 * The <code>label</code> value for the field <code>label</code> is usually the same as the value defined in the <code>&lt;field /&gt; node. 
		 *
		 * <listing version="3.0">
		 *  &lt;chart type="pieChart" id="antToBoxDataChart">
		 *		&lt;dataTip&gt;Double click to get other mice seen in this box&lt;/dataTip&gt;
		 *		&lt;field&gt;box&lt;/field&gt;
		 *		&lt;desc&gt;Grouped box data for rfid&lt;/desc&gt;
		 *	
		 *		<b>&lt;exportGrid id="antToBoxDataChartGrid" filename="grouped_box_data_for_rfid"&gt;
		 *			&lt;col field="label" label="box" width="100" sort="alphanum"/&gt;
		 *			&lt;col field="count" label="count" width="100" sort="numeric"/&gt;
		 *		&lt;/exportGrid&gt;</b>
		 *	
		 *		&lt;drillDown&gt;
		 *			&lt;gridId&gt;boxData&lt;/gridId&gt;
		 *		&lt;/drillDown&gt;
		 *	&lt;/chart&gt;
		 * </listing>
		 * 
		 * @see components.charts.CustPieChart
		 *  
		 */
		public function exportDataToExcel():void
		{
			
			var exportFilename:String;
			var exportGrid:DataGrid;
			var exportId:String;
			
			if(currentState == 'chartView' && _searchCharts.activeChartXML.hasOwnProperty('grid')) {
				
				var exportGridXML:XML = _searchCharts.activeChartXML.grid[0];
				exportGrid = new DataGrid();
				exportGrid.dataProvider = _searchCharts.activeChartData;
				
				exportFilename = exportGridXML.@filename + '_' + _item.id;
				exportId = exportGridXML.@id;

			} else {
				
				exportGrid = _searchGrid;
				exportFilename =  _filename;
				if(_item) exportFilename += '_' + _item.id;
				exportId = this.id;
				
			}
			
			var Export:ExcelExport = new ExcelExport(exportGrid, exportFilename, exportId);
				
		}
		
		
		/**
		 * Event handler for the direct export
		 */
		private function exportDirectlyToExcel(event:DirectExportEvent):void
		{
         
            var item:Item = new Item(event.data, this.id, true);
			
			dispatchEvent(new LoadDataEvent(LoadDataEvent.LOAD_DATA, item));
			event.stopImmediatePropagation();
		}
		
		/**
		 * Updates the _filterInformation array to reflect the new values when
		 * the _dbData has been filtered.
		 */
		private function updateSort(event:CollectionEvent):void
		{
			
			for each (var sortObject:Object in _filterInformation) {
				var minMax:Array;
				switch (sortObject.sort) {
					case "numeric":
						minMax = DataHelpers.getMinMaxInt(_dbData, sortObject.col); 
						sortObject.min = minMax[0];
						sortObject.max = minMax[1];
						sortObject.value =  minMax;
					break;
					case "date":
						minMax = DateHelpers.getMinMaxDate(_dbData, sortObject.col, true);
						sortObject.min = minMax[0];
						sortObject.max = minMax[1];
						sortObject.value =  [minMax[0].index, minMax[1].index];
					break;
				}
			}
			_dbData.refresh();
		}
		
		/**
		 * 
		 * On shift cklick, copy clicked cell value to te clipboard
		 */
		private function copyToClipboard(event:MouseEvent):void
		{
			if( event.shiftKey && event.target.hasOwnProperty('data') &&
				 event.target.hasOwnProperty('listData') && 
				 event.target.data.hasOwnProperty( event.target.listData.dataField ) &&
				 _searchGrid.allowMultipleSelection == false
				)
			{
				var value:String = event.target.data[ event.target.listData.dataField ];
				
				if(value != null && value != '')
				{
					System.setClipboard(value);
					
					var clipboardPopUp:CopiedToClipboardPopUp = CopiedToClipboardPopUp(PopUpManager.createPopUp(this, CopiedToClipboardPopUp,false,PopUpManagerChildList.POPUP))
					clipboardPopUp.value = value; 
				}
				
			}
		}
		
	
		////////////////////////////////////////////////////////////////
		// SETUP AND CONFIGURE CONTENTS
		//////////////////////////////////////////////////////////////// 
		
		/**
		* create <code>dataGrid</code> for this <code>searchComp</code>and set default properties
		*/
		private function buildSearchGrid():void
		{
			_searchGrid = new DataGrid();
			_searchGrid.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void
			{
				_searchGridReady = true;
				compReady(event);
			});
			
			_searchGrid.enabled = true;
			_searchGrid.editable = false;
			_searchGrid.dragEnabled = false;
			_searchGrid.dataProvider = _dbData;
			
			
			_searchGrid.addEventListener(MouseEvent.CLICK,copyToClipboard);
			
			_searchGrid.styleName = "searchGrid";
			_searchGrid.selectedIndex = 0;
			
			_searchGrid.addEventListener(CollectionEvent.COLLECTION_CHANGE,updateSort);
			_searchGrid.addEventListener(DataGridEvent.HEADER_RELEASE, sortInfo);
			
			_searchGrid.percentHeight = 100;
			_mainBox.addChild(_searchGrid);
			dispatchEvent( new Event("searchGridAvailable") );
		}
		
		/**
		 * Add columns to the search grid based on the configuration in the xml.
		 */
		private function addSearchGridColumns():void
		{
			// search grid columns
			var currentCol:int = 0;
			var searchGridColumns:Array = [];
			
			for each (var colXML:XML in columnsXML) {
				
				var gridColumn:DataGridColumn = new DataGridColumn();
				
				gridColumn.dataField = colXML.@field;
				gridColumn.headerText = colXML.@label;
				gridColumn.width = Number(colXML.@width);
								
				// set header render properties and initial sort
				if (gridColumn.dataField == _initsort) {
					_actualSortGridColumnIndex = currentCol;
					_activeSortGridColumn = gridColumn;
				}
				
				if(_itemRenderer) {
					gridColumn.itemRenderer = new ClassFactory(_itemRenderer);
				}
				
				// add the columns and their corresponding sort
				searchGridColumns.push(gridColumn);
				currentCol++;
			}
			
			
			// add a column to enable dicrect export of the data
			if(_enableGetData) {
				
				var getDataColumn:DataGridColumn = new DataGridColumn();
				var getDataclassFac:ClassFactory = new ClassFactory(GetDataRenderer);
				getDataclassFac.properties = {gridId: this.id, header: _header};
				getDataColumn.itemRenderer = getDataclassFac;
				getDataColumn.sortable = false;
				getDataColumn.width = 20;
				getDataColumn.setStyle('paddingLeft', 3);
				getDataColumn.setStyle('paddingright', 3);
				searchGridColumns.push(getDataColumn);
				
				var directExportColumn:DataGridColumn = new DataGridColumn();
				var exportDataclassFac:ClassFactory = new ClassFactory(DirectExportRenderer);
				exportDataclassFac.properties = {header: _header};
				directExportColumn.itemRenderer = exportDataclassFac;
				directExportColumn.sortable = false;
				directExportColumn.width = 20;
				directExportColumn.setStyle('paddingLeft', 3);
				directExportColumn.setStyle('paddingright', 3);
				searchGridColumns.push(directExportColumn);
				
			}
			
			_searchGrid.columns = searchGridColumns;
			dispatchEvent(new Event("columnsCreated") );

		}
		
		/**
		 * Build <code>searchChart</code> for this <code>searchComp</code>
		 */
		private function buildSearchCharts():void
		{
			//addEventListener(CompBuiltEvent.CHARTS_COMPONENT, chartsReady);
			_searchCharts = new ChartsComponent();
			_searchCharts.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void
			{
				_searchChartsReady = true;
				compReady(event);
			});
			
			_searchCharts.grid = this;
			_searchCharts.percentHeight = 100;
			_mainBox.addChild(_searchCharts);
			dispatchEvent( new Event("searchChartsAvailable") );
		}
		
		/**			
		 * Custom data tip.
		 */
		private function custDataTip(item:Object):String
		{
			if(item.id != '') {
				return "Double click to get the data for " + _header + " " + item.id;	
			} else {
				return '';
			}

		}
		
		/**
		 * Create an Array with the filter information needed.
		 */ 
		private function buildFilterInformation():void
		{
			_filterInformation = [];
			var minMax:Array = [];
			for each (var column:DataGridColumn in _searchGrid.columns) {
				
				if(column.headerText != null) {
					// build string for the filter combo box
					var comboText:String = "filter column " + column.headerText;
					
					if(_item) {
						comboText += " in " + _header + " " + _item.id; 	
					} else if(_name) {
						comboText = "filter column " + column.headerText + " in " + _name;
					}
					
					// add the needed sort
					var sort:String = _xmlConfig.col.(@field == column.dataField).@sort; 
					switch(sort) {
							// numeric
							case "numeric":
								
								minMax = DataHelpers.getMinMaxInt(_dbData, column.dataField); 
								_filterInformation.push({label: column.headerText, comboLabel: comboText, col: column.dataField, 
													sort:sort, min: minMax[0], max: minMax[1], value: minMax});
							break;
							
							break;
							// date
							case "date":
								
								minMax = DateHelpers.getMinMaxDate(_dbData, column.dataField, true);
								_filterInformation.push({label: column.dataField, comboLabel: comboText, col: column.dataField,
													 sort:sort, min: minMax[0], max: minMax[1], value: [minMax[0].index, minMax[1].index]});
							break;
							// alphanum and unrecognized 
							case "alphanum":
								_filterInformation.push({label: column.headerText, comboLabel: comboText, col: column.dataField, 
													sort:sort, value: ""});
							break;
															
					}
				}
				
			}
			
			// Adding  "choose" entry to the column labels
			if(_item) {
				_filterInformation.unshift({comboLabel: "choose a column to filter the " + _header + " " + _item.id, sort:''});	
			} else if(_name){
				_filterInformation.unshift({comboLabel: "choose a column to filter the data in " + _name, sort:''});
			}
		}
		
		/**
		 * States.
		 */ 
		private function addStates():void
		{
			_removeSearchCharts = new RemoveChild(_searchCharts);
			_removeSearchGrid = new RemoveChild(_searchGrid);
			_searchGridFullWidth = new SetProperty(_searchGrid, 'percentWidth', 100);
			_searchGridHalfWidth = new SetProperty(_searchGrid, 'percentWidth', 50);
			_searchChartFullWidth = new SetProperty(_searchCharts, 'percentWidth', 100);
			_searchChartHalfWidth = new SetProperty(_searchCharts, 'percentWidth', 50);
			//_searchChartSelectedItem = new SetProperty(_searchCharts, 'selectedItem', _searchGrid.selectedItem);
			
			_gridView = new State();
			_gridView.name = "gridView";
			_gridView.addEventListener(FlexEvent.ENTER_STATE, setExportLabel);
			_gridView.overrides.push(_removeSearchCharts, _searchGridFullWidth);
			
			_splitView = new State();
			_splitView.name = "splitView";
			_splitView.addEventListener(FlexEvent.ENTER_STATE, setExportLabel);
			_splitView.overrides.push(_searchGridHalfWidth, _searchChartHalfWidth);
			
			_chartView = new State();
			_chartView.name = "chartView";
			_chartView.addEventListener(FlexEvent.ENTER_STATE, setExportLabel);
			_chartView.overrides.push(_removeSearchGrid, _searchChartFullWidth);
			
			states.push(_gridView, _splitView, _chartView);
		}
		
		
		////////////////////////////////////////////////////////////////
		// GETTER SETTERS
		////////////////////////////////////////////////////////////////
		
		/**
		 * Set of data handled by this component.
		 * 
		 * <p>The objects in the <code>ArrayCollection</code> need to have the properties the xml configuration
		 * defines for this <code>&lt;grid&gt;</code>.</p>
		 */
		public function get dbData():ArrayCollection
		{
			return _dbData;
				
		}
		
		/**
		 * @private
		 */
		public function set dbData(data:ArrayCollection):void
		{
			if(data) {
				_dbData = data;
				_searchGrid.dataProvider = _dbData;
				addSearchGridColumns();
				buildFilterInformation();
				initSort();
				label = _name + ' (' +  _dbData.length.toString() + ')';
				
				_dbData.addEventListener(CollectionEvent.COLLECTION_CHANGE, changeLabel);
				
				// display initial sort
				_searchGrid.dispatchEvent( new DataGridEvent(
					DataGridEvent.HEADER_RELEASE,false,true,_actualSortGridColumnIndex, _initsort,0,null,null,0)
				);
			}
		}
		
		/**
		 * The item this <code>Grid</code> handles the data for.
		 * 
		 * <p>The double click handler in the <code>searchGrid</code> is disabled when showing data for an item.</p> 
		 */
		public function get item():Item
		{
			return _item;
		}
		
		/**
		 * The leading words for the filter labels in the <code>ComboBox</code> of the <code>DataFilterBox</code>.
		 * 
		 * @see classes.components.DataFilterBox
		 */
		public function get filterLabel():String
		{
			return _filterLabel;
		}
		
		/**
		 * @private
		 */
		public function set filterLabel(filterLabel:String):void
		{
			_filterLabel = filterLabel;
			
			if(_filterInformation) {
				_filterInformation.shift();
				
				for each (var filterData:Object in _filterInformation) {
					filterData.comboLabel = _filterLabel + " " + filterData.label; 		
				}
				
				_filterInformation.unshift({comboLabel: "choose a column to filter the data", sort:''});
			}
			
		}
		
		/**
		 * Tool tip value for the <code>searchGrid</code>.
		 */
		public function get gridToolTip():String
		{
			return searchGrid.toolTip
		}
		
		/**
		 * @private
		 */
		public function set gridToolTip(text:String):void
		{
			_searchGrid.showDataTips = false;
			_searchGrid.dataTipFunction = null;
			_searchGrid.toolTip = text;
		}
		
		/**
		 * The <code>filename</code> attribute value of the <code>grid</code> xml configuration which is used in the export handling.
		 * 
		 * @see classes.helpers.ExcelExport
		 * @see classes.rpc.ExportData
		 */
		public function get filename():String
		{
			return _filename;
		}
		
		/**
		 * The <code>DataGrid</code> shown in the <code>gridView</code> and <code>splitView</code> states.
		 */
		[Bindable(event="searchGridAvailable")]
		public function get searchGrid():DataGrid
		{
			return _searchGrid;
		}
		
		/**
        * The </code>ChartsComponent</code> is in the <code>chartView</code> and <code>splitView</code> states.
        */
        [Bindable(event="searchChartsAvailable")]
        public function get searchCharts():ChartsComponent
        {
        	return _searchCharts;	
        }
		
		/**
   		 * An associative <code>Array</code> with <code>[columnIndex] = <i>column filter information</i></code> pairs.
   		 */ 
   		 public function get filterInformation():Array  
   		{
   			return _filterInformation;
   		}
   		
   		/**
		 * The xml configuration for the columns of the <code>searchGrid</code>.
		 */
   		public function get columnsXML():XMLList
   		{
   			return _xmlConfig.col;
   		}
   		
		/**
		 * A reference to the column the <code>searchGrid</code> is actually sorted on.
		 */
   		public function get activeSortGridColumn():DataGridColumn
   		{
   			return _activeSortGridColumn;
   		}
   		
   		/**
		 * Is a part of the labels shown in the <code>DataFilterBox comboBox </code>.
		 * 
		 * <p>The value is defined by the <code>header</code> attribute value in the xml configuration of the <code>Grid</code>.</p>
		 * 
		 * @see classes.components.DataFilterBox  
		 */
   		public function get header():String
   		{
   			return _header;
   		}
   		
   		/**
		 * When setting to true, enables the double cklick handler on the grid items to get data.
		 * 
		 * <p>When the user double clicks an item in the <code>searchGrid</code> a <code>LoadDataEvent</code> is dispatched, with  
		 * the clicked object wrapped in an <code>Item</code> instance.<br/>The data corresponding to the <code>Item</code> will be shown in <i>miceminer</i>.</p>
		 * 
		 * 
		 * <p>Furthermore, an additional column with an <i>Excel</i> icon is shown. When the user clicks on that icon, the a <code>LoadDataEvent</code> is dispatched, with 
		 *  the clicked object wrapped in an <code>Item</code> instance, where the <code>toExcel</code> flag is set to true.<br/>The data corresponding to the </code>Item</code> 
		 * is directly exported to <i>Excel</i>.</p>
		 * </p>
		 * 
		 * @default false
		 * @see classes.events.LoadDataEvent
		 * @see classes.datastructures.Item
		 * @see classes.rpc.ExportData
		 */
   		public function get enableGetData():Boolean
   		{
   			return _enableGetData;
   		}
   		
   		/**
   		 * @private
   		 */
   		public function set enableGetData(enable:Boolean):void
   		{
   			if( enable != _enableGetData) {
   				_enableGetData = enable;
   				addSearchGridColumns();
   				
   				if( enable ) { // enabling/disabling double click handler to enable showData()	
					_searchGrid.doubleClickEnabled = true;
					_searchGrid.addEventListener(MouseEvent.DOUBLE_CLICK, showData);
					_searchGrid.addEventListener(DirectExportEvent.DIRECT_EXPORT_DATA, exportDirectlyToExcel);
   				} else {
					_searchGrid.doubleClickEnabled = false;
					_searchGrid.removeEventListener(MouseEvent.DOUBLE_CLICK, showData);
					_searchGrid.removeEventListener(DirectExportEvent.DIRECT_EXPORT_DATA, exportDirectlyToExcel);
   				}
   			}
   		}
   		
   		public function get selectedItem():Item
   		{
   			return new Item(_searchGrid.selectedItem, this.id);
   		}
   		
   		/**
   		 * @private
   		 */
   		public function set selectedItem(item:Item):void
   		{
   			
   			try {
   				if(item.gridId == this.id) {
					_searchGrid.selectedIndex = findObjectById(item.data);
   					_searchGrid.scrollToIndex(_searchGrid.selectedIndex);
   				} else {
   					throw new Error("item.gridId is not the same as this grid id. Item doesn't belong to this grid");
   				}
   			} catch(e:Error) {
   				trace(e.message);
   			}
   		}
   		/**
   		 * itemRenderer for the searchGrid columns.
   		 */ 
   		public function get itemRenderer():*
   		{
   			return _itemRenderer;
   		}
   		
   		/**
   		 * @private
   		 */
   		public function set itemRenderer(renderer:*):void
   		{
   			_itemRenderer = renderer;
   		}
	
		
		////////////////////////////////////////////////////////////////
		// OTHER METHODS
		////////////////////////////////////////////////////////////////
		
		/**
		 * Change the label when the array collection changes.
		 */
		private function changeLabel(event:Event):void
		{
			if(_dbData != null){ 
				label = _name + ' (' +  _dbData.length.toString() + ')';
			}
		}
		
		/**
		 * Finds an object in the _dbData by it's id
		 */ 
		private function findObjectById(obj:Object):int
		{
			var foundObjectIndex:int = -1;
			var i:uint = 0;
			while (foundObjectIndex == -1 && i < _dbData.length) {
				if(_dbData[i].id == obj.id) {
					foundObjectIndex = i;
					break; 
				}
				
				i++;
			}
			
			return foundObjectIndex;
		}
		
		/**
		 * Event handler hich dispatches an event itself to set the right label of the <code>exportExcelBut</code> button label
		 *  in <code>GridsNavigator</code> component.
		 */
		 private function setExportLabel(event:FlexEvent):void
		 {
		 	if( currentState == 'chartView' && _searchCharts.activeChartXML.hasOwnProperty('grid') ) {
		 		dispatchEvent( new ChangeLabelEvent( "Export chart data to Excel" ) );	
		 	} else {
		 		dispatchEvent( new ChangeLabelEvent( "Export to Excel" ) );
		 	}
		 	
		 }

	}
}