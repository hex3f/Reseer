package com.robot.app.action
{
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.Direction;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class HandActionManager
   {
      
      private static var waitTimer:Timer;
      
      private static var overFunc:Function;
      
      private static var walkFunc:Function;
      
      public function HandActionManager()
      {
         super();
      }
      
      public static function onHeadAction(param1:uint, param2:Function = null, param3:uint = 10000, param4:Function = null, param5:Function = null, param6:Boolean = true) : void
      {
         overFunc = param4;
         walkFunc = param5;
         if(MainManager.actorInfo.clothIDs.indexOf(param1) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
         {
            if(param2 != null)
            {
               param2();
            }
            else
            {
               Alarm.show("你没有相应的工具噢,装备好了它再来吧!");
            }
            return;
         }
         if(!param6)
         {
            MainManager.actorModel.skeleton.getSkeletonMC().scaleX = -1;
         }
         if(MainManager.actorInfo.clothIDs.indexOf(param1) == -1)
         {
            MainManager.actorModel.specialAction(100717);
         }
         else
         {
            MainManager.actorModel.specialAction(param1);
         }
         var _loc7_:Sprite = MainManager.actorModel.sprite;
         _loc7_.parent.addChild(_loc7_);
         if(waitTimer != null)
         {
            waitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
            waitTimer = null;
         }
         waitTimer = new Timer(param3,1);
         waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
         waitTimer.start();
         MainManager.actorModel.sprite.addEventListener(RobotEvent.WALK_START,onWalk);
      }
      
      private static function onTimeOver(param1:TimerEvent) : void
      {
         waitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
         MainManager.actorModel.sprite.removeEventListener(RobotEvent.WALK_START,onWalk);
         MainManager.actorModel.stopSpecialAct();
         MainManager.actorModel.skeleton.getSkeletonMC().scaleX = 1;
         if(overFunc != null)
         {
            overFunc();
         }
      }
      
      private static function onWalk(param1:RobotEvent) : void
      {
         waitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeOver);
         MainManager.actorModel.sprite.removeEventListener(RobotEvent.WALK_START,onWalk);
         waitTimer.stop();
         MainManager.actorModel.stop();
         MainManager.actorModel.stopSpecialAct();
         MainManager.actorModel.direction = Direction.DOWN;
         MainManager.actorModel.skeleton.getSkeletonMC().scaleX = 1;
         if(walkFunc != null)
         {
            walkFunc();
         }
         else
         {
            Alarm.show("不能随便走动噢");
         }
      }
   }
}

