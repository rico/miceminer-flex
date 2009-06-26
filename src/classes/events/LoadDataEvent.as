package classes.events
{
	import classes.datastructures.Item;
	
	import flash.events.Event;
	
	/**
	 * Custom event with a <code>dataInfo</code> property to hold the information needed for the data loading process.
	 * 
	 * <p>This events are used mainly in the <code>DataMinerComponent</code>.</p>
	 * 
	 */
	public class LoadDataEvent extends Event
	{
		
		/**
		 * @see classes.datastructures.Item
		 */
        public var item:Item;
        
        /**
        * Load data for an <code>Item</code>
        * 
        * @see classes.rpc.GetData
        * @see classes.datastructures.Item
        */
        public static const LOAD_DATA:String = "loadData";
        
        /**
        * Load data for an <code>Item</code> and items.
        * 
        * @see classes.rpc.GetData
        * @see classes.rpc.GetItems
        * @see classes.datastructures.Item
        */
        public static const LOAD_ALL:String = "loadAll";
        
        /**
        * Load data for an <code>Item</code> called from a component.
        * 
        * @see classes.rpc.GetData
        * @see classes.datastructures.Item
        */
        public static const LOAD_DATA_FOR_COMP:String = "loadDataForComp";
		
        // Public constructor.
        public function LoadDataEvent(type:String, item:Item) {
                // Call the constructor of the superclass.
                super(type,true,true);
                this.item = item;
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new LoadDataEvent(type, item);
        }
  
	}
}