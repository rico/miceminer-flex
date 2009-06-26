package classes.events
{
	import flash.events.Event;
	
	/**
	 * Used in the <code>DateSetter</code> component.
	 * 
	 * @see components.grids.gridControls.DateSetter
	 */
	public class DateValidEvent extends Event
	{
		
		
        private var _valid:Boolean;
        private var _dateRange:Array;
        
        /**
        * The constant defining the type of the event.
        */
        public static const DATE_CHANGED:String = "dateValid";
		
        /**
        * @param valid The date range is valid or not.
        * @param dateRange An <code>Array</code> containing the two dates defining the date range.
        */
        public function DateValidEvent(type:String, valid:Boolean, dateRange:Array) {
                // Call the constructor of the superclass.
                super(DATE_CHANGED,true,true);
                _valid = valid;
                _dateRange = dateRange;
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new DateValidEvent(type, valid, dateRange);
        }
        
        /**
        * Chosen date range is valid or not
        */
        public function get valid():Boolean
        {
        	return _valid;
        }
        
        /**
        * The date range
        */
        public function get dateRange():Array
        {
        	return _dateRange;
        }
  
	}
}