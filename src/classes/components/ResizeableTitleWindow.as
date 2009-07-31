package classes.components
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
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.TitleWindow;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.core.mx_internal;	
	
	
	/**
	 * A <code>TitleWindow</code> with resize functionality.
	 * 
	 * <p>A resize handler is added to the bottom right corner of the <code>TitleWindow</code> which can be dragged around 
	 * to resize the window.</p>
	 * 
	 * <p>The code for the resize functionality is taken from the <a href='http://www.wietseveenstra.nl/blog/2007/04/flex-superpanel-v15/'>SuperPanel</a> 
	 * component written by <a href='http://www.wietseveenstra.nl/blog/about/'>Wietse Veenstra</a>.</p> 
	 */
	public class ResizeableTitleWindow extends TitleWindow
	{
		[Embed(source="/assets/img/ResizableTitleWindow/resizeCursor.png")]
		private static var resizeCursor:Class;
		
		[Embed(source="/assets/img/ResizableTitleWindow/resizeHandler.png")]
		private static var resizeHandler:Class;
		
		
		private var _oW:Number;
		private var _oH:Number;
		private var _oX:Number;
		private var _oY:Number;
		private var _oPoint:Point = new Point();
		private var _resizeHandler:Image = new Image();
		private var _resizeCur:Number = 0;
		
		public function ResizeableTitleWindow()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, setToolTip);
		}
		
		private function setToolTip(event:Event):void
		{
			this.mx_internal::closeButton.toolTip = "Click to close this window";
		}
		
		override protected function createChildren():void {
			super.createChildren();

			_resizeHandler.width     = 12;
			_resizeHandler.height    = 12;
			
			_resizeHandler.source = resizeHandler;
			rawChildren.addChild(_resizeHandler);
			initPos();
			
			
			this.positionChildren();	
			this.addListeners();
		}
		
		private function initPos():void {
			_oW = this.width;
			_oH = this.height;
			_oX = this.x;
			_oY = this.y;
		}
		
		private function positionChildren():void {
			invalidateSize();
			_resizeHandler.y = this.unscaledHeight - _resizeHandler.height - 1;
			_resizeHandler.x = this.unscaledWidth - _resizeHandler.width - 1;
			
		}
		
		private function addListeners():void {
		
			_resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
			_resizeHandler.addEventListener(MouseEvent.MOUSE_OUT, resizeOutHandler);
			_resizeHandler.addEventListener(MouseEvent.MOUSE_DOWN, resizeDownHandler);
			
		}
		
		private function resizeOverHandler(event:MouseEvent):void {
			this._resizeCur = CursorManager.setCursor(resizeCursor);
		}
		
		private function resizeOutHandler(event:MouseEvent):void {
			CursorManager.removeCursor(CursorManager.currentCursorID);
		}
		
		private function resizeDownHandler(event:MouseEvent):void {
			Application.application.parent.addEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			_resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
			//this.panelClickHandler(event);
			_resizeCur = CursorManager.setCursor(resizeCursor);
			_oPoint.x = mouseX;
			_oPoint.y = mouseY;
			_oPoint = this.localToGlobal(_oPoint);		
		}
		
		private function resizeMoveHandler(event:MouseEvent):void {
			this.stopDragging();
			
			var xPlus:Number = Application.application.parent.mouseX - _oPoint.x;			
			var yPlus:Number = Application.application.parent.mouseY - _oPoint.y;
						
			
			this.width = _oW + xPlus;
			this.height = _oH + yPlus;
			
			
			this.positionChildren();
		}
		
		private function resizeUpHandler(event:MouseEvent):void {
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			CursorManager.removeCursor(CursorManager.currentCursorID);
			_resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
			initPos();
		}
		
		/**
		 * Show or hide the resize handler.
		 */
		public function set showResizeHandler(show:Boolean):void
		{
			if(show) {
				_resizeHandler.visible = true;
				_resizeHandler.enabled = true;
			} else {
				_resizeHandler.visible = false;
				_resizeHandler.enabled = false;
			}
		}

	}
}