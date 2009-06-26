package classes.events
{
	
	import flash.events.Event;
	
	/**
	 * Custom event to dispatch when the data for the items shoul get loaded.
	 * 
	 * <p>This events are used mainly in the <code>DataOverviewComponent</code>.</p>
	 * 
	 */
	public class LoadItemsEvent extends Event
	{
		
        // Define static constant.
        public static const LOAD_ITEMS:String = "loadItems";
		
        // Public constructor.
        public function LoadItemsEvent(type:String) {
                // Call the constructor of the superclass.
                super(type,true,true);
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new LoadItemsEvent(type);
        }
  
	}
}