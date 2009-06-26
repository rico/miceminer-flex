package classes.helpers
{
	import classes.GlobalVars;
	
	import mx.collections.ArrayCollection;
	import mx.formatters.DateFormatter;
	
	
	/**
	 * Helper methods to handle dates.
	 */
	public class DateHelpers
	{
		/**
		 * The date format used
		 */
		public static const DATETIME_FORMAT:String = "YYYY-MM-DD";
		
		/**
		 * Static setter function for the global <emp>database</emp> date Range based on the passed <code>Array</code> with two <code>date</code> objects.
		 * The range is assigned to the <code>GlobalVars dataRange['dbrange']</code>.
		 * 
		 * @param dbRange An array with two date strings.
		 * 
		 * @see classes.GlobalVars
		 */ 
		public static function setDbRange(dbRange:Array):void
		{
				var Globals:GlobalVars = GlobalVars.getInstance();
				var dbRangeDates:Array = new Array();
				
				if(dbRange[0] < dbRange[1]) {
					dbRangeDates = [new Date(dbRange[0]), new Date(dbRange[1])];	
				} else {
					dbRangeDates = [new Date(dbRange[1]), new Date(dbRange[0])];
				}
					
				// set the db range
				Globals.dateRange['dbrange'] = dbRangeDates;				
		
		}
		
		/** 
		 * Static getter function for the global <emp>database</emp> date Range.
		 * 
		 * @return Array of two <code>Date</code> objects, the first one is the start date, the second one is the end date.
		 */
		public static function getDbRange():Array
		{
				var Globals:GlobalVars = GlobalVars.getInstance();
				var dbRange:Array = new Array;				
				
				// sort the array with the db range values (numeric)
				var dbRanges:Array = Globals.dateRange['dbrange'];
				
				// get db range values as AS timestamp
				var startUTS:Number = dbRanges[0];
				var endUTS:Number = dbRanges[1];
				
				dbRange.push(new Date(startUTS))
				dbRange.push(new Date(endUTS));
				
				
				return dbRange;
				
		}
		
		/**
		 * Static setter function for the global <emp>current</emp> date Range based on the passed <code>Array</code> with two <code>date</code> objects.
		 * 
		 * <p>The range is assigned to the <code>GlobalVars dataRange['daterange']</code>.</p>
		 * 
		 * @see classes.GlobalVars
		 */  
		public static function setDateRange(dateRange:Array):void
		{
				var Globals:GlobalVars = GlobalVars.getInstance();
				var rangeDates:Array = new Array();
				
				if(dateRange[0] < dateRange[1]) {
					rangeDates = [new Date(dateRange[0]), new Date(dateRange[1])];	
				} else {
					rangeDates = [new Date(dateRange[1]), new Date(dateRange[0])];
				}						
				
				// set the db range
				Globals.dateRange['daterange'] = rangeDates;
				
		}
		
		/** 
		 * Static getter function for the global <emp>current</emp> date Range.
		 * 
		 * @return Array of two <code>Date</code> objects, the first one is the start date, the second one is the end date.
		 */
		public static function getDateRange():Array
		{
				var Globals:GlobalVars = GlobalVars.getInstance();				
				
				// sort the array with the db range values (numeric)
				var dateRange:Array = Globals.dateRange['daterange'];
				
				return dateRange;
				
		}
		
		/**
		 * Formats an array containing two <code>Date</code> objects as <code>String</code>'s.
		 * 
		 * <p>The format is set in the <code>DATETIME_FORMAT</code> property of this class.</p>
		 */
		public static function formatDateRange(dateRange:Array):Array
		{
			var dateRangeF:Array = new Array();
			
			var formatDate:DateFormatter = new DateFormatter();
			formatDate.formatString = DATETIME_FORMAT;
		
			dateRangeF.push(formatDate.format(dateRange[0]));
			dateRangeF.push(formatDate.format(dateRange[1]));
			
			return dateRangeF;
		}
				
		/**
		 * Takes the <code>dateRange Array</code>, consisting of two <code>Date</code> objects - the first one ist the start date,
		 * the second on the end date - and format them as a <i>MySQL</i> date strings.
		 * 
		 * @return formatted date range
		 */  
		public static function formatDate(dateRange:Array):Array
		{
			var dateRangeF:Array = new Array();
			
			var formatDate:DateFormatter = new DateFormatter();
			formatDate.formatString = DATETIME_FORMAT;
		
			dateRangeF.push(formatDate.format(dateRange[0]));
			dateRangeF.push(formatDate.format(dateRange[1]));

			return dateRangeF;
			
		}
		
		/**
		 * Get <emp>minimum</emp> and <emp>maximum</emp> values of a given <emp>date field</emp> which is a property name of the objects in an <code>ArrayCollection</code>.
		 * 
		 * @return The returned <code>Array</code> has two elements. The <emp>first</emp> one is the <emp>minimum</emp>, the <emp>second</emp>
		 *  one is the <emp>maximum</emp>.
		 */
		public static function getMinMaxDate(dbData:ArrayCollection, dbField:String, objects:Boolean = false):Array
		{
			
			var minMaxDate:Array = new Array();
			
			if(dbData.length > 1 && dbData != null) {

				dbData.source.sortOn(dbField);

				var arrLengthIndex:int = (dbData.source.length) -1;
				var lastIndexWithValue:int;
				
				while(!lastIndexWithValue && arrLengthIndex > 0) {
					var indexObj:Object = dbData.source[arrLengthIndex]; 
					if(indexObj[dbField] != null) {
						lastIndexWithValue = arrLengthIndex;
					} else {
						arrLengthIndex--;
					}
				} 
				
				var minObj:Object = dbData.source[0];
				minObj.index = 0; 
				var maxObj:Object = dbData.source[lastIndexWithValue];
				maxObj.index = lastIndexWithValue;
				
				
				if(objects) {
					minMaxDate = [ minObj, maxObj]; 

				} else {
					minMaxDate = [minObj[dbField], maxObj[dbField] ];
				}
				
			} else {
				
				if(objects) {
					minMaxDate = [new Object(), new Object()];
				} else {
					minMaxDate = [0, 0];	
				}
				
			}
			
			return minMaxDate;
						
		}
		
		/**
		 *  Split a formatted date string to show it in the form text inputs.
		 * 
		 */ 
		public static function splitDate(str:String):Array
		{
			var splitted:Array = str.split('-');
			return splitted;
		}
		
		/**
		 * Join a splitted date string.
		 * 
		 * @return Date string in format <code>mm/dd/yyyy</code>
		 */
		public static function joinDate(arr:Array):String
		{
			var delimiter:String = '/';
			var joined:String = arr.join(delimiter);
			//dateValidate.inputFormat = "mm"+delimiter+"dd"+delimiter+"yyyy";
			return joined;
		}
		
		/**
		 * Converts a mysql date (yyyy-mm-dd) to an ActionScript date object.
		 * 
		 */ 
		public static function mysqlDateToASDate(mysqlDate:String):Date
		{
			var splittedMysqlDate:Array = splitDate(mysqlDate);
		
			var convertedDate:Date = new Date();
			convertedDate.fullYear = splittedMysqlDate[0]
			convertedDate.month = splittedMysqlDate[1] -1;
			convertedDate.date = splittedMysqlDate[2];
			
			return convertedDate;
		} 
		
		
		/**
		 * Returns an <code>Array</code> with the date of the last sunday and the date of the next saturday, for the passed date.
		 * 
		 * <p>Taken from: <a href="http://blog.vixiom.com/2007/05/14/flex-datechooser-select-a-week/">http://blog.vixiom.com/2007/05/14/flex-datechooser-select-a-week/</a>.</p>
		 */
		public static function weekDateRange(date:Date):Array
        {
             var dayUTC:Number = 86400000; // day in second
             
             // check if sunday (day 0, first day of civil week)
             var date_sun:Date = date;
             if (date.day != 0) 
             {
                 date_sun = new Date(date.valueOf() - date.day * dayUTC);
             }
             
             var date_sat:Date = new Date(date_sun.valueOf() + 6 * dayUTC);
             
             var range:Array = [date_sun, date_sat];
             
             return range;

        }
        /**
         * Calculate week of the year number for a given date.
         *
         * <p>Taken from: <a href="http://board.flashkit.com/board/showthread.php?t=755170">http://board.flashkit.com/board/showthread.php?t=755170</a></p>
         *  
         * <p><i>Procedure by Rick McCarty, 1999<br/>
		 * Adapted to CVI by R.Bozzolo, 2006<br/>
		 * Adapted to AS2 by A.Colonna, 2008<br/>
		 * Adapted to AS3 by me</i></p>
         */
		public static function weekNumber(date:Date):Number
		{
			// 1) Convert date to Y M D
			var Y:Number = date.fullYear;
			var M:Number = date.month;
			var D:Number = date.date;
			
			// 2) Find out if Y is a leap year
			var isLeapYear:Boolean ;
			if( (Y % 4 == 0  &&  Y % 100 != 0) || (Y % 400 == 0) ) {
				isLeapYear = true;
			}
			
			// 3) Find out if Y-1 is a leap year
			var lastYear:Number = Y - 1;
			var lastYearIsLeap:Boolean;
			if( ((lastYear % 4 == 0)  &&  (lastYear % 100 != 0)) || (lastYear % 400 == 0) ) {
				lastYearIsLeap = true;
			}
			
			// 4) Find the Day of Year Number for Y M D
			var month:Array = [0,31,59,90,120,151,181,212,243,273,304,334];
			var DayOfYearNumber:Number = D + month[M];
			if(isLeapYear && M > 1) {
				DayOfYearNumber++;
			}
			
			// 5) Find the weekday for Jan 1 (monday = 1, sunday = 7)
			var YY:Number = (Y-1) % 100; // ...
			var C:Number = (Y-1) - YY; // get century
			var G:Number = YY + YY/4; // ...
		   	var Jan1Weekday:Number = 1 + (((((C / 100) % 4) * 5) + G) % 7);
			
			// 6) Find the weekday for Y M D
			var H:Number = DayOfYearNumber + (Jan1Weekday - 1);
		   	var Weekday:Number = 1 + ((H -1) % 7);
			
			var YearNumber:Number = Y;
			var WeekNumber:Number;
			// 7) Find if Y M D falls in YearNumber Y-1, WeekNumber 52 or 53
			if ( (DayOfYearNumber <= (8-Jan1Weekday)) && (Jan1Weekday > 4) )
			{
				//trace('Date is within the last week of the previous year.');
				YearNumber = Y - 1;
				if ( (Jan1Weekday == 5) || ( (Jan1Weekday == 6) && isLeapYear) ) {
					WeekNumber = 53;
				} else { 
					WeekNumber = 52;
				}
			}
			
			// 8) Find if Y M D falls in YearNumber Y+1, WeekNumber 1
			if (YearNumber == Y)
			{
				var I:Number = 365;
				if (isLeapYear)
				{ 
					I = 366;
				}
				if (I - DayOfYearNumber < 4 - Weekday)
				{
					//trace('Date is within the first week of the next year.');
					YearNumber = Y + 1;
					WeekNumber = 1;
				}
			}
			
			// 9) Find if Y M D falls in YearNumber Y, WeekNumber 1 through 53
			if (YearNumber == Y)
			{
				//trace('Date is within it\'s current year.');
				var J:Number = DayOfYearNumber + (7 - Weekday) + (Jan1Weekday -1);
				WeekNumber = J / 7;
				if (Jan1Weekday > 4)
				{
					WeekNumber--;
				}
			}
			
			return WeekNumber;
		}
		
		/**
		 * Convert time in seconds to hours, minute, seconds.
		 * 
		 * @param seconds The time in seconds.
		 * @return <code>Object</code> with <code>hour</code>, <code>minute</code>, <code>second</code> properties and the corresponding values.
		 */ 
		public static function secToTimeObject(seconds:Number):Object
		{
			var timeObj:Object = new Object();
			timeObj.hour = Math.floor((seconds/(60*60)));
			timeObj.minute = Math.floor((seconds/60)%60);
			timeObj.second = Math.floor(seconds%60)
			
			return timeObj;
		}
		
		/**
		 * Formats seconds to a String.
		 * 
		 * @param format The format parameter can be set to: 'colon' to get the time in format '(hh):(mm):(ss)'
		 * , 'short' for '(h)h (m)m (s)s' or 'long' for '(h) hours (m) minutes (s) seconds'. The default is 'colon'
		 */
		public static function secToTime(seconds:Number, format:String = 'colon'):String
		{
			
			var sec:Number = Math.floor(seconds%60);
			var min:Number = Math.floor((seconds/60)%60);
			var hours:Number = Math.floor((seconds/(60*60)));
			
			var secToTime:String = '';
			
			switch(format){
				case 'short':
					secToTime = (hours > 0 ? hours.toString() + "h " : '') 
						+ (min > 0 ? min.toString() + "m " : '')  
						+ (sec > 0 ? sec.toString() + "s" : '');
				break;
				case 'long':
					secToTime = (hours > 0 ? hours.toString() + " hours " : '') 
						+ (min > 0 ? min.toString() + " minutes " : '')  
						+ (sec > 0 ? sec.toString() + " seconds" : '');
				break;
				default:
					var nsMask:String = "00";
					var hoursMask:String = nsMask;
					
					if(hours > 99) {
						hoursMask = "000";
					} 
					
					secToTime = (hoursMask + hours).substr(-hoursMask.length) + ':' + 
							(nsMask + min).substr(-nsMask.length) + ':' +  
							(nsMask + sec).substr(-nsMask.length);
				break;
			
			}
			
			return secToTime;
			
			
		}
	}
}