package com.robot.app.task.taskscollection
{
   import com.robot.core.manager.LevelManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class Task142
   {
      
      public function Task142()
      {
         super();
      }
      
      public static function getMc(param1:MovieClip, param2:uint, param3:String = "", param4:Function = null) : void
      {
         var child:MovieClip = null;
         var parentMC:MovieClip = null;
         var name:String = null;
         var func:Function = null;
         child = null;
         parentMC = param1;
         var frame:uint = param2;
         name = param3;
         func = param4;
         parentMC.gotoAndStop(frame);
         if(name == "")
         {
            child = parentMC.getChildAt(0) as MovieClip;
         }
         else
         {
            child = parentMC.getChildByName(name) as MovieClip;
         }
         if(Boolean(child))
         {
            if(func != null)
            {
               func(child);
            }
         }
         else
         {
            parentMC.addEventListener(Event.ENTER_FRAME,function():void
            {
               if(name == "")
               {
                  child = parentMC.getChildAt(0) as MovieClip;
               }
               else
               {
                  child = parentMC.getChildByName(name) as MovieClip;
               }
               if(Boolean(child))
               {
                  parentMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  if(func != null)
                  {
                     func(child);
                  }
               }
            });
         }
      }
      
      public static function playMC(param1:MovieClip, param2:Function = null) : void
      {
         var mc:MovieClip = null;
         var func:Function = null;
         mc = param1;
         func = param2;
         LevelManager.closeMouseEvent();
         mc.gotoAndPlay(1);
         mc.addEventListener(Event.ENTER_FRAME,function():void
         {
            if(mc.currentFrame == mc.totalFrames)
            {
               if(func != null)
               {
                  func();
               }
               mc.stop();
               mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               LevelManager.openMouseEvent();
            }
         });
      }
   }
}

