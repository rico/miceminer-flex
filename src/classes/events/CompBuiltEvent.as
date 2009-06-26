package classes.events
{
	import flash.events.Event;
	
	/**
	 * Dispatched by some components when they finished with the setup.
	 */ 
	public class CompBuiltEvent extends Event
	{
		
        private var _component:*;
        
        /**
        * Use for <code>GridNavigator</code>.
        * 
        * @see components.navigators.GridNavigator
        */
        public static const GRIDS_NAVIGATOR:String = "GridsNavigator";
        
        /**
        * Use for <code>Grid</code>.
        * 
        * @see components.grids.Grid
        */
        public static const GRID:String = "Grid";
        
        /**
        * @private
        */
        public static const SEARCH_GRID:String = "searchGrid";
        
        /**
        * Use for <code>ChartsComponent</code>.
        * 
        * @see components.charts.ChartsComponent
        */
        public static const CHARTS_COMPONENT:String = "ChartsComponent";
        
        /**
        * @private
        */
        public static const SEARCH_CHART_ELEMENT:String = "searchChartElement";
	        
        
        /**
        * @param type One of the constants defined for this event
        */
        public function CompBuiltEvent(type:String, component:*) {
                
                super(type,true,false);
                _component = component;
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new CompBuiltEvent(type, component);
        }
        
       /**
		 * Reference to the component dispatching the event.
		 * 
		 * <p>Based on the <code>type</code> parameter of the event, you can derive the object type.</p>
		 */
        public function get component():*
        {
        	return _component;
        }
	}
}