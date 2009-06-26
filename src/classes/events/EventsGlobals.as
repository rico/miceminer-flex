package classes.events
{
	/**
	 * Constants for the global event handler.
	 * 
	 * <p>See <a href="http://www.helihobby.com/html/alon_desingpattern.html">ALON design pattern</a> for more information.</p>
	 * 
	 * @see classes.events.ObjectDataEvent
	 */ 
	public class EventsGlobals
	{
		public static const PRELOAD_COMPLETE:String	=	"PreloadComplete";  
		public static const EXPORT_COMPLETE:String	=	"ExportComplete";
		public static const DATE_RANGE_LOADED:String = "DateRangeLoaded";		
		public static const ITEMS_LOAD_COMPLETE:String	=	"ItemsLoadComplete";
		public static const ITEMS_IN_DATE_RANGE_LOAD_COMPLETE:String	=	"ItemsInDateRangeLoadComplete";
		public static const DATA_LOAD_COMPLETE:String	=	"DataLoadComplete";
		public static const LOAD_ERROR_OCCURED:String	=	"LoadErrorOccured";
		public static const DATA_LOAD_CANCELED:String	=	"DataLoadCanceled";
		public static const GENERIC_DATA_LOADED:String = "GenericDataLoaded";
		public static const GENERIC_DATA_LOAD_FAILED:String = "GenericDataLoadFailed";
		public static const GET_DATA_BY_METHOD_RESULT:String = "GetDataByMethodResult";
		public static const GET_DATA_BY_METHOD_FAULT:String = "GetDataByMethodFault";
		public static const GRAPH_DATA_LOADED:String = "GraphDataLoaded";
		public static const EDGE_DATA_LOADED:String = "EdgeDataLoaded";
		public static const CGI_REQUEST_COMPLETE:String = "CgiRequestComplete";
		
		
	}
}