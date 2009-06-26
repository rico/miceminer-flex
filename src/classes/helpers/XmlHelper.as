package classes.helpers
{
	import classes.GlobalVars;
	
	/**
	 *  Static methods to get values from the xml configuration file.
	 * 
	 * <p>The configuration xml is stored in the <code>ConfigXML</code> attribute in the <code>GlobalVars</code> class.</p>
	 * 
	 * @see classes.GlobalVars 
	 */ 
	public class XmlHelper
	{
		
		/**
		 * Gets all the <code>gridId</code> attributes from the provided <code>XML</code> and resturn the in an <code>Array</code>.
		 */
		public static function getGridIds(gridListXML:XML):Array
		{
			//trace("dataTab->getGridConfig: " + gridListXML.toXMLString())
			var gridIds:Array = new Array();
			var gridsXML:XMLList = gridListXML..id;
			
			for each(var grid:XML in gridsXML)
			{
				//trace("dataTab->grid: " + grid.toXMLString());
				var gridId:String = grid.toString();
				gridIds.push(gridId);
			}
			
			// Debug
			//trace("dataTab->dataGrids: " + gridIds.toString());
			
			return gridIds;
		}
		
		/**
		 * Get the <code>&lt;dataGrid&gt;</code> <emp>XML</emp> for an <code>itemGrid id</code>.
		 * 
		 * <p>Each <code>&lt;grid&gt;</code> which is a child node of the <code>&lt;itemsGridsInDateRange&gt;</code> node in the xml configuration file has associated <code>data grids</code>.
		 * The <code>data grid</code> id's are in a child node called <emp>&lt;dataGrids&gt;</emp> of the <code>&lt;grid&gt;</code> tag.
		 * The function gets these id's, searches through the xml configuration file for the corresponding <code>&lt;grid&gt;</code> tag
		 * and appends them to an <code>XMLList</code> with all the child nodes.</p>
		 * 
		 * @param gridId The <code>id</code> of the <code>&lt;grid&gt;</code> which is a child node of the <code>&lt;itemsGridsInDateRange&gt;</code> node.
		 * 
		 * @return XMLList with all the <code>&lt;dataGrids&gt;</code> configuration corresponding to the item grid
		 * 
		 * @see classes.rpc.GetData
		 */    
		public static function getDataGridsXML(gridId:String):XMLList
		{
			
			var ConfigXML:XML = GlobalVars.getInstance().ConfigXML;
			var dataGridsXML:XMLList = ConfigXML..flex..dataGrids;
			
			
			var dataGridIds:XMLList = ConfigXML..flex..itemsGridsInDateRange..grid.(@id == gridId)..dataGrids.id;
			
			//var gridIds:Array = getGridIds(gridListXML);
			
			var gridIdDataGridsXML:XMLList = new XMLList();
			
			for each(var dataGridIdXML:XML in dataGridIds) {
				var dataGridId:String = dataGridIdXML.toString();
				var gridXMLList:XMLList = dataGridsXML.grid.( attribute("id" ) == dataGridId );
				
				gridIdDataGridsXML += gridXMLList;
				
			} 
			
			return gridIdDataGridsXML;

		}
		
		/**
		 * Get a <code>data grid</code> xml configuration.
		 * 
		 * <p>A <code>data grid</code> is a <code>&lt;grid&gt;</code> node which is the child node of the <code>&lt;grids&gt;</code> node.</p> 
		 * 
		 * @return <code>grid</code> xml configuration.
		 */
		public static function getGridXML(gridId:String):XML
		{
			return XML(GlobalVars.getInstance().ConfigXML)..flex..grids..grid.(attribute("id") == gridId)[0];
		}
		
		/**
		 * Get xml configuration for all &lt;itemsGridsInDateRange&gt;  grid nodes in the configuration xml file.
		 * 
		 * @return XMLList with all <code>&lt;itemsGridsInDateRange&gt;</code> configurations.
		 */ 
		public static function getItemsGridsInDateRangeXML():XMLList
		{
			
			return XML(GlobalVars.getInstance().ConfigXML)..flex..itemsGridsInDateRange..grid;

		}
		
		/**
		 * Get all <code>&lt;itemsGrids&gt;</code> nodes from the xml configuration file. These are all <code>&lt;itemsGrids&gt;</code> child nodes.
		 * 
		 * @return XMLList with all <code>item grids</code> configuration
		 */ 
		public static function getItemsGrids():XMLList
		{
			
			return XML(GlobalVars.getInstance().ConfigXML)..flex..itemsGrids..grid;
		}
		
		/**
		 * Get the <code>chart</code> XML configuration for a grid.
		 * 
		 * Returns the <code>&lt;chart&gt;</code> xml config for the given grid
		 */		
		public static function getChartsXML(gridId:String):XMLList
		
		{
				
			var ConfigXML:XML = GlobalVars.getInstance().ConfigXML;
			var chartsXMLList:XMLList = ConfigXML..flex..charts.chart;
			var gridXML:XMLList = ConfigXML..flex..grids..grid.(attribute("id") == gridId);
			var gridChartXMLList:XMLList = gridXML.chart;
		
			var gridChartsXMLList:XMLList = new XMLList();
			
			for each (var gridChartXML:XML in gridChartXMLList ) {
				
				var chartType:String = gridChartXML.@type;
				var chartId:String = gridChartXML.@id;
				
				for each (var chartItemXML:XML in chartsXMLList) {
					
					if(chartItemXML.@type == chartType && chartItemXML.@id == chartId) {
						gridChartsXMLList += chartItemXML;
					}
				}
			}
		 	
			return gridChartsXMLList;
			
		}
		
		/**
		 * Get the <code>drillDownchart</code> XML configuration for a grid (can only be one)
		 * 
		 * @return <code>&lt;drillDownChart&gt;</code> XML config for the given <code>Grid</code>
		 */		
		public static function getDrillDownChartXML(gridId:String):XMLList
		
		{
				
			var ConfigXML:XML = GlobalVars.getInstance().ConfigXML;
			var chartsXMLList:XMLList = ConfigXML..flex..charts.chart;
			var gridXML:XMLList = ConfigXML..flex..grids..grid.(attribute("id") == gridId);
			var gridChartXMLList:XMLList = gridXML.chart.(attribute("drillDown") == "true");
		
			var gridChartsXMLList:XMLList = new XMLList();
			
			for each (var gridChartXML:XML in gridChartXMLList ) {
				
				var chartType:String = gridChartXML.@type;
				var chartId:String = gridChartXML.@id;
				
				for each (var chartItemXML:XML in chartsXMLList) {
					
					if(chartItemXML.@type == chartType && chartItemXML.@id == chartId) {
						gridChartsXMLList += chartItemXML;
					}
				}
			}
		 	
			return gridChartsXMLList;
			
		}
		
		/**
		 * Get the <code>gridId</code> which is the drilldown for the passed <code>chartXML</code>
		 * 
		 * @return the <code>gridId</code> for the drilldown grid
		 */
		public static function getDrillDownGridId(chartXML:XML):String
		{
			var reqGridXMLList:XMLList = chartXML.drillDown.gridId;
			var reqGridId:String = reqGridXMLList.toString();
			
			return reqGridId; 
		}
		
		/**
		 * Get the <code>columns</code> of a grid with the given id
		 * 
		 * @return the <code>&lt;col&gt;</code> tags as an XMLList
		 */
		public static function getGridColsXML(gridId:String):XMLList
		{
			var gridXML:XML = XML(GlobalVars.getInstance().ConfigXML)..flex..grids..grid.(@id == gridId);
			var colXMLList:XMLList = gridXML.col;
			
			return colXMLList;
		}
		
		/**
		 * Get the <code>label</code> attribute for the selected database field from the <emp>XML</emp> 
		 * configuration for this column
		 */ 
		public static  function getLabel(field:String, colsXML:XMLList):String
		{
			var label:String;
			
			for each (var col:XML in colsXML)
			{
				var colField:String = col.@field;
				
				if(colField == field)
				{
					label = col.@label
				}
				
			}
			
			return label;
			
		}
		
		/**
		 * Return the <code>chart</code> description (label).
		 */ 
		public static function getChartDesc(chartXML:XML, detail:String):String
		{
			return chartXML.desc + " " + detail;
		}
		
		/**
		 * @return the <code>chart</code> dataTip value.
		 */ 
		public static function getChartDataTip(chartXML:XML):String
		{
			return chartXML.dataTip;
		}
		
		/**
		 * @return the string for this chart which should be added to the label.
		 */		
		public static function getChartAddLabel(chartXML:XML):String
		{
			var subLabelFieldXMLList:XMLList = chartXML.addLabel.field;
            var subLabelField:String = subLabelFieldXMLList.toString();
            
            return subLabelField;
		}
		
		/**
		 * Get analysis XML from config.
		 * 
		 * @return a <code>&lt;node&gt;</code> tag for each analysis with an attribute for the <b>comp</b> and the <b>label</b> 
		 */
		public static function getAnalysis():XML
		{
			var ConfigXML:XML = GlobalVars.getInstance().ConfigXML;
			var analysisXMLList:XMLList = ConfigXML..flex..analysises.analysis;
			
			var analysisesTreeXML:XML = <tree/>;
			
			for each (var analysisXML:XML in analysisXMLList) {
					
				var node:XML = <node/>;
				node['@label'] = analysisXML.@label;
				node['@comp'] = analysisXML.@comp;
				
				analysisesTreeXML.appendChild(node);

			}
			
			
			return analysisesTreeXML; 
		}
		
		/**
		 * Get xml configuration for an analysis node
		 */
		public static function getAnalysisXML(id:String):XML
		{
			return XML(GlobalVars.getInstance().ConfigXML)..flex..analysises..analysis.(attribute("id") == id)[0];
			
		}
		
		/**
		 * Get xml configuration for the <code>&lt;fileManagers&gt;<code> node.
		 * 
		 */
		public static function getFileManagers():XML
		{
			var ConfigXML:XML = GlobalVars.getInstance().ConfigXML;
			var fileManagerXMLList:XMLList = ConfigXML..flex..fileManagers.fileManager;
			
			var fileManagerTreeXML:XML = <tree/>;
			
			for each (var fileManagerXML:XML in fileManagerXMLList) {
					
				var node:XML = <node/>;
				node['@id'] = fileManagerXML.@id;
				node['@label'] = fileManagerXML.@label;
				node['@comp'] = fileManagerXML.@comp;
				
				fileManagerTreeXML.appendChild(node);

			}
		
			return fileManagerTreeXML;
		}
		
		/**
		 * Get xml-configuration for a <code>&lt;fileManager&gt;</code> node which is a child of the <code>&lt;fileManagers&gt;<code> node.
		 */
		public static function getFileManagerXML(id:String):XML
		{
			
			return XML(GlobalVars.getInstance().ConfigXML)..flex..fileManagers..fileManager.(attribute("id") == id)[0];
		}
		
		/**
		 * Get the database table name based on the id out of the xml-configuration file.
		 * 
		 * <p>Table names are <code>&lt;table&gt;</code> nodes which are child nodes of the <code>&lt;config&gt; &lt;db&gt; &lt;tables&gt;</code> node.
		 * 
		 * @example Current xml-configuartion for the database tables.
		 * 
		 * <listing version="3.0">		 
		 *	&lt;db&gt;
		 *		&lt;tables&gt;
		 *			&lt;table id="data"&gt;data&lt;/table&gt;
		 *			&lt;table id="direction_results"&gt;dir&lt;/table&gt;
		 *			&lt;table id="results"&gt;res&lt;/table&gt;
		 *			&lt;table id="meetings"&gt;meetings&lt;/table&gt;												
		 *			&lt;table id="rfids"&gt;rfid&lt;/table&gt;
		 *			&lt;table id="boxes"&gt;box&lt;/table&gt;		
		 *			&lt;table id="antennas"&gt;ant&lt;/table&gt;				
		 *			&lt;table id="antenna_count"&gt;ant_count&lt;/table&gt;						
		 *			&lt;table id="rfid_count"&gt;rfid_count&lt;/table&gt;								
		 *			&lt;table id="box_count"&gt;box_count&lt;/table&gt;										
		 *			&lt;table id="logfiles"&gt;logs&lt;/table&gt;													
		 *		&lt;/tables&gt;
		 *	&lt;/db&gt;
		 * </listing>  
		 */
		public static function getDbTableName(id:String):String
		{
			return XML(GlobalVars.getInstance().ConfigXML)..db..tables..table.(attribute("id") == id)[0];
		}
		
		/**
		 * Get the xml configuration for a component out of the xml-configuration file.
		 * <p>The component cofigurations are found in the path <code>config.flex.components</code>
		 */
		public static function getComponentXML(componentName:String):XML
		{
			var compXML:XML = XML(GlobalVars.getInstance().ConfigXML).flex.components.component.(@name == componentName)[0];
			return compXML;
		}
	}
}