package classes.skins
{
	import mx.charts.LegendItem;
	import mx.controls.Label;
	
	/**
	 * @private
	 */
	public class CustLegendItemPieChart extends LegendItem
	{    
		
		private var _label:Label;
	    
		public function CustLegendItemPieChart()
		{
	         super();
	         this.styleName = "pieChartLegendItem";
		}

	}
}