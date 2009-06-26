package classes.helpers
{
	///////////////////////////////////////////////////
	// written by rico leuthold - rleuthold@access.ch
	// 
	// use at your own risk!	
	///////////////////////////////////////////////////	
	import flash.geom.Point;
	
	/**
	 * Non intersection polygons area and bounding box calculation.
	 * 
	 * <p>Provides access to Polygon bounding box and area calculation.
	 * The points in the array passed as the constructor argument must be of object type <code>flash.geom.Point</code>.</p>
	 * 
	 * <p>The bounding box is calculated based on the <a href="http://en.wikipedia.org/wiki/Jarvis_march">Jarvis March</a> algorithm.</p>
	 * <p>Implementation ported from a <i>Java</i> implemetation at <a href="http://www.inf.fh-flensburg.de/lang/algorithmen/geo/jarvis.htm">http://www.inf.fh-flensburg.de/lang/algorithmen/geo/jarvis.htm</a>.</p>
	 * 
	 * <p>The formula for the area calculation used in this class can be found at <a href="http://mathworld.wolfram.com/PolygonArea.html">http://mathworld.wolfram.com/PolygonArea.html</a>.</p>
	 * 
	 */ 
	public class Polygon
	{
		
		public var polygonCalculationPoints:Array;
		private var _hull:Array;
		private var _n:int;
    	private var _h:int;
		
		/**
		 * @param points The points of object type <code>flash.geom.Point</code> which build the non intersecting polygon.
		 */ 
		public function Polygon(points:Array = null)
		{
			this.polygonCalculationPoints = [];
			
			for each( var point:Point in points) {
				polygonCalculationPoints.push( new PolyCalcPoint( point.x, point.y) );
			}
		}
		
		/**
		 * @return The <code>flash.geom.Point</code>'s which build the hull of the polygon
		 */
		public function computeHull():Array
    	{
	        //this.p=p;
	        _n = polygonCalculationPoints.length;
	        _h = 0;
	        jarvisMarch();
	        
	        _hull = polygonCalculationPoints.slice(0,_h);
	        return _hull;
    	}
    	
    	/**
		 * @return The area of the hull <code>flash.geom.Point</code>'s. 
		 */
    	public function area():Number
    	{
    		var area:Number = 0;
    		
    		if(_hull == null)
    		{
    			computeHull();
    		}

    		var n:int;
   			if(_hull.length > 2) 
   			{
   				
   				var hullClosed:Array = polygonCalculationPoints.slice(0,_h);
    			hullClosed.push(polygonCalculationPoints[0]);
   				
	    		for (n=0; n < hullClosed.length -1; n++) 
		        {
		            area += (hullClosed[n].x * hullClosed[n+1].y) - (hullClosed[n+1].x * hullClosed[n].y);
		        }
		        
		        area = area * 0.5;
    		} else {
    			area = 0;
    		}
    		
    		return area;
    	}
    	
    	private function jarvisMarch():void
    	{
        	var i:int=indexOfLowestPoint();
	        do
	        {
	            exchange(_h, i);
	            i=indexOfRightmostPointFrom(polygonCalculationPoints[_h]);
	            _h++;
	        }
	        while (i>0);
		
    	}
    	
    	private function indexOfLowestPoint():int
	    {
	        var i:int;
	        var min:int = 0;
	        
	        for (i=1; i<_n; i++) 
	        {
	            if (polygonCalculationPoints[i].y < polygonCalculationPoints[min].y ||
	            	 polygonCalculationPoints[i].y==polygonCalculationPoints[min].y &&
	            	  polygonCalculationPoints[i].x < polygonCalculationPoints[min].x)
	            {
	                min=i;
	            }
	        }
	        
	        return min;
	    }
	    
	    private function indexOfRightmostPointFrom(q:PolyCalcPoint):int
   		{
	        var i:int = 0;
	        var j:int;
	        
	        for (j=1; j< _n; j++) 
	        {
	            if ( polygonCalculationPoints[j].relTo(q).isLess( polygonCalculationPoints[i].relTo(q) ) )
	            {
	                i=j;
	            }
	        }
	        
	        return i;
    	}
    	
    	private function exchange(i:int, j:int):void
		{
			var t:PolyCalcPoint = polygonCalculationPoints[i];
        	
        	polygonCalculationPoints[i] = polygonCalculationPoints[j];
        	polygonCalculationPoints[j] = t;
    	}
	}
}


import flash.geom.Point;
/////////////////////////////////////////////////////////////////////////////
// Adds some methods to the flash.geom.Point class used for the calculations
/////////////////////////////////////////////////////////////////////////////   
class PolyCalcPoint extends Point
{
	public function PolyCalcPoint(x:Number, y:Number):void
	{
		super(x, y);
	}
	
	public function relTo(p:PolyCalcPoint):PolyCalcPoint
    {
        return new PolyCalcPoint(x-p.x, y-p.y);
    }

    public function isLower(p:PolyCalcPoint):Boolean
    {
        return y<p.y || y==p.y && x<p.x;
    }

    public function cross(p:PolyCalcPoint):int
    {
        return x*p.y-p.x*y;
    }
    
     public function mdist():int
    {
         return Math.abs(x)+Math.abs(y);
    }

    public function isFurther(p:PolyCalcPoint):Boolean
    {
        return mdist()>p.mdist();
    }

	public function isLess(p:PolyCalcPoint):Boolean
    {
        var f:int=cross(p);
        return f>0 || f==0 && isFurther(p);
    }
	
}