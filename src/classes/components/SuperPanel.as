/********************************************
 title   : SuperPanel
 version : 1.5
 author  : Wietse Veenstra
 website : http://www.wietseveenstra.nl
 date    : 2007-03-30
********************************************/
package classes.components {
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import mx.core.Application;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.effects.Resize;
	import mx.managers.CursorManager;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	/**
	 * A floating, draggable <code>Panel</code> component with minimize and maximize functionality.
	 * 
	 * <p>Written by <a href='http://www.wietseveenstra.nl'>Wietse Veenstra</a>, adapted to my needs.
	 *
	 */ 
	public class SuperPanel extends Panel {
		
		/**
		 * Show maximize/minimize controls.
		 * 
		 * @default false
		 */ 
		[Bindable]
		 public var showControls:Boolean = false;
		
		/**
		 * Enable resize of the component.
		 *
		 * @default false
		 */ 
		[Bindable]
		 public var enableResize:Boolean = false;
				
		[Embed(source="/assets/img/SuperPanel/resizeCursor.png")]
		private static var resizeCursor:Class;
		
		[Embed(source="/assets/img/down_arrow.png")]
		private static var downArrIcon:Class;
		
		[Embed(source="/assets/img/up_arrow.png")]
		private static var upArrIcon:Class;
		
		private var	pTitleBar:UIComponent;
		private var oW:Number;
		private var oH:Number;
		private var oX:Number;
		private var oY:Number;
		private var normalMaxButton:Button	= new Button();
		private var closeButton:Button		= new Button();
		private var resizeHandler:Button	= new Button();
		private var upMotion:Resize			= new Resize();
		private var downMotion:Resize		= new Resize();
		private var oPoint:Point 			= new Point();
		private var resizeCur:Number		= 0;
				
		public function SuperPanel() {}

		override protected function createChildren():void {
			super.createChildren();
			this.pTitleBar = super.titleBar;
			this.setStyle("headerColors", [0xAFAFAF, 0xAFAFAF]);
			this.setStyle("borderColor", 0x333333);
			this.setStyle("titleIcon", upArrIcon);
			this.titleBar.toolTip = "Double click to minimize and maximize the panel";
			this.initPos();
			this.doubleClickEnabled = true;
			
			this.resizeHandler.setStyle("icon", upArrIcon);
			this.resizeHandler.toolTip = "Click to minimize the panel";
			this.rawChildren.addChild(resizeHandler);
			
			this.positionChildren();	
			this.addListeners();
		}
		
		private function initPos():void {
			this.oW = this.width;
			this.oH = this.height;
			this.oX = this.x;
			this.oY = this.y;
		}
	
		private function positionChildren():void {
			
			this.resizeHandler.y = 13;
			this.resizeHandler.x = this.unscaledWidth - 13;
			
		}
		
		private function addListeners():void {
			this.addEventListener(MouseEvent.CLICK, panelClickHandler);
			this.pTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler);
			this.pTitleBar.addEventListener(MouseEvent.DOUBLE_CLICK, titleBarDoubleClickHandler);
			
			if (showControls) {
				this.closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler);
				this.normalMaxButton.addEventListener(MouseEvent.CLICK, normalMaxClickHandler);
			}
			
			
			this.resizeHandler.addEventListener(MouseEvent.CLICK, titleBarDoubleClickHandler);
			
		}
		
		private function panelClickHandler(event:MouseEvent):void {
			this.pTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			this.parent.setChildIndex(this, this.parent.numChildren - 1);
			this.panelFocusCheckHandler();
		}
		
		private function titleBarDownHandler(event:MouseEvent):void {
			this.pTitleBar.addEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
		}
			
		private function titleBarMoveHandler(event:MouseEvent):void {
			if (this.width < screen.width) {
				Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, titleBarDragDropHandler);
				this.pTitleBar.addEventListener(DragEvent.DRAG_DROP,titleBarDragDropHandler);
				this.parent.setChildIndex(this, this.parent.numChildren - 1);
				this.panelFocusCheckHandler();
				this.alpha = 0.5;
				this.startDrag(false, new Rectangle(0, 0, screen.width - this.width, screen.height - this.height));
			}
		}
		
		private function titleBarDragDropHandler(event:MouseEvent):void {
			this.pTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			this.alpha = 1.0;
			this.stopDrag();
		}
		
		private function panelFocusCheckHandler():void {
			for (var i:int = 0; i < this.parent.numChildren; i++) {
				var child:UIComponent = UIComponent(this.parent.getChildAt(i));
				
				child.setStyle("headerColors", [0xAFAFAF, 0xAFAFAF]);
				child.setStyle("borderColor", 0x333333);
				/* if (this.parent.getChildIndex(child) < this.parent.numChildren - 1) {
					child.setStyle("headerColors", [0xAFAFAF, 0xAFAFAF]);
					child.setStyle("borderColor", 0x333333);
				} else if (this.parent.getChildIndex(child) == this.parent.numChildren - 1) {
					child.setStyle("headerColors", [0x333333, 0x333333]);
					child.setStyle("borderColor", 0x333333);
				} */
			}
		}
		
		private function titleBarDoubleClickHandler(event:MouseEvent):void {
			this.pTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			
			this.upMotion.target = this;
			this.upMotion.duration = 300;
			this.upMotion.heightFrom = oH;
			this.upMotion.heightTo = 28;
			this.upMotion.end();
			
			this.downMotion.target = this;
			this.downMotion.duration = 300;
			this.downMotion.heightFrom = 28;
			this.downMotion.heightTo = oH;
			this.downMotion.end();
			
			if (this.width < screen.width) {
				if (this.height == oH) {
					this.upMotion.play();
					this.resizeHandler.setStyle("icon", downArrIcon);
					this.resizeHandler.toolTip = "Click to maximize the panel";
					
				} else {
					this.downMotion.play();
					this.downMotion.addEventListener(EffectEvent.EFFECT_END, endEffectEventHandler);
					this.resizeHandler.setStyle("icon", upArrIcon);
					this.resizeHandler.toolTip = "Click to minimize the panel";
				}
			}
		}
						
		private function endEffectEventHandler(event:EffectEvent):void {
			this.resizeHandler.visible = true;
		}

		private function normalMaxClickHandler(event:MouseEvent):void {
			if (this.normalMaxButton.styleName == "increaseBtn") {
				if (this.height > 28) {
					this.initPos();
					this.x = 0;
					this.y = 0;
					this.width = screen.width;
					this.height = screen.height;
					this.normalMaxButton.styleName = "decreaseBtn";
					this.positionChildren();
				}
			} else {
				this.x = this.oX;
				this.y = this.oY;
				this.width = this.oW;
				this.height = this.oH;
				this.normalMaxButton.styleName = "increaseBtn";
				this.positionChildren();
			}
		}
		
		private function closeClickHandler(event:MouseEvent):void {
			this.removeEventListener(MouseEvent.CLICK, panelClickHandler);
			this.parent.removeChild(this);
		}
		
		private function resizeOverHandler(event:MouseEvent):void {
			this.resizeCur = CursorManager.setCursor(resizeCursor);
		}
		
		private function resizeOutHandler(event:MouseEvent):void {
			CursorManager.removeCursor(CursorManager.currentCursorID);
		}
		
		private function resizeDownHandler(event:MouseEvent):void {
			Application.application.parent.addEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
			this.panelClickHandler(event);
			this.resizeCur = CursorManager.setCursor(resizeCursor);
			this.oPoint.x = mouseX;
			this.oPoint.y = mouseY;
			this.oPoint = this.localToGlobal(oPoint);		
		}
		
		private function resizeMoveHandler(event:MouseEvent):void {
			this.stopDragging();

			var xPlus:Number = Application.application.parent.mouseX - this.oPoint.x;			
			var yPlus:Number = Application.application.parent.mouseY - this.oPoint.y;
			
			if (this.oW + xPlus > 140) {
				this.width = this.oW + xPlus;
			}
			
			if (this.oH + yPlus > 80) {
				this.height = this.oH + yPlus;
			}
			this.positionChildren();
		}
		
		private function resizeUpHandler(event:MouseEvent):void {
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			CursorManager.removeCursor(CursorManager.currentCursorID);
			this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
			this.initPos();
		}
	}
	
}