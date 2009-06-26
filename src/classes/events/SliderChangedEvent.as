package classes.events
{
	import flash.events.Event;
	
	/**
	 * Custom events used by the slider controls to communicate with the <code>DataFilterBox</code> component.
	 * 
	 * @see components.sliders.RangeFilterSliderNumeric
	 * @see components.sliders.RangeFilterSliderDate
	 * @see classes.components.DataFilterBox
	 */
	public class SliderChangedEvent extends Event
	{
		
		/**
		 * The two slider values.
		 */
        public var sliderRange:Array;
        
        /**
        * Dispatched by a </code>RangeFilterSliderNumeric</code> component.
        * 
        * @see components.sliders.RangeFilterSliderNumeric
        */
        public static const SLIDER_CHANGED_NUMERIC:String = "sliderChangedNumeric";
        
        /**
        * Dispatched by a </code>RangeFilterSliderDate</code> component.
        * 
        * @see components.sliders.RangeFilterSliderDate
        */
        public static const SLIDER_CHANGED_DATE:String = "sliderChangedDate";
        
        //public static const SLIDER_RESET:String = "sliderReset";
		
        /**
        * @param type One of the constants defined for this event.
        * @param sliderRange The two slider values.
        */
        public function SliderChangedEvent(type:String, sliderRange:Array) {
                // Call the constructor of the superclass.
                super(type,true,true);
                this.sliderRange = sliderRange;
        }

        /**
        * @private
        */
        override public function clone():Event
        {
            return new SliderChangedEvent(type,sliderRange);
        }
	}
}