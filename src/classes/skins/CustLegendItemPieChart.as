package classes.skins
{
	/*
		© Rico Leuthold [rleuthold@access.ch] // 2009
		
		This program is free software: you can redistribute it and/or modify
	    it under the terms of the GNU General Public License as published by
	    the Free Software Foundation, either version 3 of the License, or
	    (at your option) any later version.
	
	    This program is distributed in the hope that it will be useful,
	    but WITHOUT ANY WARRANTY; without even the implied warranty of
	    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	    GNU General Public License for more details.
	
	    You should have received a copy of the GNU General Public License
	    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	*/
	
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