package classes.skins
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	
	import mx.skins.Border;
	
	/**
	* The corner radius.
	*/
	[Style(name="cornerRadius", type="Number", type="uint")]
	
	/**
	* color of the border.
	*/
	[Style(name="borderColor", type="Number", format="Color")]
	
	/**
	* Colors in the <code>upSkin</code> state.
	*/
	[Style(name="fillColors", type="Array", arrayType="Number", format="Color")]
	
	/**
	* Colors in the <code>overSkin</code> state.
	*/
	[Style(name="fillColorsOver", type="Array", arrayType="Number", format="Color")]
	
	/**
	* The ratio of the colors in the gradient
	*/
	[Style(name="fillColorRatios", type="Array", arrayType="Number", format="Number")]
	
	
	/**
	 * Custom <code>ComboBox</code> skin.
	 * 
	 */
	public class ComboBoxSkin extends Border
	{

		// Constructor.
     	public function ComboBoxSkin():void {
        	
     	}
     	
		override protected function updateDisplayList(w:Number, h:Number):void {
		
		   // Depending on the skin's current name, set values for this skin.
	        var cornerRadius:Number = getStyle("cornerRadius")
	        var borderColor:Number = getStyle("borderColor");
	        
	        var fillColorsUp:Array = getStyle("fillColors");
	        var fillColorsOver:Array = getStyle("fillColorsOver");
	        var fillColorRatios:Array = getStyle("fillColorRatios");
	        
	        var fillColors:Array = fillColorsUp;
	        var fillAlphas:Array = [0.5,0.7];
	        
	        switch (name) {
	           case "upSkin":
	  				fillColors = fillColorsUp;
	           break;
	           case "overSkin":
	            	fillColors = fillColorsOver;
	           break;
	      
	           case "downSkin":
	           case "selectedUpSkin":
	           case "selectedDownSkin":
	           case "selectedOverSkin":
	           case "selectedDisabledSkin":
					fillColors = fillColorsOver;
					//StyleManager.getStyleDeclaration(".tabStyleComp").setStyle("textRollOverColor", borderColor);
	           break;
	            
	           case "disabledSkin":
					fillAlphas = [0.2,0.2];
	           break;
	        }
	        
			
			// Draw the box using the new values.
	        var g:Graphics = graphics;
	        g.clear();
	        g.beginGradientFill(GradientType.LINEAR,fillColors,fillAlphas,fillColorRatios,verticalGradientMatrix(1,1,w-2,h-2));
	        g.lineStyle(1, borderColor,1.0,true);
	        g.drawRoundRectComplex(0,0,w,h,cornerRadius,cornerRadius,cornerRadius,cornerRadius);
	        g.endFill();
	        
	        // the seperator
	        g.moveTo(w - 20, 2);
	        g.lineStyle(1, borderColor,1,true);
	        
	        g.lineTo(w - 20,h -2);
	        
	        // the triangle indicator
	        //g.beginFill(borderColor);
	        g.moveTo(w - 7, h/2 - 3);
	        g.beginFill(borderColor, 1.0);
	        g.lineStyle(1, borderColor,1,true);
	        
	        g.lineTo(w - 13,h/2 - 3);
	        g.lineTo(w - 10, h/2 + 3);
	        g.lineTo(w - 7, h/2 - 3);
	        g.endFill();
		}
	}        	
}