package classes.components
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.events.FlexEvent;

	/**
	 * An enhanced TextInput control with button to clear the text value.
	 * 
	 * @class ClearTextInput
	 * @author Jove / Rico Leuthold
	 */
	public class ClearTextInput extends TextInput{
				

		private var clearButton:Button;
		
		/**
		 * @constructor
		 */ 
		public function ClearTextInput(){
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, addButton);
			this.addEventListener(FocusEvent.FOCUS_IN, this_focusInHandler);
			this.addEventListener(FocusEvent.FOCUS_OUT, this_focusOutHandler);
			

		}
		
		private function addButton(event:FlexEvent):void
		{
			
			
			if(clearButton == null){
				
				clearButton = new Button();
				clearButton.width=10;
				clearButton.height=10;
				clearButton.y = (this.height - 10) / 2;
				clearButton.x = this.width - 10 - (this.height - 10) / 2;
				clearButton.focusEnabled=false;
				clearButton.styleName = this.getStyle("clearButStyle");
				clearButton.addEventListener(MouseEvent.CLICK, clearButton_clickHandler);
				clearButton.visible = false;
				clearButton.buttonMode = true;
				clearButton.useHandCursor = true;
				clearButton.mouseChildren = false;
				clearButton.toolTip = "click to reset filter";
				this.addChild(clearButton);
				this.addEventListener("textChanged", showClearButton);
				showClearButton(null);
			}
			
		}
		
		private function clearButton_clickHandler(event:MouseEvent):void{
			this.text = "";
			
			clearButton.visible = false;
			
			// needed to get the change event fired which normally only happens on user input
			// but here we have AS and need to do it manually
			dispatchEvent(new Event("change"));

		}
		
		private function this_focusInHandler(event:FocusEvent):void{
			if(text == ""){
				this.text = "";
				this.textField.text = "";
				this.textField.textColor = this.getStyle("color");
				clearButton.visible = false;
			} else {
			
			}
		}
		
		private function this_focusOutHandler(event:FocusEvent):void{
			if(text == ""){
				this.text = "";
			}
		}
		
		/**
		 * Sets the text property to a empty String
		 */
		public function reset():void{
		
			clearButton.visible = false;
			this.text = "";
		}
		
		
				
		private function showClearButton(event:Event):void{
			if(clearButton){
				if(text != ""){
					clearButton.visible = true;
				}else{
					clearButton.visible = false;
				}
				this.textField.textColor = this.getStyle("color");
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			/*if(searchIndicator != null){
				searchIndicator.x = 2;
				searchIndicator.y = (this.height - 18) / 2;
			}*/
			
			
			if(clearButton != null){
				clearButton.x = this.width - 10 - (this.height - 10) / 2;
				clearButton.y = (this.height - 10) / 2;
			}
			
		}
	}

}