package com.robot.app.ogre
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.task.control.TaskController_81;
   import com.robot.core.config.xml.OgreXMLInfo;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.OgreModel;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.geom.Point;
   import org.taomee.ds.HashMap;
   
   public class OgreController
   {
      
      private static var _list:HashMap;
      
      private static var _pList:Array;
      
      private static var _currObj:OgreModel;
      
      private static var D_MAX:int = 40;
      
      private static var _isSwitching:Boolean = false;
      
      private static var b:Boolean = false;
      
      public function OgreController()
      {
         super();
      }
      
      public static function add(param1:int, param2:uint) : void
      {
         var _loc3_:OgreModel = null;
         if(_isSwitching)
         {
            return;
         }
         if(_list == null)
         {
            _pList = OgreXMLInfo.getOgreList(MainManager.actorInfo.mapID);
            _list = new HashMap();
            MapManager.addEventListener(MapEvent.MAP_SWITCH_OPEN,onMapSwitchOpen);
            MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchComplete);
            MapManager.addEventListener(MapEvent.MAP_DESTROY,onMapSwitchOpen);
            MapManager.addEventListener(MapEvent.MAP_MOUSE_DOWN,onMapDown);
         }
         if(_list.length > 3)
         {
            return;
         }
         if(_list.containsKey(param1))
         {
            return;
         }
         if(Boolean(_pList))
         {
            _loc3_ = _list.getValue(param1) as OgreModel;
            if(Boolean(_loc3_))
            {
               _loc3_.removeEventListener(RobotEvent.OGRE_CLICK,onClick);
               _loc3_.destroy();
               _loc3_ = null;
            }
            _loc3_ = new OgreModel(param1);
            if(MapManager.currentMap.id == 58)
            {
               if(FightInviteManager.isKillBigPetB1 == false)
               {
                  if(param2 == 228)
                  {
                     _loc3_.destroy();
                     _loc3_ = null;
                     return;
                  }
               }
            }
            if(MapManager.currentMap.id == 62)
            {
               if(FightInviteManager.isKillBigPetB0 == false)
               {
                  if(param2 == 240)
                  {
                     _loc3_.destroy();
                     _loc3_ = null;
                     return;
                  }
               }
            }
            if(MapManager.currentMap.id == 61)
            {
               if(FightInviteManager.isKillBigPetB == false)
               {
                  if(param2 == 237)
                  {
                     _loc3_.destroy();
                     _loc3_ = null;
                     return;
                  }
               }
            }
            if(MapManager.currentMap.id == 57)
            {
               if(TasksManager.getTaskStatus(TaskController_81.TASK_ID) != TasksManager.COMPLETE)
               {
                  if(param2 == 235)
                  {
                     _loc3_.destroy();
                     _loc3_ = null;
                     return;
                  }
               }
            }
            if(MapManager.currentMap.id == 27)
            {
               if(TasksManager.getTaskStatus(93) != TasksManager.COMPLETE)
               {
                  if(param2 == 249 || param2 == 250)
                  {
                     _loc3_.destroy();
                     _loc3_ = null;
                     return;
                  }
               }
            }
            if(MapManager.currentMap.id == 325)
            {
               if(TasksManager.getTaskStatus(97) != TasksManager.COMPLETE)
               {
                  if(param2 == 265 || param2 == 266)
                  {
                     _loc3_.destroy();
                     _loc3_ = null;
                     return;
                  }
               }
            }
            _loc3_.addEventListener(RobotEvent.OGRE_CLICK,onClick);
            _list.add(param1,_loc3_);
            _loc3_.show(param2,_pList[param1]);
         }
      }
      
      public static function remove(param1:int) : void
      {
         if(_list == null)
         {
            return;
         }
         var _loc2_:OgreModel = _list.remove(param1) as OgreModel;
         if(Boolean(_loc2_))
         {
            _loc2_.removeEventListener(RobotEvent.OGRE_CLICK,onClick);
            _loc2_.destroy();
            _loc2_ = null;
         }
      }
      
      public static function destroy() : void
      {
         var _loc1_:OgreModel = null;
         MapManager.removeEventListener(MapEvent.MAP_MOUSE_DOWN,onMapDown);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,onEnter);
         var _loc2_:Array = _list.getValues();
         for each(_loc1_ in _loc2_)
         {
            _loc1_.removeEventListener(RobotEvent.OGRE_CLICK,onClick);
            _loc1_.destroy();
            _loc1_ = null;
         }
         _list = null;
         _pList = null;
      }
      
      private static function startFight(param1:OgreModel) : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:PetInfo = null;
         var _loc4_:* = 0;
         var _loc5_:PetSkillInfo = null;
         if(Point.distance(param1.pos,MainManager.actorModel.pos) < D_MAX)
         {
            if(PetManager.length == 0)
            {
               Alarm.show("你的背包里还没有一只赛尔精灵哦！");
               return true;
            }
            _loc2_ = PetManager.infos;
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = 0;
               for each(_loc5_ in _loc3_.skillArray)
               {
                  _loc4_ += _loc5_.pp;
               }
               if(_loc3_.hp > 0 && _loc4_ > 0)
               {
                  MainManager.actorModel.stop();
                  LevelManager.closeMouseEvent();
                  PetFightModel.defaultNpcID = param1.id;
                  FightInviteManager.fightWithNpc(param1.index);
                  return true;
               }
            }
            if(!b)
            {
               b = true;
               Alarm.show("你的赛尔精灵没有体力或不能使用技能了，不能出战哦！");
            }
         }
         return false;
      }
      
      private static function onClick(param1:RobotEvent) : void
      {
         b = false;
         _currObj = param1.currentTarget as OgreModel;
         if(startFight(_currObj))
         {
            _currObj = null;
            return;
         }
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,onEnter);
         MainManager.actorModel.walkAction(_currObj.pos);
      }
      
      private static function onEnter(param1:Event) : void
      {
         if(Boolean(_currObj))
         {
            if(startFight(_currObj))
            {
               _currObj = null;
               onMapDown(null);
               return;
            }
         }
      }
      
      private static function onMapDown(param1:MapEvent) : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,onEnter);
      }
      
      private static function onMapSwitchOpen(param1:MapEvent) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_OPEN,onMapSwitchOpen);
         MapManager.removeEventListener(MapEvent.MAP_DESTROY,onMapSwitchOpen);
         _isSwitching = true;
         destroy();
      }
      
      private static function onMapSwitchComplete(param1:MapEvent) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchComplete);
         _isSwitching = false;
      }
      
      public static function getOgreList() : Array
      {
         if(!_list)
         {
            return [];
         }
         return _list.getValues();
      }
      
      public static function set isShow(param1:Boolean) : void
      {
         var _loc2_:OgreModel = null;
         if(param1 == false)
         {
            OgreModel.isShow = false;
            for each(_loc2_ in getOgreList())
            {
               _loc2_.alpha = 0;
            }
         }
         else
         {
            OgreModel.isShow = true;
            for each(_loc2_ in getOgreList())
            {
               _loc2_.show(_loc2_.id,_loc2_.pos);
            }
         }
      }
   }
}

