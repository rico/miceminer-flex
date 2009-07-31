package classes.renderer
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
	
	import mx.controls.DataGrid;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	
	/**
	 * A <code>DataGrid</code> cell renderer, which can be used to highlight updated data values. 
	 * 
	 * <p>In order to find the updated values, the <code>value</code> object needs to have a property named <code>updated</code>,
	 * which is an <code>Object</code> with the property names (<code>Strings</code>) of the
	 * <code>values</code> which have been updated.</p>
	 * 
	 * @example model object with update values in properties '<code>prop1, prop2, prop4</code>'
	 * <listing version="3.0">
	 * 	var	modelObject:Object = {
	 * 			prop1: 10,
	 * 			prop2: 8,
	 * 			prop3: 12,
	 * 			prop4: 19,
	 * 			prop5: 20,
	 * 			updated: { prop1:'prop1', prop2:'prop2', prop4:'prop4' }
	 * 		} 
	 * </listing>
	 * 
	 * 		<p>The updated values are renderd in bold text with color <code>0x01a601</code>, the text of the other values are renderd with a
	 * 		normal font weight and the color defined as the <code>color</code> style declaration for the <code>DataGrid</code>.</p>
	 *
	 */
    public class UpdatedValuesRenderer extends Label {
      
        override public function set data(value:Object):void {
            super.data = value;
       		
       		// highlight updated values
            if( value && value.hasOwnProperty("updated") ) {
				data = value[DataGridListData(listData).dataField];
				var label:String = DataGridListData(listData).dataField;
				
				if( value.updated.hasOwnProperty(label) ) {	
					setStyle("fontWeight", "bold");
					setStyle("color", 0x01a601);
					//trace("updated " + value.id + ": " +  label + " => " + data.toString() );
					
				}
				
			} else if(ownerGrid) { // reset styling
				var ownerGrid:DataGrid = DataGridListData(listData).owner as DataGrid;
				setStyle("fontWeight", "normal");
				setStyle("color", ownerGrid.getStyle("color") );
				
			}
            
            super.invalidateDisplayList();
        }
    }
}