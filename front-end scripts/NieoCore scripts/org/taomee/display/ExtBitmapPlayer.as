package org.taomee.display
{
   import flash.display.Bitmap;
   
   public class ExtBitmapPlayer extends Bitmap
   {
      
      private var _totalFrames:uint;
      
      private var _bitmapList:Array = [];
      
      private var _currentFrame:uint;
      
      public function ExtBitmapPlayer(param1:Array = null)
      {
         super();
         if(Boolean(param1))
         {
            this.dataList = param1;
         }
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var gc:Boolean = param1;
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
      
      public function set currentFrame(param1:uint) : void
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
         bitmapData = this._bitmapList[this._currentFrame];
      }
      
      public function get totalFrames() : uint
      {
         return this._totalFrames;
      }
      
      public function clear() : void
      {
         bitmapData = null;
         this._totalFrames = 0;
         this._currentFrame = 0;
         this._bitmapList = [];
      }
      
      public function set dataList(param1:Array) : void
      {
         if(param1 == null)
         {
            this.clear();
            return;
         }
         this._bitmapList = param1;
         this._totalFrames = this._bitmapList.length;
         this._currentFrame = 0;
         bitmapData = this._bitmapList[this._currentFrame];
      }
      
      public function get currentFrame() : uint
      {
         return this._currentFrame;
      }
      
      public function nextFrame() : void
      {
         if(this._totalFrames > 1)
         {
            bitmapData = this._bitmapList[this._currentFrame];
            ++this._currentFrame;
            if(this._currentFrame == this._totalFrames)
            {
               this._currentFrame = 0;
            }
         }
      }
   }
}

