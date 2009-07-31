package classes.datastructures
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
	
	import mx.utils.ObjectProxy;

	/**
	 * This class acts as an intermediate for a data object which belongs to a <code>Grid</code> with
	 * the id <code>gridId</code>.
	 * 
	 * For example an instance is passed as a parameter of an <code>ObjectDataEvent</code> when we need to load 
	 * data for that object.
	 */
	public class Item extends ObjectProxy
	{
		
		private var _gridId:String;
		private var _toExcel:Boolean;
		private var _data:Object;
		
		/**
		 * 
		 * @param data The data object whih is usually the data object of the <code>dataProvider</code> of the <code>Gridy</code>.
		 * @param gridId The <code>id</code> of the <code>Grid</code> the data object belongs to.
		 * @param toExcel If set to true, the data loaded will not be shown in the GUI but directly exported to an <i>Excel</i> file.
		 */   
		public function Item( data:Object, gridId:String, toExcel:Boolean = false)
		{
			super();
			
			_data = data;
			_gridId = gridId;
			_toExcel = toExcel 
		}
		
		/**
		 * the id of the data object of this instance.
		 * Added for simplicity.
		 */ 
		public function get id():String
		{
			return _data.id;	
		}
		
		/**
		 * The grid id the data object belongs to
		 */
		public function get gridId():String
		{
			return _gridId;	
		}
		
		/**
		 * The data object
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 * If true data will directly exported to Excel
		 */
		public function get toExcel():Boolean
		{
			return _toExcel;
		}
		
	}
}