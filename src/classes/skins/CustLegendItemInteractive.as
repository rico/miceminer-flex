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
	
	import flash.events.MouseEvent;
	import mx.charts.LegendItem;
	
	     	
	/**
	* The arrow color.
	*/
	[Style(name="arrowColor", type="Number", type="Color")] 

	/**
	* The arrow size
	*/
	[Style(name="arrowSize", type="Number", type="uint")]
	
	/**
	* The corner radius.
	*/
	[Style(name="cornerRadius", type="Number", type="uint")] 

	/**
	* Roll over text color.
	*/
	[Style(name="text-roll-over-color", type="Number", type="Color")] 

	/**
	* The arrow color.
	*/
	[Style(name="arrowColor", type="Number", type="Color")] 

	 
	
	/**
	 * Custom <code>LegendItem</code> skin with a highlight and mouse over skin change. 
	 */ 
	public class CustLegendItemInteractive extends LegendItem
	{
	 
	    private var _highlight:Boolean;
	    private var _alphaVal:Number;
    	private var _selected:Boolean;
    	private var _desc:Boolean;
    	private var _dataField:String;    
	    
	     public function CustLegendItemInteractive(dataField:String)
	     {
	         super();
	         _dataField = dataField;
	         this.styleName = "searchChartLegendItem";
	         
	         addEventListener(MouseEvent.MOUSE_OVER, handleEvent);
	         addEventListener(MouseEvent.MOUSE_OUT, handleEvent);
			
	     }
	     
	     override protected function createChildren():void {
			super.createChildren();
			
		}
		
		/**
		 * The data field in the data provider this legend item represents.  
		 */
		public function get dataField():String
		{
			return _dataField;
		}
		
		private function handleEvent(event:MouseEvent):void
		{
			
			switch(event.type){
				case("mouseOver"):
					highlight = true;
					_selected ? this.toolTip ="Click to change sort direction" : this.toolTip ="Click to sort chart by " + event.currentTarget.label;
				break;
				case("mouseOut"):
				
					if(_selected) {
						highlight = true;
					} else {
						highlight = false;
						this.setStyle("color", 0xFFFFFF);
					}
					 
				break;
				
			}
			
		}
		
		/**
		 * When set to true, apply <i>highlight</i> skin to the item, else the <i>normal</i> skin is applied.
		 */
		public function set highlight(value:Boolean):void{
			_highlight = value;
			invalidateDisplayList();
		}
		
		/**
		 * When set to true, apply <i>select</i> skin to the item, else the <i>normal</i> skin is applied.
		 */
		public function set selected(value:Boolean):void{
			_selected = value;
			_highlight = value;
			invalidateDisplayList();
		}
		
		/**
		 * The label.
		 */
		public function set desc(value:Boolean):void
		{
			
			_desc = value;
			_selected = true;
			_highlight = true;

			invalidateDisplayList();
		}
		
	     protected override function updateDisplayList(w:Number,h:Number):void
	     {
	     	
	     	var arrowColor:Number = getStyle("arrowColor");
	     	var arrowSize:int = getStyle("arrowSize");
	     	var cornerRadius:int = getStyle("cornerRadius");
	     	var bgColor:Number = getStyle("backgroundColor");
	     	var color:Number = getStyle("color");
	     	var rollOverColor:Number = getStyle("text-roll-over-color");
	     	
	        super.updateDisplayList(w, h);
			graphics.clear();
			
			if(_highlight && _selected) {
				
				this.setStyle("color", rollOverColor);
				
				graphics.beginFill(bgColor,1);
				graphics.drawRoundRect(0,0,w,h,cornerRadius);
				graphics.endFill();
				
				graphics.beginFill(arrowColor,1);
				graphics.lineStyle(1,arrowColor,1);
				
				var fromRight:Number = 4;
				var sideLength:Number = arrowSize;
				
				this.setStyle("color", rollOverColor);
				
				if(_desc) {
					graphics.moveTo(w - fromRight - sideLength/2,h/2 + sideLength/2);
					graphics.lineTo(w - fromRight -sideLength, h/2 - sideLength/2);
					graphics.lineTo(w - fromRight,h/2 - sideLength/2);
					graphics.lineTo(w - fromRight -sideLength/2,h/2 + sideLength/2);					
					
				} else {

					graphics.moveTo(w - fromRight, h/2 + sideLength/2);
					graphics.lineTo(w - fromRight - sideLength,h/2 + sideLength/2);
					graphics.lineTo(w - fromRight - sideLength/2,h/2 - sideLength/2);
					graphics.lineTo(w - fromRight, h/2 + sideLength/2);
				}
				
				graphics.endFill();    
				     
			} else if (_highlight){
				
				this.setStyle("color", rollOverColor);
				
				graphics.beginFill(color,1);
				graphics.drawRoundRect(0,0,w,h,cornerRadius);
				graphics.endFill();
					         
			} else if(!_highlight && !_selected) {
				
				this.setStyle("color", 0xFFFFFF);

			}	
	         
	     }
	}
}