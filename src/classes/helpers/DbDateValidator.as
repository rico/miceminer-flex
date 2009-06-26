package classes.helpers
{
	import mx.validators.DateValidator;
	import mx.validators.ValidationResult;
	import classes.helpers.DateHelpers;
	
	public class DbDateValidator extends DateValidator
	{
		
		public var maxDate:Date;
		public var minDate:Date;
		
		 // Define Array for the return value of doValidation().
        private var results:Array;

        // Constructor.
        public function DbDateValidator() {
            // Call base class constructor. 
            super();
        }
        
        // Define the doValidation() method.
        override protected function doValidation(value:Object):Array {

            // Clear results Array.
            results = [];

            // Call base class doValidation().
            results = super.doValidation(value);        
            // Return if there are errors.
            if (results.length > 0)
                return results;
        
            var currentYear:Number = new Date().getFullYear();
            var maxDateVal:Number = maxDate.valueOf();
            var minDateVal:Number = minDate.valueOf();
            
            var toCheck:Number = new Date(value.month + "/" + value.day + "/" + value.year).valueOf();
            
            // check for db range
            if(  toCheck < minDateVal || toCheck > maxDateVal) {
            	
            	var dbRangeF:Array = DateHelpers.formatDateRange([minDate, maxDate]);
            		
				results.push(new ValidationResult(true,null, "outOfRange", 
					"This date is out of the allowed date Range ("+ dbRangeF[0] + " to " + dbRangeF[1] + ")"));
			} 
                        
            return results;
        }
    
	}
}