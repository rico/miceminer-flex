/**
 * Helper method to get passowrd protected XML configuration file
 * 
 * @class Base64
 * @author Abdul Qabiz (http://www.abdulqabiz.com)
 * @version 1.0
 * @requires ActionScript 3.0 and Flash Player 8.5 (atleast)
 * 
 * @credits Based on Aardwulf Systems'(www.aardwulf.com) Javascript implementation.
 *			   (http://www.aardwulf.com/tutor/base64/base64.html)
 * 
**/
package classes.helpers
{
	public class Base64
	{
		 
		 private static const KEY_STR:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

		//Base64:encode(..) encodes a string to a base64 string
		public static function encode(input:String):String
		{
			var output:String = "";
		    var chr1:uint, chr2:uint, chr3:uint;
		    var enc1:uint, enc2:uint, enc3:uint, enc4:uint;
		    var i:uint = 0;
			var length:uint = input.length;
		    do{
				chr1 = input.charCodeAt(i++);
				chr2 = input.charCodeAt(i++);
				chr3 = input.charCodeAt(i++);
	            enc1 = chr1 >> 2;
		        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			    enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
				enc4 = chr3 & 63;
		         if (isNaN(chr2)) 
				 {
			        enc3 = enc4 = 64;
				 } 
				 else if (isNaN(chr3)) 
				{
					enc4 = 64;
				}
				output+= KEY_STR.charAt(enc1) + KEY_STR.charAt(enc2) + KEY_STR.charAt(enc3) + KEY_STR.charAt(enc4);
			}while (i < length);
			return output;
		}


		//Base64:decode(..) decodes a base64 string
   
		public static function decode(input:String):String
		{
		    var output:String = "";
			var chr1:uint, chr2:uint, chr3:uint;
		    var enc1:int, enc2:int, enc3:int, enc4:int;
			var i:uint = 0;
			var length:uint = input.length;

			// remove all characters that are not A-Z, a-z, 0-9, +, /, or =
			var base64test:RegExp = /[^A-Za-z0-9\+\/\=]/g;
			if (base64test.exec(input))
			{
		     throw new Error("There were invalid base64 characters in the input text.\n" +
               "Valid base64 characters are A-Z, a-z, 0-9, '+', '/', and '='\n" +
               "Expect errors in decoding.");
			}
			input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

			do{
				enc1 = input.indexOf(input.charAt(i++));
				enc2 = input.indexOf(input.charAt(i++));
				enc3 = input.indexOf(input.charAt(i++));
				enc4 = input.indexOf(input.charAt(i++));
				
				chr1 = (enc1 << 2) | (enc2 >> 4);
				chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
				chr3 = ((enc3 & 3) << 6) | enc4;
				output+= String.fromCharCode(chr1);

				if (enc3 != 64)
				{
					output+= String.fromCharCode(chr2);
				}
				if (enc4 != 64) 
				{
					output+= String.fromCharCode(chr3);
				}
	
			}while(i < length);

			return output;
		}
	}
}
