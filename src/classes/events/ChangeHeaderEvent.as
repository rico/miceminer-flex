package classes.events
{
	import flash.events.Event;
	import classes.components.Grid;
	
	/**
	 * Custom event with a <code>Grid</code> component as parameter.
	 * 
	 * @see components.grids.Grid
	 */
	public class ChangeHeaderEvent extends Event
	{
		
		// Define a public variable to hold the state of the enable property.
        public var grid:Grid;
        
        /**
        * Event type
        */
        public static const CHANGE_HEADER:String = "changeHeader";
		
        /**
        * @param type One of the constants defined for this event.
        * @param grid The <code>Grid</code> component.
        */
        public function ChangeHeaderEvent(grid:Grid) {
                // Call the constructor of the superclass.
                super(CHANGE_HEADER,true,true);
                this.grid = grid;
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new ChangeHeaderEvent(grid);
        }
}
}