package classes.helpers
{
	//import mx.collections.ArrayCollection;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;

	
	/**
	 * Helper methods to handle data providers like <code>ArrayCollection</code>'s.
	 */
	public class DataHelpers
	{
		/**
		 * Get <emp>minimum</emp> and <emp>maximum</emp> of a given <emp>integer field</emp> in an <code>ArrayCollection</code>.
		 * 
		 * @param dbData The <code>ArrayCollection</code> to search.
		 * @param dbField The property name of the objects in the <code>ArrayCollection</code> the minimal and maximal value should be searched.
		 * 
		 * @return The returned <code>Array</code> has two elements. The <emp>first</emp> one is the <emp>minimum</emp>, the <emp>second</emp>
		 *  one is the <emp>maximum</emp>.
		 * 
		 */
		public static function getMinMaxInt(dbData:ArrayCollection, dbField:String):Array
		{
			
			var minMaxInt:Array = new Array();
			
			if(dbData != null &&dbData.length > 1) {
					
				dbData.source.sortOn(dbField, Array.NUMERIC);
				var minObj:Object = dbData.source[0];
				var maxObj:Object = dbData.source[dbData.source.length -1];
				
				var minVal:int = minObj[dbField];
				var maxVal:int = maxObj[dbField];
							
				minMaxInt = [minVal, maxVal];
			} else {
				
				minMaxInt = [0, 0];
				
			}
			
			return minMaxInt;

		}
		
		/**
		 * Get <emp>minimum</emp> and <emp>maximum</emp> of a given <emp>field</emp> in an <code>ArrayCollection</code>.
		 * 
		 * @param dbData The <code>ArrayCollection</code> to search.
		 * @param prop The property name of the objects in the <code>ArrayCollection</code> the minimal and maximal value should be searched.
		 * 
		 * @return The returned <code>Array</code> has two objects. The <emp>first</emp> one is the one with the <emp>lowest</emp> value, the <emp>second</emp>
		 *  one is the one with <emp>highest</emp> value.
		 * 
		 */
		public static function getMinMax(dbData:ArrayCollection, prop:String):Array
		{
			
			var minMax:Array = new Array();
			var timeRegex:RegExp = /\d{2}:\d{2}:\d{2}/;
			var datetimeRegex:RegExp = /\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}/;
		
			if(dbData != null && dbData.length > 1 && dbData.source[0].hasOwnProperty(prop)) {
				
				if ( dbData.source[0].prop is Number ) {
					dbData.source.sortOn(prop, Array.NUMERIC);	
				} else if( timeRegex.test(dbData.source[0].prop) ) {
					var timeCompare:Compare = new Compare( prop );
					dbData.source.sort(timeCompare.timeCompare);
				} else if( datetimeRegex.test(dbData.source[0].prop) ) {
					var datetimeCompare:Compare = new Compare( prop );
					dbData.source.sort(datetimeCompare.datetimeCompare);	
				} else {
					dbData.source.sortOn(prop, Array);
				}
					
				
				minMax = [ dbData.source[0], dbData.source[dbData.source.length -1] ];
			} else {
				minMax = [0, 0];
			}
			
			return minMax;

		}
		

		/**
		 * Groups the data in an <code>ArrayCollection</code> by the passed <emp>field</emp> and counts the elemnents in each of these groups.
		 * 
		 * @param dbData The <code>ArrayCollection</code>.
		 * @param field The property name of the objects in the <code>ArrayCollection</code> the group count should be calculated. 
		 * 
		 * @return The <code>ArrayCollection</code> source <code>Array</code> objects have the form <pre><code>[{field: <i>string</i>, count: <i>int</i>}]</code></pre>
		 */ 
		public static function distinctDataCount(field:String, data:ArrayCollection):ArrayCollection
		{
			var groupedArray:Array = new Array();
			
			for each(var item:Object in data) {
				
				var value:String = item[field] as String;
				
				groupedArray[value] == null ? groupedArray[value] = {field: value, count: 1} : groupedArray[value].count  += 1;
		
			}
			
			var groupedCountAC:ArrayCollection = new ArrayCollection(assArrayToArray(groupedArray));
			
			
			return groupedCountAC;
		}
		
		/**
		 * Convert an associative array to an <code>Array</code> with numeric indexes.
		 * 
		 * @param assArra an associative array with non object keys.
		 */
		public static function assArrayToArray(assArray:Array):Array
		{
			var numArray:Array = new Array();
			
			for each (var arrayItem:Object in assArray) {
				numArray.push(arrayItem)
			}
					
			return numArray;
		}
		
		/**
		 * Convert an associative array to an <code>ArrayCollection</code>.
		 * 
		 * @param assArray The associative array with non object keys to convert to an <code>ArrayCollection</code>.
		 */
		public static function assArrayToAC(assArray:Array):ArrayCollection
		{
			var arrCol:ArrayCollection = new ArrayCollection(assArray);
			if(arrCol.length == 0){
				arrCol = new ArrayCollection();
				
				for(var key:String in assArray) {
					var item:Object = new Object();
					item.key = key;
					item.value = assArray[key];
					arrCol.addItem(item);
				}
			}
			
			return arrCol;
		}
			 
	}
	
}

/////////////////////////////////////////////////////////////////////////////
// Private class to handle comparisons
/////////////////////////////////////////////////////////////////////////////

import mx.utils.ObjectUtil;
   
class Compare
{
	
	private var _prop:String;
	
	public function Compare(prop:String):void
	{
		_prop = prop;
	}
	
	/**
	 * Compare function for mysql time date strings (hh:mm:ss).
	 */
	public function timeCompare(itemA:Object, itemB:Object):int
	{
		var colonReplace:RegExp = /:/g;
		
		var itemAdate:String = itemA[_prop];
		var itemBdate:String = itemB[_prop];
	
		var timeA:int = parseInt(itemAdate.replace(colonReplace,''));
		var timeB:int = parseInt(itemBdate.replace(colonReplace,''));
		
		return ObjectUtil.compare(timeA, timeB);
	}
	
	/**
	 * Compare function for time data (hh:mm:ss).
	 */
	public function datetimeCompare(itemA:Object, itemB:Object):int
	{
		var dashReplace:RegExp = /-/g;
		
		var itemAdateString:String = itemA[_prop];
		var itemBdateString:String = itemB[_prop];
		
		var dateA:Date = new Date(Date.parse(itemAdateString.replace(dashReplace,'/')));
		var dateB:Date = new Date(Date.parse(itemBdateString.replace(dashReplace,'/')));
         
		return ObjectUtil.dateCompare(dateA, dateB);
	}
	
}