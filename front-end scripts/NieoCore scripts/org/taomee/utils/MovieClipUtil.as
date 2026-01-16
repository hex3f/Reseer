package org.taomee.utils
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MovieClipUtil
   {
      
      public function MovieClipUtil()
      {
         super();
      }
      
      public static function childPlay(param1:DisplayObjectContainer, param2:Object, param3:uint = 0) : void
      {
         var count:int = 0;
         var obj:DisplayObjectContainer = param1;
         var frame:Object = param2;
         var level:uint = param3;
         count = 0;
         count = 0;
         var num:int = obj.numChildren;
         if(num == 0)
         {
            return;
         }
         if(level >= num)
         {
            level = uint(num - 1);
         }
         obj.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            var _loc3_:MovieClip = obj.getChildAt(level) as MovieClip;
            if(Boolean(_loc3_))
            {
               obj.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               _loc3_.gotoAndPlay(frame);
            }
            else if(count > 2)
            {
               obj.removeEventListener(Event.ENTER_FRAME,arguments.callee);
            }
            ++count;
         });
      }
      
      public static function playEndAndRemove(param1:MovieClip) : void
      {
         var mc:MovieClip = param1;
         mc.addFrameScript(mc.totalFrames - 1,function():void
         {
            mc.addFrameScript(mc.totalFrames - 1,null);
            DisplayUtil.removeForParent(mc);
            mc = null;
         });
      }
      
      public static function childStop(param1:DisplayObjectContainer, param2:Object, param3:uint = 0) : void
      {
         var count:int = 0;
         var obj:DisplayObjectContainer = param1;
         var frame:Object = param2;
         var level:uint = param3;
         count = 0;
         count = 0;
         var num:int = obj.numChildren;
         if(num == 0)
         {
            return;
         }
         if(level >= num)
         {
            level = uint(num - 1);
         }
         obj.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            var _loc3_:MovieClip = obj.getChildAt(level) as MovieClip;
            if(Boolean(_loc3_))
            {
               obj.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               _loc3_.gotoAndStop(frame);
            }
            else if(count > 2)
            {
               obj.removeEventListener(Event.ENTER_FRAME,arguments.callee);
            }
            ++count;
         });
      }
   }
}

