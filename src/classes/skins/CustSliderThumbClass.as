package classes.skins
{
	/*
		© Rico Leuthold [rleuthold@access.ch] // 2009
		
		This program is free software: you can redistribute it and/or modify
	    it under the terms of the GNU General Public License as published by
	    the Free Software Foundation, either version 3 of the License, or
	    (at your option) any later version.
	
	    This program is distributed in the hope that it will be useful,
	    but WITHOUT ANY WARRANTY; without even the implied warranty of
	    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	    GNU General Public License for more details.
	
	    You should have received a copy of the GNU General Public License
	    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	*/
	
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