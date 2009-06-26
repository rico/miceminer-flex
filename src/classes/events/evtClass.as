package classes.events
{
   	import flash.events.Event;
	/**
	 * Global event handling.
	 * 
	 * <p>See <a href="http://www.helihobby.com/html/alon_desingpattern.html">ALON design pattern</a> for more information.</p>
	 * 
	 */
   	public class evtClass extends Event
   	{

		public var evProp:Array;

			public function evtClass(evParam:Array,type:String)
			{
				super(type);
				this.evProp = evParam;
			}
       	 
		override public function clone():Event
		{
			return new evtClass(evProp,type);
		}
   	}
}