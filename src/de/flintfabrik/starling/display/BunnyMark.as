/**
 *	Copyright (c) 2013 Michael Trenkler
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

 package de.flintfabrik.starling.display 
{
	import de.flintfabrik.starling.display.BunnyMark.Bunny;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/** A Starling adaption of Iain Lobb's BunnyMark for quick performance testing.
	 *  @author Michael Trenkler
	 */
	public class BunnyMark extends Sprite
	{
		[Embed(source = "BunnyMark/wabbit_alpha.png",mimeType="application/octet-stream")]
		private var Wabbit:Class;
		
		private var mBitmap:Bitmap = new Wabbit();
		private var mCount:int = 0;
		private var mTexture:Texture;
		private var mBunnies:Vector.<Bunny> = new Vector.<Bunny>;
		private var mBunny:Bunny;
		private var mIndex:int;
		private var mRectangle:Rectangle;
		private var mMinX:Number = 0;
		private var mMaxX:Number = 0;
		private var mMinY:Number = 0;
		private var mMaxY:Number = 0;
		private var mGravity:Number = 0.5;
		
		/**
		 * Creates a BunnyMark with a certain number of Wabbits.
		 * 
		 * @param count
		 * The number of wabbits.
		 * @param rect
		 * You can define a rectangle for the borders of the BunnyMark. If you don't specify the rectangle the complete stage will be used.
		 */
		public function BunnyMark(count:int = 100, rect:Rectangle=null) 
		{
			mCount = count;
			if (rect) this.mRectangle = rect;
			mTexture = Texture.fromBitmap(mBitmap);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addBunny():void 
		{
			mBunny = new Bunny(mTexture);
			mBunny.speedX = Math.random() * 5;
			mBunny.speedY = Math.random() * 5 - 2.5;
			mBunny.scaleX = mBunny.scaleY = Math.random() + 0.3; 
			mBunny.rotation = Math.random() * 30 - 15;
			addChild(mBunny);
			mBunnies.push(mBunny);
		}
		
		private function addedToStageHandler(e:Event=null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			if (mRectangle) {
				mMinX = mRectangle.x;
				mMinY = mRectangle.y;
				mMaxX = mRectangle.x + mRectangle.width - mBitmap.width;
				mMaxY = mRectangle.y + mRectangle.height - mBitmap.height;
			}else{
				mMaxX = stage.stageWidth - mBitmap.width;
				mMaxY = stage.stageHeight - mBitmap.height;
			}
			count = mCount;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		override public function dispose():void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			while (count) removeBunny();
			mTexture.dispose();
			mBitmap.bitmapData.dispose();
			mBitmap = null;
			super.dispose();
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			loop();
		}
		
		/**
		 * The BunnyMark loop. Processes all Wabbits one frame further.
		 * @param	e
		 * @see start
		 * @see stop
		 */
		public function loop():void {
			mCount = mBunnies.length;
			for (mIndex = 0; mIndex < mCount; ++mIndex) {
				mBunny = mBunnies[mIndex];
				mBunny.x += mBunny.speedX;
				mBunny.y += mBunny.speedY;
				mBunny.speedY += mGravity;
				
				//b.alpha = 0.3 + 0.7 * b.y / maxY; 
				
				if (mBunny.x > mMaxX)
				{
					mBunny.speedX *= -1;
					mBunny.x = mMaxX;
				}
				else if (mBunny.x < mMinX)
				{
					mBunny.speedX *= -1;
					mBunny.x = mMinX;
				}
				if (mBunny.y > mMaxY)
				{
					mBunny.speedY *= -0.8;
					mBunny.y = mMaxY;
					if (Math.random() > 0.5) mBunny.speedY -= 3 + Math.random() * 4;
				} 
				else if (mBunny.y < mMinY)
				{
					mBunny.speedY = 0;
					mBunny.y = mMinY;
				}			
			}
		}
		
		private function removeBunny():void 
		{
			if (mBunnies.length > 0){
				mBunny = mBunnies.pop();
				if (mBunny) {
					mBunny.parent.removeChild(mBunny);
					mBunny.dispose();
				}
			}
		}
		
		/**
		 * Starts the BunnyMark.
		 */
		public function start():void {
			if (stage) {
				addedToStageHandler();
			}else {
				trace("Couldn't start. stage=" + this.stage);
			}
		}
		/**
		 * Stops the BunnyMark.
		 */
		public function stop():void {
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Number of Wabbits.
		 */
		public function get count():int {
			return mBunnies.length;
		}
		public function set count(val:int):void {
			val = Math.max(0, val);
			if (!stage) {
				mCount = val;
				return;
			}
			while (count < val)
				addBunny();
			while (count > val)
				removeBunny();
		}
	}

}