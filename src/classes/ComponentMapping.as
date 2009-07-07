package classes
{
	/**
	 * Helper class for component name mapping.
	 * 
	 * <p>The name attribute values of the <code>config.flex.components.component</code> nodes in the configuration-xml must be
	 * the same as the values of the constants below.</p>
	 * 
	 * <p>So if you change the values in this class you have to change the values in the xml-configuration file as well or vice versa.</p>   
	 */
	public class ComponentMapping
	{
		 public static const BROWSE_DATA:String = "Browse Data";
		 public static const DATA_OVERVIEW:String = "Data Overview";
		 public static const DATA_ANALYSIS:String = "Data Analysis";
		 public static const GRAPH_DATA:String = "Graph Data";
		 public static const UPLOAD_FILES:String = "Upload Files";
	}
}