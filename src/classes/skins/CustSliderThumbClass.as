package classes.skins
{
    import flash.filters.GlowFilter;
    
    import mx.controls.sliderClasses.SliderThumb;
    import flash.filters.BitmapFilterQuality;
    /**
    * Custom <code>SliderThumb</code> to set correct <code>width</code> and <code>height</code> properties.
    * 
    * @see components.sliders.RangeFilterSliderDate
    * @see components.sliders.RangeFilterSliderNumeric
    */ 
    public class CustSliderThumbClass extends SliderThumb {
    	
        public function CustSliderThumbClass() {
            super();
        }
        
        override protected function measure():void {
            super.measure();
            measuredHeight = minHeight;
            measuredWidth = minWidth;
        }
    }
}