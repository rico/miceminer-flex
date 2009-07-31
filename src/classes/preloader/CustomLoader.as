package classes.preloader
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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;

	
	public class CustomLoader extends Loader
	{
         // Logo picture
        [Bindable]
        [Embed(source="/assets/img/mouse_mid.png")]
        private var logoClass:Class;        
        private var Logo:Bitmap;
        
        [Bindable]
        [Embed(source="/assets/img/preload_text.png")]
        private var TextClass:Class;        
        private var Text:Bitmap;
        
        [Bindable]
        [Embed(source="/assets/img/uzh_logo.png")]
        private var UzhLogoClass:Class;        
        private var UzhLogo:Bitmap;
        
        private var m_Ready:Boolean;
        private var m_Progress:Number;
        private var m_BitmapData:BitmapData;

        // Constant to change to fit your own layout
        private static var ProgressWidth:int = 150; // Progress bar width
        private static var ProgressHeight:int = 25; // Progress bar height
        private var PictureWidth:int = 55;  // Logo picture width
        private static var LeftMargin:int = 1;      // Left Margin
        private static var RightMargin:int = 2;     // Right Margin
        private static var Spacing:int = 5;        // Spacing between logo and progress bar
        private static var TopMargin:int = 1;       // Top Margin
        private static var BottomMargin:int = 1;    // Bottom Margin
        private var PictureHeight:int = 57; // Logo picture height
        
        private static var ProgressBarBackground:uint = 0x000000;
        private static var progressBarOuterBorder:uint = 0x000000;
        private static var ProgressBarColor:uint = 0xFFFFFF;
        private static var ProgressBarInnerColor:uint = 0xFFFFFF;
        
        public function CustomLoader(): void
        {
            super();
            m_Progress = 0;
            Logo = new logoClass as Bitmap;
            Text = new TextClass as Bitmap;
            UzhLogo = new UzhLogoClass as Bitmap;
            
            PictureHeight = Logo.height;
            PictureWidth = Logo.width;
            this.addEventListener(Event.RENDER, renderEventHandler);
            
        }
        
        private function renderEventHandler(event: Event): void
        {
            
        }
        public function refreshProgressBar(): void
        {            
            m_BitmapData = drawProgress(); // Create the bitmapdata object
            var encoder: PNGEncoder = new PNGEncoder();
            var byteArray: ByteArray = encoder.encode(m_BitmapData); // Encode the bitmapdata to a bytearray
            this.loadBytes(byteArray); // Draw the bitmap on the loader object
        }
                
        public function getWidth(): Number
        {
            return LeftMargin + PictureWidth + Spacing + ProgressWidth + RightMargin;
        }
        
        public function getHeight(): Number
        {
            return TopMargin + PictureHeight + BottomMargin + Text.height;
        }
        
        private function drawProgress(): BitmapData
        {
            // Create the bitmap class object
            var bitmapData:BitmapData = new BitmapData(getWidth(), getHeight(), true, 0x000000);         
            // Draw the Progress Bar
            var sprite:Sprite = new Sprite();
            var graph:Graphics = sprite.graphics;
            
            // draw background
            
            // Draw the progress bar background
			//graph.beginFill(ProgressBarBackground);
            graph.lineStyle(1, progressBarOuterBorder, 1, true);
            var containerWidth: Number = ProgressWidth;
            var px: int = getWidth() - RightMargin - ProgressWidth;
            var py: int = (getHeight() - Logo.height - Text.height) / 2;
            graph.drawRoundRect(px, py, containerWidth, ProgressHeight, 0);
            containerWidth -= 4;
            var progressWidth: Number = containerWidth * m_Progress / 100;
            //graph.beginFill(ProgressBarColor);
            //var gradMatrix:Matrix = new Matrix();
            //gradMatrix.rotate(90);
            graph.beginFill(0x000000);
            graph.drawRoundRect(px + 2, py + 2, progressWidth, ProgressHeight - 4, 6);
            graph.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xf92f10],[1,0.5],[127,255]);
            graph.lineStyle(1, ProgressBarInnerColor, 1, true);
            graph.drawRoundRect(px + 2, py + 2, progressWidth, ProgressHeight - 4, 6);
                        
            bitmapData.draw(sprite);
            
            //Draw the Logo
            bitmapData.draw(Logo.bitmapData, null, null, null, null, true);
            // draw the text
            var textMatr:Matrix = new Matrix(1,0,0,1,(PictureWidth + Spacing + 2 ),(ProgressHeight + 2));
            bitmapData.draw(Text.bitmapData,textMatr,null,null,null,true);
            
            // uzh
            var uzhMatr:Matrix = new Matrix(1,0,0,1,(PictureWidth + Spacing + ProgressWidth - UzhLogo.width),(ProgressHeight + 6));
            bitmapData.draw(UzhLogo.bitmapData,uzhMatr,null,null,null,true);
            
            return bitmapData;                    
        }
                
        public function set ready(value: Boolean): void
        {
            m_Ready = value;            
            this.visible = !value;            
        }
        
        public function get ready(): Boolean
        {
            return m_Ready;            
        }
        
        public function set progress(value: Number): void
        {
            m_Progress = value;            
        }
        public function get progress(): Number{
            return m_Progress;
        }        

	}
}