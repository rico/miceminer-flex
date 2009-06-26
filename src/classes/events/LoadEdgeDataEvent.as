package classes.events
{
	import classes.renderer.CustomEdgeLabelRenderer;
	
	import flash.events.Event;
	
	/**
	 * Custom event with a <code>data</code> property to hold the information needed to load the data for an edge.
	 * 
	 * <p>This events are used in the <code>GraphComponent</code>.</p>
	 * 
	 */
	public class LoadEdgeDataEvent extends Event
	{
		
		/**
		 * 
		 */
        public var edge:CustomEdgeLabelRenderer;
        
        /**
        * Load data for an edge in the  graph
        * 
        */
        public static const LOAD_EDGE_DATA:String = "loadEdgeData";
        
       		
        // Public constructor.
        public function LoadEdgeDataEvent(edge:CustomEdgeLabelRenderer) {
                // Call the constructor of the superclass.
                super(LOAD_EDGE_DATA,true,true);
                this.edge = edge;
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new LoadEdgeDataEvent(edge);
        }
  
	}
}