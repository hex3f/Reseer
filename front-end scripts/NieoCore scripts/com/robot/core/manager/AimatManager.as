package com.robot.core.manager
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import flash.display.DisplayObject;
   
   public class AimatManager
   {
      
      public function AimatManager()
      {
         super();
      }
      
      public static function useHeadShoot(param1:uint, param2:Function = null, param3:Boolean = false, param4:Array = null, param5:Function = null, param6:Function = null) : void
      {
         var headItemID:uint = param1;
         var func:Function = param2;
         var isHit:Boolean = param3;
         var disArr:Array = param4;
         var hitFun:Function = param5;
         var noHitFun:Function = param6;
         AimatController.addEventListener(AimatEvent.PLAY_END,function(param1:AimatEvent):void
         {
            var _loc3_:DisplayObject = null;
            AimatController.removeEventListener(AimatEvent.PLAY_END,arguments.callee);
            var _loc4_:AimatInfo = param1.info;
            if(_loc4_.userID != MainManager.actorID)
            {
               return;
            }
            if(isHit)
            {
               if(Boolean(disArr))
               {
                  for each(_loc3_ in disArr)
                  {
                     if(Boolean(_loc3_))
                     {
                        if(_loc3_.hitTestPoint(_loc4_.endPos.x,_loc4_.endPos.y))
                        {
                           if(hitFun != null)
                           {
                              hitFun();
                              return;
                           }
                        }
                     }
                  }
                  if(noHitFun != null)
                  {
                     noHitFun();
                  }
               }
            }
            else if(func != null)
            {
               func();
            }
         });
      }
   }
}

