package classes.events
{
	import flash.events.Event;
	
	/**
	 * Custom event with a <code>view</code> parameter which corresponds to a view state in a <code>DataMinerComponent</code>
	 * or a <code>Grid</code> component.
	 * 
	 * @see components.grids.Grid
	 */
	public class RequestViewEvent extends Event
	{
		/**
		 * Corresponds to the <code>itemsView</code> view state in the <code>DataMinerComponent</code>.
		 */ 
       	public static const ITEMS_VIEW:String = "ItemsView";
       	/**
		 * Corresponds to the <code>dataView</code> view state in the <code>DataMinerComponent</code>.
		 */
        public static const DATA_VIEW:String = "DataView";
        /**
		 * Corresponds to the <code>chartView</code> view state in the <code>Grid</code>.
		 */
        public static const CHART_VIEW:String = "ChartView";
        /**
		 * Tell a <code>DataMinerComponent</code> or a <code>Grid</code> component to switch back to a cached view state.
		 */
        public static const RESTORE_VIEW:String = "RestoreView";
        /**
		 * Tell a <code>DataMinerComponent</code> that the <code>GridsNavigator</code> close button has been clicked.
		 */
        public static const DATA_CLOSED:String = "DataClosed";
        
        
       /**
       * @param type One of the constants defined for this event.
       */ 
        public function RequestViewEvent(type:String) {
                // Call the constructor of the superclass.
                super(type,true,true);
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new RequestViewEvent(type);
        }
	}
}