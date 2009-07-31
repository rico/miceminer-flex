package classes.renderer {
	
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
	
	// Flash classes
	import classes.events.LoadEdgeDataEvent;
	import classes.helpers.DateHelpers;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.LinkButton;
	import mx.events.FlexEvent;
	
	import org.un.cava.birdeye.ravis.components.renderers.BaseRenderer;
	import org.un.cava.birdeye.ravis.utils.events.VGraphRendererEvent;
	
	/**
	 * Dispatched when the edge label is double clicked.
	 * 
	 * @eventType corg.un.cava.birdeye.ravis.utils.events.VGraphRendererEvent.VG_RENDERER_SELECTED
	 */
	[Event(name="vgRendererSelected", type="org.un.cava.birdeye.ravis.utils.events.VGraphRendererEvent")]
	
	/**
	 * Adds some formatting and highlighting functionalities to the edge label rendering of the 
	 * <b><a href="http://code.google.com/p/birdeye/wiki/RaVis">RaVis</a></b> base renderer.
	 */
	public class CustomEdgeLabelRenderer extends BaseRenderer {
		
		private var _offLineColor:uint;
		private var _edgeLabel:LinkButton;
		
		/**
		 * Base Constructor
		 * */
		public function CustomEdgeLabelRenderer() {
			super();
			
		}
			
		/**
		 * @inheritDoc
		 * */
		override protected function getDetails(e:Event):void {

			// trace("Show Details");
			var vgre:VGraphRendererEvent = new VGraphRendererEvent(VGraphRendererEvent.VG_RENDERER_SELECTED);
			
			/* do the checks in the super class */
			super.getDetails(e);
			
			/* prepare the event */
			
			/* make sure we have the XML attribute */
			if(this.data.data.@sec != null) {
				vgre.rname = this.data.data.@sec;
			} else {
				trace("XML data object has no 'sec' attribute");
			}
			
			this.dispatchEvent(vgre);
		}
		
		/**
		 * @inheritDoc
		 * 
		 * Make sure we call the init methods of THIS
		 * class and not the base class.
		 * */
		override protected function initComponent(e:Event):void {
			
			/* now the link button */
			initLinkButton();
			
		}
		
		
		/**
		 * @inheritDoc
		 * */
		override protected function initLinkButton():LinkButton {
			
			_edgeLabel = new LinkButton();
			_edgeLabel.doubleClickEnabled = true;
			
			_edgeLabel.label = DateHelpers.secToTime(this.data.data.@sec, 'short');
			_edgeLabel.setStyle("fontFamily", 'MyriadPro');
			_edgeLabel.setStyle("fontSize", 10);
			_edgeLabel.setStyle("color", 0x333333);
			_edgeLabel.setStyle("fontWeight","normal");
			_edgeLabel.setStyle("textRollOverColor", 0xffffff);
			_edgeLabel.setStyle("selectionColor", 0xff0d00);
			_edgeLabel.setStyle("rollOverColor",0xff0d00);
			
			
			_edgeLabel.addEventListener(FlexEvent.CREATION_COMPLETE, adjustPosition);
			_edgeLabel.addEventListener(MouseEvent.MOUSE_OVER, highlightEdge);
			_edgeLabel.addEventListener(MouseEvent.MOUSE_OUT, normalEdge);
			_edgeLabel.addEventListener(MouseEvent.DOUBLE_CLICK, loadDataforEdge)
			
			this.addChild(_edgeLabel);
			
			
			return _edgeLabel;
			
		}
		
		/**
		 * Dispatch a custom event to load and show the data for this edge
		 */
		private function loadDataforEdge(event:MouseEvent):void
		{
			
			_edgeLabel.removeEventListener(MouseEvent.MOUSE_OUT, normalEdge);
			_edgeLabel.removeEventListener(MouseEvent.MOUSE_OVER, highlightEdge);
			dispatchEvent(new LoadEdgeDataEvent(this));
			
		}
		
		/**
		 * Restore normal mouse over out highlight funtionality.
		 */
		public function edgeDataClosed():void
		{
			_edgeLabel.addEventListener(MouseEvent.MOUSE_OVER, highlightEdge);
			_edgeLabel.addEventListener(MouseEvent.MOUSE_OUT, normalEdge);
			_edgeLabel.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
		}
		
		/**
		 * Adjust postition after the component is ready
		 */
		private function adjustPosition(event:FlexEvent):void
		{
			
			this.x -= this.width / 2.0;
			this.y -= this.height / 2.0;
		}
		
		/**
		 * Highlight vedge (of this edge label) and the nodes it connects.
		 * 
		 * <p>This happens automatically on mouse over of the edge label.</p>
		 */
		private function highlightEdge(event:Event):void
		{
			_offLineColor = this.data.edge.vedge.lineStyle.color;
			this.data.edge.vedge.lineStyle.color = 0xff0d00;
			this.data.vgraph.edgeRenderer.draw(data.edge.vedge);
			
			this.data.edge.node1.vnode.view.highlight = true;
			this.data.edge.node2.vnode.view.highlight = true;
		}
		
		/**
		 * Restore normal style of vedge (of this edge label) and the nodes it connects.
		 * 
		 * <p>This happens automatically on mouse out of the edge label.</p>
		 */
		private function normalEdge(event:Event):void
		{
			this.data.edge.vedge.lineStyle.color = _offLineColor;
			this.data.vgraph.edgeRenderer.draw(data.edge.vedge);
			this.data.edge.node1.vnode.view.highlight = false;
			this.data.edge.node2.vnode.view.highlight = false;
		}
		
		/**
		 * The edge label button.
		 * 
		 * <p>Double click enable by default.</p>
		 */
		public function get linkButton():LinkButton
		{
			return _edgeLabel;
		}
		
		
	}
}

