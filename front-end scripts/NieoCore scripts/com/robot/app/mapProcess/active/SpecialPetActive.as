package com.robot.app.mapProcess.active
{
   import com.robot.app.mapProcess.active.randomPet.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.event.*;
   import com.robot.core.info.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.fightInfo.attack.*;
   import com.robot.core.info.task.novice.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.npc.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import org.taomee.ds.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class SpecialPetActive
   {
      
      private static var pet:IRandomPet;
      
      private static var _petMc:MovieClip;
      
      private static var point:Point;
      
      private static var map:HashMap = new HashMap();
      
      private static var strMap:HashMap = new HashMap();
      
      private static var classMap:HashMap = new HashMap();
      
      private static var date:Date = null;
      
      public static var _gaiya:Boolean = false;
      
      private static var ruleHashMap:HashMap = new HashMap();
      
      setup();
      
      public function SpecialPetActive()
      {
         super();
      }
      
      private static function setup() : void
      {
         map.add(15,new Point(808,338));
         map.add(105,new Point(126,217));
         map.add(54,new Point(297,157));
         ruleHashMap.add(0,"以致命一击为终结技");
         ruleHashMap.add(1,"在2回合之内");
         ruleHashMap.add(2,"以致命一击为终结技");
         ruleHashMap.add(3,"承受住我10次攻击后再");
         ruleHashMap.add(4,"以致命一击为终结技");
         ruleHashMap.add(5,"在2回合之内");
         ruleHashMap.add(6,"承受住我10次攻击后再");
      }
      
      private static function onMapSwitch(param1:MapEvent) : void
      {
         hide();
      }
      
      public static function getStr(param1:uint) : String
      {
         return strMap.getValue(param1);
      }
      
      public static function getMC(param1:uint) : MovieClip
      {
         var _loc2_:Class = classMap.getValue(param1) as Class;
         return new _loc2_() as MovieClip;
      }
      
      public static function show(param1:uint) : void
      {
         if(param1 == 0)
         {
            return;
         }
         point = map.getValue(MainManager.actorInfo.mapID);
         if(Boolean(point))
         {
            _gaiya = true;
            ResourceManager.getResource(ClientConfig.getPetSwfPath(param1),onLoadPet,"pet");
         }
      }
      
      private static function onLoadPet(param1:DisplayObject) : void
      {
         var o:DisplayObject = param1;
         _petMc = o as MovieClip;
         if(Boolean(MapManager.currentMap))
         {
            MapManager.currentMap.depthLevel.addChild(_petMc);
         }
         else
         {
            MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,function(param1:MapEvent):void
            {
               MapManager.removeEventListener(MapEvent.MAP_SWITCH_COMPLETE,arguments.callee);
               var _loc3_:Point = map.getValue(MainManager.actorInfo.mapID);
               if(Boolean(_loc3_))
               {
                  MapManager.currentMap.depthLevel.addChild(_petMc);
                  _petMc.x = _loc3_.x;
                  _petMc.y = _loc3_.y;
               }
            });
         }
         _petMc.x = point.x;
         _petMc.y = point.y;
         _petMc.buttonMode = true;
         _petMc.addEventListener(MouseEvent.CLICK,onClick);
         (_petMc.getChildAt(0) as MovieClip).gotoAndStop(1);
      }
      
      private static function onClick(param1:MouseEvent) : void
      {
         if(Boolean(date))
         {
            talkWithGaiYa();
         }
         else
         {
            SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,onGetTime);
            SocketConnection.send(CommandID.SYSTEM_TIME);
         }
      }
      
      private static function onGetTime(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,onGetTime);
         date = (param1.data as SystemTimeInfo).date;
         talkWithGaiYa();
      }
      
      private static function talkWithGaiYa() : void
      {
         var str:String = null;
         try
         {
            str = "我的目标是成为精灵战斗大师，我对战斗有着独特的见解，只有力量与智慧都达到一定的境界的对手才会得到我的认同。如果你能以0xff00001对1的形式并" + ruleHashMap.getValue(date.day) + "战胜我0xffffff，我就做你的伙伴。";
         }
         catch(error:Error)
         {
            str = "我的目标是成为精灵战斗大师，我对战斗有着独特的见解，只有力量与智慧都达到一定的境界的对手才会得到我的认同。如果你能以0xff00001对1的形式并以今天的规则战胜我0xffffff，我就做你的伙伴。";
         }
         NpcDialog.show(NPC.GAIYA,[str],["我接受，一定要让你成为我的伙伴。","等我把精灵训练的更强后再来找你挑战。"],[function():void
         {
            fightWithGaiYa();
         }]);
      }
      
      public static function fightWithGaiYa() : void
      {
         PetFightModel.mode = PetFightModel.SINGLE_MODE;
         PetFightModel.status = PetFightModel.FIGHT_WITH_NPC;
         PetFightModel.enemyName = "盖亚";
         SocketConnection.addCmdListener(CommandID.COMPLETE_TASK,getGaiYa);
         SocketConnection.addCmdListener(CommandID.SPRINT_GIFT_NOTICE,onFightLose);
         EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,onFightClose);
         SocketConnection.send(CommandID.FIGHT_SPECIAL_PET);
      }
      
      private static function onFightClose(param1:PetFightEvent) : void
      {
         var info:FightOverInfo = null;
         var evt:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,onFightClose);
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         info = evt.dataObj["data"] as FightOverInfo;
         if(info.winnerID != MainManager.actorID)
         {
            NpcDialog.show(NPC.GAIYA,["你还需要多多修炼哦，我也再去训练去了，我们下次再见吧。"],["下次我一定要让你成为我的伙伴！"],[function():void
            {
               SocketConnection.removeCmdListener(CommandID.COMPLETE_TASK,getGaiYa);
               SocketConnection.removeCmdListener(CommandID.SPRINT_GIFT_NOTICE,onFightLose);
            }]);
         }
      }
      
      private static function getGaiYa(param1:SocketEvent) : void
      {
         var info:NoviceFinishInfo = null;
         var o:Object = null;
         var evt:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.COMPLETE_TASK,getGaiYa);
         SocketConnection.removeCmdListener(CommandID.SPRINT_GIFT_NOTICE,onFightLose);
         info = evt.data as NoviceFinishInfo;
         if(info.taskID == 99)
         {
            for each(o in info.monBallList)
            {
               if(o["itemID"] == 400126)
               {
                  EventManager.addEventListener(PetFightEvent.ALARM_CLICK,function(param1:PetFightEvent):void
                  {
                     var evt:PetFightEvent = param1;
                     EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,arguments.callee);
                     NpcDialog.show(NPC.GAIYA,["你果然是文武双全、机智英勇的好对手，我履行承诺，做你的伙伴吧。"],["我们一起加油，成为最强吧！"],[function():void
                     {
                        ItemInBagAlert.show(400126,"1个" + TextFormatUtil.getRedTxt("盖亚的精元") + "已经放入你的储存箱中！");
                     }]);
                  });
                  break;
               }
            }
         }
      }
      
      private static function onFightLose(param1:SocketEvent) : void
      {
         var evt:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.COMPLETE_TASK,getGaiYa);
         SocketConnection.removeCmdListener(CommandID.SPRINT_GIFT_NOTICE,onFightLose);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,function(param1:PetFightEvent):void
         {
            EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,arguments.callee);
            NpcDialog.show(NPC.GAIYA,["虽然你赢了，但是你没有按照规则战胜我，我们下次再见吧。"],["下次我一定要让你成为我的伙伴！"]);
         });
      }
      
      public static function hide() : void
      {
         if(Boolean(_petMc))
         {
            _petMc.removeEventListener(MouseEvent.CLICK,onClick);
            DisplayUtil.removeForParent(_petMc);
            _petMc = null;
            _gaiya = false;
         }
      }
      
      private static function getRandomPet() : IRandomPet
      {
         var _loc1_:IRandomPet = null;
         var _loc2_:uint = Math.floor(Math.random() * 3);
         if(_loc2_ == 0)
         {
            _loc1_ = new NormalPet();
         }
         else if(_loc2_ == 1)
         {
            _loc1_ = new RunPet();
         }
         else if(_loc2_ == 2)
         {
            _loc1_ = new PretendPet();
         }
         return _loc1_;
      }
   }
}

