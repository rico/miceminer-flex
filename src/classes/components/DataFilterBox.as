package classes.components
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
	
	import classes.events.SliderChangedEvent;
	
	import components.sliders.RangeFilterSliderDate;
	import components.sliders.RangeFilterSliderNumeric;
	
	import flash.events.Event;
	
	import mx.containers.HBox;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.events.CollectionEvent;
	import mx.events.ListEvent;
	import mx.events.SliderEvent;
	
	/**
	 * Handles data filtering of a <b>Grid</b> component.
	 * 
	 * <p>Based on the selected grid in the miceminer, this class shows a <code>ComboBox</code> with all columns of the <code>Grid</code> component which can be filtered.
	 * Each of this columns have a configuration in the <b>configuration xml file</b> with an attribute named <b>sort</b>. Based on this value a suitable filter control component 
	 * is shown on the right of the <code>ComboBox</code>.</p>
	 * 
	 * <p>Description of the possible values of the sort attribute:</p>
	 * 
	 * @example <b>Alphanumeric sort</b> configuration of the <i>rfid</i> column.</p>
	 * 
	 * <listing version="3.0">
	 * &lt;col field="rfid" label="rfid" width="80" sort="alphanum"/&gt;
	 * </listing>
	 * 			<p> A <b>ClearTextInput</b> component will be shown if the user choose to filter this column from the <code>ComboBox</code>.</p>
	 * 			
	 * @example Numeric sort</b> configuration of the <i>data count</i> column.</p>
	 * <listing version="3.0">
	 * &lt;col field="data_count" label="data count" width="80" sort="numeric"/&gt;
	 * </listing> 			
	 * 			<p>A <b>RangeFilterSliderNumeric</b> component will be shown if the user choose to filter this column from the <code>ComboBox</code>.</p>
	 *			
	 * @example <b>Date type sort</b> configuration of the <i>implant date</i> column.</p>
	 * <listing version="3.0">
	 * &lt;col field="implant_date" label="implant date" width="100" sort="date"/&gt;
	 * </listing>
	 * 			<p>A <b>RangeFilterSliderDate</b> component will be shown if the user choose to filter this column from the <code>ComboBox</code>.</p>
	 *
	 * @see classes.components.ClearTextInput
	 * @see components.sliders.RangeFilterSliderNumeric
	 * @see components.sliders.RangeFilterSliderDate
	 * @see classes.GlobalVars
	 *   
	 */
	public class DataFilterBox extends HBox
	{
		private var _searchFilterText:ClearTextInput;
		private var _searchFilterRangeNumeric:RangeFilterSliderNumeric;
		private var _searchFilterRangeDate:RangeFilterSliderDate;
		private var _activeSearchComp:Grid;
		private var _searchComboBox:ComboBox;
		
		private var _filterBox:HBox;
		private var _multiFilter:CheckBox;
		private var _comboBoxStyleName:String;
		private var _textInputStyleName:String;
		
			
		/**
		 * Constructor
		 */
		public function DataFilterBox():void
		{
			super();
			this.percentWidth = 100;
			this.height = 25;
			
			
			/* -----------------------------------
				CONFIGURE LAYOUT COMPONENTS
			/----------------------------------- */
			// ComboBox
			
			_searchComboBox = new ComboBox();
			_searchComboBox.minWidth = 250;
			_searchComboBox.maxWidth = 520;
			_searchComboBox.height = 20;
			_searchComboBox.enabled = true;
			_searchComboBox.toolTip = "click to choose a column based filter for the actual grid";
			_searchComboBox.styleName = comboBoxStyleName;
			_searchComboBox.labelField = "comboLabel";
			_searchComboBox.rowCount = 10;
			_searchComboBox.addEventListener("change",changeFilterType);
			
			addChild(_searchComboBox);

			// filter box
			_filterBox = new HBox();
			_filterBox.percentWidth= 100;
			_filterBox.height = 22;
			
			addChild(_filterBox);
			
			/* ------------------------------
            	CONFIGURE FILTER COMPONENTS
        	------------------------------ */
        	var filterH:int = _searchComboBox.height;
        	var filterW:int = 150;
        	
        	// text input filter
        	_searchFilterText = new ClearTextInput();
        	_searchFilterText.name ="_searchFilterText";
        	_searchFilterText.styleName = _textInputStyleName;
        	_searchFilterText.toolTip = "Enter the search term";
        	_searchFilterText.editable = true;
        	_searchFilterText.enabled = true;
        	_searchFilterText.height = filterH;
        	_searchFilterText.width = filterW;
        	_searchFilterText.addEventListener(Event.CHANGE,alphanumFilter);
        	
        	// numeric slider filter
        	_searchFilterRangeNumeric = new RangeFilterSliderNumeric();
        	_searchFilterRangeNumeric.name = "_searchFilterRangeNumeric";
      		_searchFilterRangeNumeric.height = filterH;
      		_searchFilterRangeNumeric.percentWidth = 100;
      		_searchFilterRangeNumeric.maxWidth = this.width;
        	_searchFilterRangeNumeric.addEventListener(SliderChangedEvent.SLIDER_CHANGED_NUMERIC,rangeFilterNumeric);
        	
        	// date slider filter
        	_searchFilterRangeDate = new RangeFilterSliderDate();
        	_searchFilterRangeDate.name = "_searchFilterRangeDate";
      		_searchFilterRangeDate.height = filterH;
      		_searchFilterRangeDate.percentWidth = 100;
        	_searchFilterRangeDate.addEventListener(SliderChangedEvent.SLIDER_CHANGED_DATE,rangeFilterDate);
			
		}
		
		/**
		 * An instance of a <b>Grid</b> component to apply the filter.
		 * 
		 * <p>The <b>ComboBox</b> data is provided by the <b>labelColName</b> property of the <b>Grid</b> instance.
		 * <p>The actual filter is stored in the <b>actFilter</b> proprty of the <b>Grid</b> instance.</p>
		 * 
		 * @see components.grid.Grid
		 */
		public function set activeComp(activeSearchComp:Grid):void
		{  
			_activeSearchComp = activeSearchComp;
			_searchComboBox.dataProvider = _activeSearchComp.filterInformation;
			
			try{
				if(!_activeSearchComp.activeFilter) {
					throw new Error("activeFilter must not be null");
					
				}
				_searchComboBox.selectedItem = searchActiveFilter(_activeSearchComp.activeFilter, _activeSearchComp.filterInformation);
			} catch (err:Error){
				trace( err.message );
				
			}
			
			setFilter(); 
			
		}
		
		/**
		 * Get the active filter object.
		 */
		private function searchActiveFilter(selectedFilter:Object, filterInformation:Array):Object
		{
			if(!selectedFilter) {
				return filterInformation[0];
			}
			
			for each (var filterInfo:Object in filterInformation) {
				if(filterInfo.comboLabel == selectedFilter.comboLabel) {
					return filterInfo;
				}
			}
			
			return filterInformation[0];
		}
		
		/**
		 * @private
		 */
		 public function get activeComp():Grid
		 {
		 	return _activeSearchComp;
		 }
		 
		 public function set comboBoxStyleName(styleName:String):void
		 {
		 	_comboBoxStyleName = styleName;
		 	_searchComboBox.styleName = _comboBoxStyleName;
		 }
		 
		 /**
		 * Style class name for the <code>ComboBox</code> component.
		 */
		 public function get comboBoxStyleName():String
		 {
		 	return _comboBoxStyleName;
		 }
		 
		 
		 public function set textInputStyleName(styleName:String):void
		 {
		 	_textInputStyleName = styleName;
		 	_searchFilterText.styleName = _textInputStyleName;
		 }
		 
		 /**
		 * Style class name for the <code>ClearTextInput</code> component.
		 */
		 public function get textInputStyleName():String
		 {
		 	return _textInputStyleName;
		 }
		 
		
		/**
		 * Set filter to default, meaning no filter is choosen from the <b>ComboBox</b> component, and no filter component 
		 * is shown to the right of the <code>ComboBox</code>.
		 */
		public function setToDefault():void
		{
			_searchComboBox.selectedIndex  = 0;
			_filterBox.removeAllChildren();
			_activeSearchComp.dbData.filterFunction = null;
			_activeSearchComp.dbData.refresh();
			
		}
		
		/* ----------------------------------------------------------------------------------------------- */
			// Set the appropriate filter for the chosen field in the combobox
			/**
			 * Set the appropriate filter type for the chosen field in the <code>_searchComboBox</code>.
			 * Gets the <code>selectedItem</code> from the <code>_searchComboBox</code> and
			 * based on that updates the <code>actFilter</code> attributes on the <code>activeGrid</code>
			 */ 
			private function changeFilterType(event:ListEvent):void
			{
				_activeSearchComp.activeFilter = _activeSearchComp.filterInformation[ event.currentTarget.selectedIndex ];
				//_activeSearchComp.activeFilter = _activeSearchComp.selectedItem;
					
				setFilter();
			}
			
			/**
			 * Set filter type <code>changeHeaderEvent</code> based on the <code>actFilter</code> attribute of the active
			 * <code>searchGrid</code>
			 * <ul><li><emp>alphanum</emp>: A <code>clearTextInput</code> is shown for alphanumeric search.</li>
			 * <li><emp>numeric</emp>: A <i>flexlib</i> <code>HSlider</code> is showwn with to thumbs to select the <emp>numeric range</emp>.</li>
			 * <li>date: A <i>flexlib</i> <code>HSlider</code> is shown with to thumbs to select the <emp>date
			 *  range</emp>.</li></ul>
			 */
			private function setFilter():void
			{
				_filterBox.removeAllChildren();
				
				switch(_activeSearchComp.activeFilter.sort) {
					case "alphanum": 
						// add to display list
            			_filterBox.addChild(_searchFilterText);
            			
            			
            			
            			// set filter value
            			_searchFilterText.text = _activeSearchComp.activeFilter.value;
            			
            			// set filter function
            			_activeSearchComp.dbData.filterFunction = alphanumFilterFunction;
            			_activeSearchComp.dbData.refresh();
            			
            			// initialize the filter
            			_searchFilterText.dispatchEvent( new Event(Event.CHANGE) );
	            		
            			
					break;
					case "numeric":
						// add to display list
						_filterBox.addChild(_searchFilterRangeNumeric);
						
						// set filter function
						_activeSearchComp.dbData.filterFunction = rangeFilterNumericFunction;
						
						// set slider configuration
						_searchFilterRangeNumeric.setConf(_activeSearchComp.activeFilter);
						
						// set slider values
						_searchFilterRangeNumeric.setValues(_activeSearchComp.activeFilter.value);
						
						// apply filter
						_searchFilterRangeNumeric.slider.dispatchEvent( new SliderEvent(SliderEvent.CHANGE) );
						
						
					break;
					case "date":
						// add to display list
						_filterBox.addChild(_searchFilterRangeDate);
						
						// set filter function 
						_activeSearchComp.dbData.filterFunction = rangeFilterDateFunction;
						
						// set slider configuration
						_searchFilterRangeDate.setConf(_activeSearchComp.dbData, _activeSearchComp.activeFilter);
						
						// set slider values (date range slider)
						_searchFilterRangeDate.setValues(_activeSearchComp.activeFilter.value);
						
						// apply filter
						_searchFilterRangeDate.slider.dispatchEvent( new SliderEvent(SliderEvent.CHANGE) );
						
					break;
					default:
						setToDefault();
					break;
				}
				
			}
			
			/* ------------------------------
            	FILTER FUNCTIONS
            ------------------------------ */
            
            /* ---------------------------------------------------------------------
			 Alphanumeric filter
			--------------------------------------------------------------------- */
			/**
			 * Alphanumeric filter
			 */
			private function alphanumFilter(event:Event):void
			{
				
				// updating filter info
				_activeSearchComp.activeFilter.value = _searchFilterText.text;
				_activeSearchComp.filterInformation[ _searchComboBox.selectedIndex ].value = _searchFilterText.text;
				_activeSearchComp.dbData.filterFunction = alphanumFilterFunction;
				_activeSearchComp.dbData.refresh();
				trace("filtering");
				
			}
			
			
			/**
			 * Alphanumeric filter callback function
			 */
			private function alphanumFilterFunction(entry:Object) : Boolean
			{
				var isMatch:Boolean = false;
				var searchCol:String = _searchComboBox.selectedItem.col;
				var i:uint = 1;
				for (var prop:String in entry) 
				{
 				  	if(prop == searchCol)
 				  	{
 				  		var value:Object = entry[prop];
 				  		
 				  		if(value != null) {
 				  		
	 				  		if(entry[prop].toLowerCase().search(_searchFilterText.text.toLowerCase()) != -1)
							{
								isMatch = true;
							}
 				  		}
 				  	}
 				  	            
				}			
				
				return isMatch;     
			}
			
			/* ---------------------------------------------------------------------
			 Numeric Range filter
			--------------------------------------------------------------------- */
			/**
			 * Numeric filter
			 */			
			private function rangeFilterNumeric(event:SliderChangedEvent):void
			{
				
				// updating filter info
				_activeSearchComp.activeFilter.value = _searchFilterRangeNumeric.slider.values;
				_activeSearchComp.filterInformation[ _searchComboBox.selectedIndex ].value = _searchFilterRangeNumeric.slider.values;
				
				_activeSearchComp.dbData.refresh();
				
			}
			
			/**
			 * Numeric filter callback function
			 */
			private function rangeFilterNumericFunction(entry:Object) : Boolean
			{
				
				var isMatch:Boolean = false;
				
				var searchCol:String = _searchComboBox.selectedItem.col;
				
				//trace ("Range Filter for range " + searchFilterRangeNumeric.minValLabel + " to " + searchFilterRangeNumeric.maxValLabel + " in col " + searchCol);
				
				for (var prop:String in entry) 
				{
 				  	if(prop == searchCol)
 				  	{
 				  		var value:Object = entry[prop];
 				  		
 				  		if(value >= _searchFilterRangeNumeric.slider.values[0] && value <= _searchFilterRangeNumeric.slider.values[1])
						{
							isMatch = true;
							//trace ("Range Filter found " + searchFilterRangeNumeric.slider.values[0].toString()  + " < " + value + " < " + searchFilterRangeNumeric.slider.values[1].toString()  + " in col " + searchCol);
						}
 				  	}             
				}			
				
				return isMatch;     

			}
			
			/* ---------------------------------------------------------------------
			 Date Range filter
			--------------------------------------------------------------------- */
			/**
			 * Date filter
			 */			
			private function rangeFilterDate(event:SliderChangedEvent):void
			{
				
				// updating filter info
				_activeSearchComp.activeFilter.value = _searchFilterRangeDate.slider.values;
				_activeSearchComp.filterInformation[ _searchComboBox.selectedIndex ].value = _searchFilterRangeDate.slider.values;
				_activeSearchComp.dbData.refresh();
				
				
			}
			
			/**
			 * Date filter callback function
			 */
			private function rangeFilterDateFunction(entry:Object) : Boolean
			{
				
				var isMatch:Boolean = false;
				
				//var searchCol:String = _searchComboBox.selectedItem.col;
				
				// get postition of the entry object in the sorted array collection (see few lines above)
				// to compare positions (indexes) 
				var entryPos:int = _activeSearchComp.dbData.source.indexOf(entry);

 		  		if(entryPos >= _searchFilterRangeDate.slider.values[0] && entryPos <= _searchFilterRangeDate.slider.values[1])
				{
					isMatch = true;
					//trace ("Range Filter Date found " + searchFilterRangeDate.slider.values[0].toString()  + " < " + entryPos + " < " + searchFilterRangeDate.slider.values[1].toString());
				}			
				
				return isMatch;     

			}

	}
}