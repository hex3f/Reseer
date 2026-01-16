package com.robot.core.teamPK.shotActive
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.config.xml.ShotDisXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.event.UserEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.SpriteModel;
   import com.robot.core.mode.additiveInfo.TeamPkPlayerSideInfo;
   import com.robot.core.teamPK.TeamPKManager;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.EventManager;
   
   public class AutoShotManager
   {
      
      private static var target:SpriteModel;
      
      private static var autoTargetByDis:SpriteModel;
      
      private static var shotDis:uint;
      
      private static var autoTimer:Timer;
      
      private static var isBreakAuto:Boolean;
      
      private static var walkByAuto:Boolean;
      
      private static var isSetup:Boolean = false;
      
      public function AutoShotManager()
      {
         super();
      }
      
      public static function breakAuto() : void
      {
         autoTimer.stop();
      }
      
      public static function openAuto() : void
      {
         autoTimer.start();
      }
      
      public static function setup() : void
      {
         if(isSetup)
         {
            return;
         }
         isSetup = true;
         shotDis = ShotDisXMLInfo.getClothDistance(MainManager.actorInfo.clothIDs);
         MainManager.actorModel.addEventListener(RobotEvent.WALK_START,onWalkStart);
         MainManager.actorModel.addEventListener(RobotEvent.WALK_END,onWalkEnd);
         UserManager.addEventListener(UserEvent.REMOVED_FROM_MAP,onRmoveFromMap);
         EventManager.addEventListener(PKArmModel.BE_DESTROY,onArmModeDestroy);
         autoTimer = new Timer(3000);
         autoTimer.addEventListener(TimerEvent.TIMER,autoHandler);
         autoTimer.start();
      }
      
      public static function destroy() : void
      {
         isSetup = false;
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_START,onWalkStart);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_END,onWalkEnd);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,onWalkEnterFrame);
         UserManager.removeEventListener(UserEvent.REMOVED_FROM_MAP,onRmoveFromMap);
         EventManager.removeEventListener(PKArmModel.BE_DESTROY,onArmModeDestroy);
         autoTimer.stop();
         autoTimer.removeEventListener(TimerEvent.TIMER,autoHandler);
         autoTimer = null;
         target = null;
         autoTargetByDis = null;
      }
      
      public static function shot(param1:SpriteModel, param2:Boolean = true, param3:Boolean = true) : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,onWalkEnterFrame);
         isBreakAuto = param2;
         if(isBreakAuto)
         {
            autoTimer.stop();
         }
         if(!param1)
         {
            return;
         }
         if(param3)
         {
            autoTargetByDis = null;
            target = param1;
         }
         var _loc4_:Point = param1.localToGlobal(new Point());
         var _loc5_:Point = MainManager.actorModel.localToGlobal(new Point());
         if(Point.distance(_loc5_,_loc4_) > shotDis)
         {
            walkByAuto = true;
            MainManager.actorModel.walkAction(param1.pos);
            MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,onWalkEnterFrame);
         }
         else
         {
            AimatController.setClothType(MainManager.actorInfo.clothIDs);
            MainManager.actorModel.aimatAction(0,AimatController.type,param1.pos);
         }
      }
      
      private static function onWalkStart(param1:RobotEvent) : void
      {
         if(walkByAuto)
         {
            walkByAuto = false;
         }
         else
         {
            isBreakAuto = true;
            target = null;
            autoTimer.stop();
         }
      }
      
      private static function onWalkEnd(param1:RobotEvent) : void
      {
         if(isBreakAuto)
         {
            isBreakAuto = false;
            autoTimer.stop();
            autoTimer.start();
         }
      }
      
      private static function onWalkEnterFrame(param1:RobotEvent) : void
      {
         if(!target)
         {
            return;
         }
         if(Point.distance(MainManager.actorModel.pos,target.pos) <= shotDis)
         {
            walkByAuto = true;
            MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,onWalkEnterFrame);
            MainManager.actorModel.walkAction(MainManager.actorModel.pos);
            AimatController.setClothType(MainManager.actorInfo.clothIDs);
            MainManager.actorModel.aimatAction(0,AimatController.type,target.pos);
            autoTimer.start();
         }
      }
      
      private static function onRmoveFromMap(param1:UserEvent) : void
      {
         if(Boolean(target))
         {
            if(target is BasePeoleModel)
            {
               if(param1.userInfo.userID == BasePeoleModel(target).info.userID)
               {
                  target = null;
               }
            }
         }
         if(Boolean(autoTargetByDis))
         {
            if(autoTargetByDis is BasePeoleModel)
            {
               if(param1.userInfo.userID == BasePeoleModel(autoTargetByDis).info.userID)
               {
                  autoTargetByDis = null;
               }
            }
         }
      }
      
      private static function onArmModeDestroy(param1:DynamicEvent) : void
      {
         var _loc2_:PKArmModel = param1.paramObject as PKArmModel;
         if(target == _loc2_)
         {
            target = null;
         }
         if(autoTargetByDis == _loc2_)
         {
            autoTargetByDis = null;
         }
         TeamPKManager.homeBuildingMap.remove(_loc2_.info.buyTime);
         TeamPKManager.awayBuildingMap.remove(_loc2_.info.buyTime);
      }
      
      private static function autoHandler(param1:TimerEvent) : void
      {
         var event:TimerEvent = param1;
         var oldDis:Number = NaN;
         var i:SpriteModel = null;
         var peopleList:Array = null;
         var buildingList:Array = null;
         var array:Array = null;
         var p:Point = null;
         var dis:Number = NaN;
         var myP:Point = MainManager.actorModel.localToGlobal(new Point());
         if(Boolean(autoTargetByDis))
         {
            if(Point.distance(myP,autoTargetByDis.localToGlobal(new Point())) <= shotDis)
            {
               shot(autoTargetByDis,false,false);
               return;
            }
         }
         if(!target)
         {
            autoTargetByDis = null;
            oldDis = 0;
            peopleList = UserManager.getUserModelList().filter(function(param1:BasePeoleModel, param2:int, param3:Array):Boolean
            {
               if((param1.additiveInfo as TeamPkPlayerSideInfo).side != (MainManager.actorModel.additiveInfo as TeamPkPlayerSideInfo).side)
               {
                  return true;
               }
               return false;
            });
            if(TeamPKManager.TEAM == TeamPKManager.AWAY)
            {
               buildingList = TeamPKManager.homeBuildingMap.getValues();
            }
            else
            {
               buildingList = TeamPKManager.awayBuildingMap.getValues();
            }
            array = peopleList.concat(buildingList);
            for each(i in array)
            {
               p = i.localToGlobal(new Point());
               dis = Point.distance(myP,p);
               if(dis <= shotDis)
               {
                  if(oldDis == 0)
                  {
                     autoTargetByDis = i;
                     oldDis = dis;
                  }
                  else if(Math.min(oldDis,dis) == dis)
                  {
                     autoTargetByDis = i;
                     oldDis = dis;
                  }
               }
            }
            shot(autoTargetByDis,false,false);
         }
         else
         {
            shot(target,false);
         }
      }
   }
}

