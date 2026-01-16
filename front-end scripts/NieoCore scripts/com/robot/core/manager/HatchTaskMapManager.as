package com.robot.core.manager
{
   import com.robot.core.config.xml.HatchTaskXMLInfo;
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.HatchTask.HatchTaskInfo;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   import org.taomee.ds.HashMap;
   
   public class HatchTaskMapManager
   {
      
      private static var mapItemHash:HashMap = new HashMap();
      
      private static var soulBeadStatusMap:HashMap = new HashMap();
      
      getMapItems();
      
      public function HatchTaskMapManager()
      {
         super();
      }
      
      public static function setup() : void
      {
         setTimeout(function():void
         {
            HatchTaskManager.getTaskStatusList(function(param1:HashMap):void
            {
               soulBeadStatusMap = param1;
               cutIsTaskMap();
            });
         },1000);
      }
      
      public static function getSoulBeadStatusMap(param1:HashMap) : void
      {
         soulBeadStatusMap = param1;
      }
      
      public static function mapSoulBeadTaskDo(param1:HatchTaskInfo, param2:uint) : void
      {
         var _loc3_:String = null;
         var _loc4_:MovieClip = null;
         if(Boolean(param1))
         {
            if(!param1.statusList[param2])
            {
               _loc3_ = HatchTaskXMLInfo.getProMCName(param1.itemID,param2);
               _loc4_ = MapManager.currentMap.controlLevel[_loc3_] as MovieClip;
               if(Boolean(_loc4_))
               {
                  _loc4_.buttonMode = true;
                  _loc4_.addEventListener(MouseEvent.CLICK,finishHatchTask(param1.obtainTime,param1.itemID,param2));
               }
            }
         }
      }
      
      private static function getMapItems() : void
      {
         var _loc1_:HatchTaskInfo = null;
         var _loc2_:* = 0;
         var _loc3_:Array = null;
         var _loc4_:Array = soulBeadStatusMap.getValues();
         for each(_loc1_ in _loc4_)
         {
            _loc2_ = _loc1_.itemID;
            _loc3_ = HatchTaskXMLInfo.getTaskMapList(_loc2_);
            mapItemHash.add(_loc2_,_loc3_);
         }
      }
      
      public static function cutIsTaskMap() : void
      {
         MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,function(param1:MapEvent):void
         {
            var _loc2_:Number = 0;
            var _loc3_:HatchTaskInfo = null;
            var _loc4_:Array = null;
            var _loc5_:Number = 0;
            var _loc6_:uint = param1.mapModel.id;
            var _loc7_:Array = HatchTaskXMLInfo.getMapSoulBeadList(_loc6_);
            if(_loc7_.length > 0)
            {
               for each(_loc2_ in _loc7_)
               {
                  for each(_loc3_ in soulBeadStatusMap.getValues())
                  {
                     if(_loc3_.itemID == _loc2_)
                     {
                        _loc4_ = HatchTaskXMLInfo.getMapPro(_loc3_.itemID,_loc6_);
                        for each(_loc5_ in _loc4_)
                        {
                           if(!HatchTaskManager.getTaskProStatus(_loc3_.obtainTime,_loc5_))
                           {
                              mapSoulBeadTaskDo(_loc3_,_loc5_);
                           }
                        }
                     }
                  }
               }
            }
         });
      }
      
      private static function finishHatchTask(param1:uint, param2:uint, param3:uint) : Function
      {
         var obtainTime:uint = param1;
         var id:uint = param2;
         var pro:uint = param3;
         var func:Function = function(param1:MouseEvent):void
         {
            var mc:MovieClip = null;
            var playMC:MovieClip = null;
            var evt:MouseEvent = param1;
            mc = null;
            playMC = null;
            mc = evt.currentTarget as MovieClip;
            playMC = mc["mc"];
            if(playMC == null)
            {
               mc.buttonMode = false;
               mc.mouseEnabled = false;
               mc.mouseChildren = false;
               mc.removeEventListener(MouseEvent.CLICK,finishHatchTask);
            }
            playMC.gotoAndPlay(2);
            playMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               var evt:Event = param1;
               if(playMC.currentFrame == playMC.totalFrames)
               {
                  playMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  HatchTaskManager.complete(obtainTime,id,pro,function(param1:Boolean):void
                  {
                     var _loc2_:String = null;
                     if(param1)
                     {
                        Alarm.show("元神珠已经吸收了足够的精华能量，现在可以放入元神转化仪中转化了。");
                     }
                     else
                     {
                        _loc2_ = HatchTaskXMLInfo.getProDes(id,pro);
                        Alarm.show(_loc2_);
                     }
                  });
                  playMC.gotoAndStop(1);
                  mc.buttonMode = false;
                  mc.mouseEnabled = false;
                  mc.mouseChildren = false;
                  mc.removeEventListener(MouseEvent.CLICK,finishHatchTask);
               }
            });
         };
         return func;
      }
   }
}

