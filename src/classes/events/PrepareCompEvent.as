package classes.events
{
	import flash.events.Event;
	
	/**
	 * @private
	*/
	public class PrepareCompEvent extends Event
	{
		
		// Define a public variable to hold the state of the enable property.
        public var loadWinLabel:String;
        
        // Define static constant.
        public static const PREPARING_COMP:String = "preparingComp";
        public static const COMP_READY:String = "compReady";
        
		
        // Public constructor.
        public function PrepareCompEvent(type:String, loadWinLabel:String) {
                // Call the constructor of the superclass.
                super(type,true,true);
                this.loadWinLabel = loadWinLabel;
        }

        // Override the inherited clone() method.
        override public function clone():Event
        {
            return new PrepareCompEvent(type,loadWinLabel);
        }
	}
}