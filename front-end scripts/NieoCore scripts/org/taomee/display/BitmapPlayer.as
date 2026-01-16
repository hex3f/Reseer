package org.taomee.display
{
   import flash.display.Bitmap;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class BitmapPlayer extends Bitmap
   {
      
      private var _delay:uint = 40;
      
      private var _timeID:uint;
      
      private var _totalFrames:uint;
      
      private var _bitmapList:Array = [];
      
      private var _currentFrame:uint;
      
      private var _playing:Boolean;
      
      private var _repeatCount:uint;
      
      private var _currentCount:uint;
      
      public function BitmapPlayer(param1:uint = 40, param2:uint = 0)
      {
         super();
         this._delay = param1;
         this._repeatCount = param2;
      }
      
      public function stop() : void
      {
         clearInterval(this._timeID);
         this._playing = false;
      }
      
      public function get delay() : uint
      {
         return this._delay;
      }
      
      public function set delay(param1:uint) : void
      {
         this._delay = param1;
         clearInterval(this._timeID);
         if(this._totalFrames > 1)
         {
            this._timeID = setInterval(this.onEnter,this._delay);
         }
      }
      
      public function get totalFrames() : uint
      {
         return this._totalFrames;
      }
      
      public function clear() : void
      {
         this.stop();
         bitmapData = null;
         this._totalFrames = 0;
         this._currentFrame = 0;
         this._bitmapList = [];
         this._currentCount = 0;
      }
      
      public function gotoAndPlay(param1:uint) : void
      {
         if(param1 > this._totalFrames - 1)
         {
            param1 = uint(this._totalFrames - 1);
         }
         if(param1 < 0)
         {
            return;
         }
         this._currentFrame = param1;
         if(!this._playing)
         {
            this.play();
         }
      }
      
      public function set dataList(param1:Array) : void
      {
         if(param1 == null)
         {
            this.clear();
            return;
         }
         this.stop();
         this._bitmapList = param1;
         this._totalFrames = this._bitmapList.length;
         this._currentFrame = 0;
         this._currentCount = 0;
         bitmapData = this._bitmapList[this._currentFrame];
      }
      
      public function gotoAndStop(param1:uint) : void
      {
         if(param1 > this._totalFrames - 1)
         {
            param1 = uint(this._totalFrames - 1);
         }
         if(param1 < 0)
         {
            return;
         }
         this.stop();
         this._currentFrame = param1;
         bitmapData = this._bitmapList[this._currentFrame];
      }
      
      public function play() : void
      {
         this._playing = true;
         clearInterval(this._timeID);
         if(this._totalFrames > 1)
         {
            this._timeID = setInterval(this.onEnter,this._delay);
         }
         this.onEnter();
      }
      
      public function set repeatCount(param1:uint) : void
      {
         this._repeatCount = param1;
      }
      
      public function get playing() : Boolean
      {
         return this._playing;
      }
      
      public function get currentFrame() : uint
      {
         return this._currentFrame;
      }
      
      private function onEnter() : void
      {
         bitmapData = this._bitmapList[this._currentFrame];
         ++this._currentFrame;
         if(this._currentFrame == this._totalFrames)
         {
            this._currentFrame = 0;
            if(this._repeatCount != 0)
            {
               ++this._currentCount;
               if(this._currentCount == this._repeatCount)
               {
                  this.stop();
               }
            }
         }
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var gc:Boolean = param1;
         this.stop();
         if(gc)
         {
            this._bitmapList.forEach(function(param1:*, param2:int, param3:Array):void
            {
               if(param1)
               {
                  param1.dispose();
               }
            });
         }
         bitmapData = null;
         this._bitmapList = null;
      }
      
      public function get repeatCount() : uint
      {
         return this._repeatCount;
      }
   }
}

