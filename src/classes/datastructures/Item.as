package classes.datastructures
{
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