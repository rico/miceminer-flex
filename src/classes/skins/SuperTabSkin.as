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
	
  	import flash.display.Graphics;
  	import mx.skins.ProgrammaticSkin;
  	
  	/**
	* The corner radius.
	*/
	[Style(name="cornerRadius", type="Number", type="uint")]
	
	/**
	* Color of the border.
	* 
	* @default 0xFFFFFF
	*/
	[Style(name="borderColor", type="Number", format="Color")]
	
	/**
	* Fill color.
	* 
	* @default 0xAFAFAF
	*/
	[Style(name="fillColor", type="Number", format="Color")]
	
	/**
	* Alpha channel value for the fill.
	*/
	[Style(name="fillAlpha", type="Number", format="Number")]
	
	/**
	* Border color when the tab is selected.
	*/
	[Style(name="selBorderColor", type="Number", format="Number")]
	
	/**
	* Text color when the tab is selected.
	*/
	[Style(name="selTextColor", type="Number", format="Number")]
  	
  	/**	
  	 * Skin for the tabs of the <code>flexlib.SuperTabNavigator</code>.
  	 */
	public class SuperTabSkin extends ProgrammaticSkin
	{
	
		private var backgroundFillColor:Number;
     	private var borderColor:Number;
     	
		// Constructor.
     	public function SuperTabSkin():void {
     		
     		backgroundFillColor = 0xAFAFAF;
        	borderColor = 0xFFFFFF;
        	super();
        	
     	}

	    override protected function updateDisplayList(w:Number, h:Number):void {
	    	
	        // Depending on the skin's current name, set values for this skin.
	        var cornerRadius:Number = getStyle("cornerRadius")
	        var fillColor:Number = getStyle("fillColor");
	        var fillAlpha:Number = getStyle("fillAlpha");
	        var borderColor:Number = getStyle("borderColor");
	        var selBorderColor:Number = getStyle("selectedColor");
	        var selTextColor:Number = getStyle("selectedTextColor");
	        
	        var borderAlpha:Number = 1;
	        
	        switch (name) {
				case"selectedUpSkin":
				case "selectedOverSkin":
	            	borderColor = borderColor;
	           		backgroundFillColor = fillColor;
	           	break;
	           	case "upSkin":
	           		borderColor = borderColor;
	           		backgroundFillColor = fillColor;
	           		fillAlpha = 0.5;
	           	break;
	           	case "overSkin":
	            	backgroundFillColor = selBorderColor;
	            	fillAlpha = 1;
	           	break;
	           	case "downSkin":
					borderColor = borderColor;
					backgroundFillColor = fillColor;
	           	break;
	           	case "disabledSkin":
					borderColor = borderColor;
	           		backgroundFillColor = fillColor;
	           		fillAlpha -= 0.5; 
	           	break;
	        }
	
	        // Draw the box using the new values.
	        var g:Graphics = graphics;
	        g.clear();
	        g.lineStyle(1, borderColor,borderAlpha,true);
	        g.beginFill(backgroundFillColor,fillAlpha);
	        g.drawRoundRectComplex(0,0,w,h-2,cornerRadius,cornerRadius,0,0);
	        g.endFill();
	        
	     }
	}
}