package classes.events
{
	import flash.events.EventDispatcher;
	import classes.interfaces.*;

	/**
	 * Global event handling.
	 * 
	 * <p>Instance will be created as needed.</p>
	 * <p>See <a href="http://www.helihobby.com/html/alon_desingpattern.html">ALON design pattern</a> for more information.</p>
	 * 
	 * @see classes.events.Globs
	 */
	public class ComBroker extends EventDispatcher
	{
		
		private var _registry:Object;

		public function ComBroker() {
			_registry = new Object();
		}
		
		/**
		 * @private
		 */
		public function setService(name:String , obj:IService):void {
			_registry[name] = obj;
		}
		
		/**
		 * @private
		 */
		public function getService(name:String):IService {
		
			if ( _registry[name] == null ) {
				return null;
			} else {
				return _registry[name];
			}
		}
	}
}