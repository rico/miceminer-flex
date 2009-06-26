package classes.preloader
{
	import classes.GlobalVars;
	import classes.events.*;
	import classes.rpc.DateRange;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;
	import mx.utils.Base64Encoder;

    public class CustomPreloader extends DownloadProgressBar

    {
    	  	
    	private var Globals:GlobalVars = GlobalVars.getInstance();
    	private var ConfigXML:XML;
    	public var loadWin:CustomLoader;
    	private var _configLoader:URLLoader;
    	//private var _preloader:Sprite;
    	private var m_Timer: Timer;
    
		public function CustomPreloader()
        {   
			
			super();
			
			//var browser: BrowserManager;
			loadWin = new CustomLoader;            
			this.addChild(loadWin);
			m_Timer = new Timer(1);
			m_Timer.addEventListener(TimerEvent.TIMER, timerEventHandler);
			m_Timer.start();
			
									

		}

		override public function set preloader(value:Sprite):void
        {

			//_preloader = value;

	        value.addEventListener(ProgressEvent.PROGRESS, progressEventHandler);
	        value.addEventListener(Event.COMPLETE, completeEventHandler);     	
	        value.addEventListener(FlexEvent.INIT_PROGRESS, initProgressHandler);
	        value.addEventListener(FlexEvent.INIT_COMPLETE, FlexInitComplete);

		}
		
		private function progressEventHandler(event: ProgressEvent): void{
            var progress: Number = event.bytesLoaded / event.bytesTotal * 100;
            if (loadWin){
                loadWin.progress = progress;
            }
        }
        
        private function timerEventHandler(event: TimerEvent): void{
	        this.stage.addChild(this);
	        var width: Number = this.stage.stageWidth * 0.4; // Get 40% for the Stage width
	        // Set the Position of the Progress bar to the middle of the screen
	        loadWin.x = (this.stage.stageWidth - loadWin.getWidth()) / 2;
	        loadWin.y = (this.stage.stageHeight - loadWin.getHeight()) / 2;
	        loadWin.refreshProgressBar();
        }
        
        private function completeEventHandler(event: Event): void{
            var i: int = 0;
        }
        
        private function initProgressEventHandler(event: FlexEvent): void{
            var i: int = 0;
        }

        // Override to return true so progress bar appears
        // during initialization.       
        override protected function showDisplayForInit(elapsedTime:int, count:int):Boolean {
            
            //this.downloadingLabel = "Initilazing miceMiner";
            return false;

        }

        // Override to return true so progress bar appears during download.       
        override protected function showDisplayForDownloading(elapsedTime:int, event:ProgressEvent):Boolean 
        {
        	//this.downloadingLabel = "Loading miceMiner";
            return false;

        }

        


		// called when flex init is complete and we want to go on getting the configuration file 
        private function FlexInitComplete(event:Event):void
        {
           
        	var global:GlobalVars = GlobalVars.getInstance();   
            Security.loadPolicyFile(global.policyFile);
            
            /*
            	Workaround for loading data with basic auth copied from:
            	http://synja.com/?p=21
            */
            var configRequest:URLRequest = new URLRequest(global.configFile);
            configRequest.method = "POST";
            
            // Some type of POST data must be present for POST to happen in the first place
			configRequest.data = "dummy_data=needed_for_post_to_work";
			
			// user credentials
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encode(global.USER + ":" + global.PASSWD);
			
			// authentication string
			var authString:String = "Basic " + encoder.toString();
			
			// request headers
			configRequest.requestHeaders = [new URLRequestHeader("Authorization", authString), new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded")];
            
            // the url loader
            _configLoader = new URLLoader();     
            _configLoader.addEventListener(Event.COMPLETE, configLoaded);
            _configLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            
            try {
                _configLoader.load(configRequest);
            } catch (error:Error) {
                trace("Unable to load requested document.");
                Alert.show("Config load => Security error " + error.errorID.toString());
            }

        }
        
		private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
            Alert.show("Config load => securityError: " + event);
            _configLoader.removeEventListener(Event.COMPLETE, configLoaded);
            _configLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }
		
		// called when the configuration file is loaded           
        private function configLoaded(event:Event):void
        {
				
			var loader:URLLoader = URLLoader(event.target);
			try {
				if(loader.bytesTotal == 0) {
					throw new Error("Error: config file seems to be empty!");
				}	
   			} catch (err:Error){
   				Alert.show(err.message);
   			}
   			
            Globals.ConfigXML = new XML(loader.data);
            this.ConfigXML = Globals.ConfigXML;
            trace("[CustomPreloader]: config loaded " + (loader.bytesTotal/1024).toFixed(2) + " KBytes");
            
            _configLoader.removeEventListener(Event.COMPLETE, configLoaded);
            _configLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
         
           	// set dateRange
            DateRange.getDateRange();
            Globs.broker.addEventListener(EventsGlobals.DATE_RANGE_LOADED,this.dateRangeLoaded);
        }
      	
		private function dateRangeLoaded(event:ObjectDataEvent):void
      	{
      		// When the config is loaded, preload is complete
          
      		Globs.broker.removeEventListener(EventsGlobals.DATE_RANGE_LOADED,this.dateRangeLoaded);
      		Globs.broker.dispatchEvent(new ObjectDataEvent(EventsGlobals.PRELOAD_COMPLETE,null));
      		
      		loadWin.ready = true;
            m_Timer.stop();
            
      		dispatchEvent(new Event(Event.COMPLETE,true));	
      		trace("Preload complete");
      	}
           
	}
}