package classes.helpers
{
	import classes.GlobalVars;
	import classes.events.EventsGlobals;
	import classes.events.Globs;
	import classes.events.ObjectDataEvent;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	
	/**
	 * Dispatched when the request has been successful.
	 * 
	 * <p>Along with the event the cgi request data is passed in an array which is the <code>values</code> prooperty of the event:</p>
	 *  	<ul><li><code>event.values[0]</code>
	 * 
	 * @see classes.events.EventsGlobals
	 * 
	 * @eventType classes.events.EventsGlobals.CGI_REQUEST_COMPLETE
	 */
	[Event(name="CgiRequestComplete", type="classes.events.ObjectDataEvent")]
	
	public class CgiRequest
	{
		
		private var _request:URLRequest;
		private var _script:String;
		private var _params:URLVariables;
		private var _loader:URLLoader;
		
		/**
		 * Execute a cgi (http) POST request.
		 * 
		 * @param script Script location
		 * @param params The parameters to send as an <code>Obejct</code>.
		 */
		public function CgiRequest(script:String, paramsObj:Object)
		{
			_script = script;
			_params = new URLVariables();
			
			var ConfigXML:XML = GlobalVars.getInstance().ConfigXML;
			var domain:String = ConfigXML..domain;
			var requestUrl:String = domain.concat(_script);
			
			// seting up request parameters
			for (var param:String in paramsObj) {
				_params[param] = paramsObj[param];
			}
			
			_request = new URLRequest(requestUrl);
			_request.method = URLRequestMethod.POST;
			_request.data = _params;
			
			_loader = new URLLoader();
			configureListeners(_loader); // add the event listeners
			
            try {
                _loader.load(_request);
            }
            catch (error:SecurityError)
            {
                Alert.show("[CgiRequest]:\tA SecurityError has occurred => " + error.message.toString());
                removeListeners(_loader);
            }
		}
            
        /**
        * Configure event listeners
        */ 
        
        private function configureListeners(dispatcher:IEventDispatcher):void 
        {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
        
        /**
        * Remove event listeners
        */ 
        private function removeListeners(dispatcher:IEventDispatcher):void 
        {
            dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
        
        /*
        	EVENT LISTENERS
        */
        private function completeHandler(event:Event):void {
        	var answerLoader:URLLoader = URLLoader(event.target);
        	Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.CGI_REQUEST_COMPLETE,null,answerLoader.data));
        	trace("completeHandler => " + answerLoader.data);
        	removeListeners(_loader);
        	
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            Alert.show("[CgiRequest]:\tsecurityErrorHandler => " + event);
            removeListeners(_loader);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            Alert.show("[CgiRequest]:\tioErrorHandler => " + event);
            removeListeners(_loader);
        }
	}
}