package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.task.taskscollection.Task142;
   import com.robot.app.task.tc.TaskClass_145;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.CommandID;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_401 extends BaseMapProcess
   {
      
      public static var xuanWuStatus:int;
      
      private var boss:MovieClip;
      
      private var petArr:Array;
      
      private var bossIn:MovieClip;
      
      private var shuanDian:MovieClip;
      
      private var index:int;
      
      private var petInArr:Array;
      
      private var timer:Timer;
      
      public function MapProcess_401()
      {
         super();
      }
      
      private static function stopMC(param1:DisplayObjectContainer) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Number = 0;
         var _loc4_:MovieClip = param1 as MovieClip;
         if(Boolean(_loc4_))
         {
            _loc4_.stop();
            _loc2_ = uint(_loc4_.numChildren);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               stopMC(_loc4_.getChildAt(_loc3_) as MovieClip);
               _loc3_++;
            }
         }
      }
      
      override protected function init() : void
      {
         EventManager.addEventListener("Error13088",this.onEError13088);
         ToolBarController.panel.hide();
         ToolBarController.showOrHideAllUser(false);
         LevelManager.iconLevel.visible = false;
         this.boss = conLevel["pet_0"];
         this.shuanDian = conLevel["shuan_dian"];
         this.petArr = new Array();
         this.lightning(null);
         this.timer = new Timer(500);
         this.timer.addEventListener(TimerEvent.TIMER,this.lightning);
         this.timer.start();
         var _loc1_:int = 1;
         while(_loc1_ <= 6)
         {
            this.petArr.push(conLevel["pet_" + _loc1_]);
            _loc1_++;
         }
         switch(xuanWuStatus)
         {
            case 0:
               this.initComp0();
               break;
            case 1:
               EventManager.addEventListener(PetFightEvent.ALARM_CLICK,this.initComp1);
               break;
            case 2:
               EventManager.addEventListener(PetFightEvent.ALARM_CLICK,this.initComp2);
               break;
            case 3:
               EventManager.addEventListener(PetFightEvent.ALARM_CLICK,this.initComp3);
               break;
            case 4:
               EventManager.addEventListener(PetFightEvent.ALARM_CLICK,this.initComp4);
         }
      }
      
      private function lightning(param1:TimerEvent) : void
      {
         var _loc2_:MovieClip = null;
         _loc2_ = null;
         var _loc3_:int = 1;
         while(_loc3_ <= 6)
         {
            _loc2_ = animatorLevel["lightning_" + _loc3_];
            _loc2_.visible = false;
            _loc2_.stop();
            _loc3_++;
         }
         _loc2_ = animatorLevel["lightning_" + (Math.floor(Math.random() * 6) + 1)];
         _loc2_.visible = true;
         _loc2_.play();
      }
      
      private function initComp0() : void
      {
         this.petInArr = new Array();
         Task142.getMc(this.boss,1,"",function(param1:MovieClip):void
         {
            var mc:MovieClip = null;
            mc = param1;
            AnimateManager.playMcAnimate(mc,0,"",function():void
            {
               Task142.getMc(mc,mc.totalFrames,"boss_in",function(param1:MovieClip):void
               {
                  var i:int = 0;
                  var pet:MovieClip = null;
                  var mc:MovieClip = param1;
                  bossIn = mc;
                  mc.buttonMode = true;
                  mc.addEventListener(MouseEvent.CLICK,fight6Boss);
                  stopMC(mc.parent);
                  i = 0;
                  while(i < 6)
                  {
                     pet = petArr[i];
                     Task142.getMc(pet,1,"",function(param1:MovieClip):void
                     {
                        var mc:MovieClip = null;
                        mc = param1;
                        AnimateManager.playMcAnimate(mc,0,"",function():void
                        {
                           Task142.getMc(mc,mc.totalFrames,"pet_in",function(param1:MovieClip):void
                           {
                              stopMC(param1.parent);
                              petInArr.push(param1);
                              param1.buttonMode = true;
                              param1.addEventListener(MouseEvent.CLICK,fight6Boss);
                           });
                        });
                     });
                     i++;
                  }
               });
            });
         });
      }
      
      private function initComp1(param1:PetFightEvent) : void
      {
         var i:int = 0;
         var pet:MovieClip = null;
         var event:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.initComp1);
         i = 0;
         while(i < 6)
         {
            pet = this.petArr[i];
            Task142.getMc(pet,2,"",function(param1:MovieClip):void
            {
               stopMC(param1.parent);
            });
            i++;
         }
         Task142.getMc(this.boss,2,"",function(param1:MovieClip):void
         {
            stopMC(param1.parent);
         });
         NpcDialog.show(NPC.XUANWU,["你的表现令我震惊，你愿意接受最后的考验吗？"],["我愿意接受最后的考验。","我还是下次再来吧。"],[this.initComp1Helper,this.initComp1Helper]);
      }
      
      private function initComp1Helper() : void
      {
         var pet:MovieClip = null;
         pet = null;
         Task142.getMc(this.boss,2,"",function(param1:MovieClip):void
         {
            var i:int = 0;
            var mc:MovieClip = param1;
            bossIn = mc;
            mc.buttonMode = true;
            mc.addEventListener(MouseEvent.CLICK,fightXuanWu);
            stopMC(mc.parent);
            index = 0;
            i = 0;
            while(i < 6)
            {
               pet = petArr[i];
               Task142.getMc(pet,2,"",function(param1:MovieClip):void
               {
                  var mc:MovieClip = null;
                  mc = param1;
                  AnimateManager.playMcAnimate(mc,0,"",function():void
                  {
                     ++index;
                     if(index == 6)
                     {
                        DisplayUtil.removeForParent(shuanDian);
                        DisplayUtil.removeForParent(typeLevel["tmp_path"]);
                        MapManager.currentMap.makeMapArray();
                     }
                     DisplayUtil.removeForParent(mc.parent);
                  });
               });
               i++;
            }
         });
      }
      
      private function initComp2(param1:PetFightEvent) : void
      {
         var i:int = 0;
         var pet:MovieClip = null;
         var event:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.initComp2);
         i = 0;
         while(i < 6)
         {
            pet = this.petArr[i];
            Task142.getMc(pet,2,"",function(param1:MovieClip):void
            {
               stopMC(param1.parent);
            });
            i++;
         }
         Task142.getMc(this.boss,2,"",function(param1:MovieClip):void
         {
            stopMC(param1.parent);
         });
         NpcDialog.show(NPC.XUANWU,["等你的实力有长足的进步时再来吧！"],["我还是下次再来吧。"],[function():void
         {
            var i:* = undefined;
            var pet:* = undefined;
            index = 0;
            i = 0;
            while(i < 6)
            {
               pet = petArr[i];
               Task142.getMc(pet,2,"",function(param1:MovieClip):void
               {
                  var mc:* = undefined;
                  mc = param1;
                  AnimateManager.playMcAnimate(mc,0,"",function():void
                  {
                     ++index;
                     if(index == 6)
                     {
                        DisplayUtil.removeForParent(shuanDian);
                        Task142.getMc(boss,2,"",function(param1:MovieClip):void
                        {
                           var mc:* = undefined;
                           mc = param1;
                           AnimateManager.playMcAnimate(mc,0,"",function():void
                           {
                              stopMC(mc.parent);
                              MapManager.changeMap(MapManager.prevMapID);
                           });
                        });
                     }
                     DisplayUtil.removeForParent(mc.parent);
                  });
               });
               i++;
            }
         }]);
      }
      
      private function initComp3(param1:PetFightEvent) : void
      {
         var i:int = 0;
         var id:int = 0;
         var name:String = null;
         var pet:MovieClip = null;
         id = 0;
         name = null;
         var event:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.initComp3);
         DisplayUtil.removeForParent(this.shuanDian);
         i = 0;
         while(i < 6)
         {
            pet = this.petArr[i];
            stopMC(pet);
            DisplayUtil.removeForParent(pet);
            i++;
         }
         Task142.getMc(this.boss,2,"",function(param1:MovieClip):void
         {
            stopMC(param1.parent);
         });
         if(TaskClass_145.spriteID != -1)
         {
            id = TaskClass_145.spriteID;
            name = ItemXMLInfo.getName(id);
            TaskClass_145.spriteID = -1;
            NpcDialog.show(NPC.XUANWU,["我为你感到骄傲！请收下我的精元，我将与你同在！"],["我不会让你失望的。"],[function():void
            {
               ItemInBagAlert.show(id,"1个" + TextFormatUtil.getRedTxt(name) + "已经放入你的储存箱！",function():void
               {
                  MapManager.changeMap(MapManager.prevMapID);
               });
            }]);
         }
         else
         {
            MapManager.changeMap(MapManager.prevMapID);
         }
      }
      
      private function initComp4(param1:PetFightEvent) : void
      {
         var i:int = 0;
         var pet:MovieClip = null;
         var event:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.initComp4);
         DisplayUtil.removeForParent(this.shuanDian);
         i = 0;
         while(i < 6)
         {
            pet = this.petArr[i];
            stopMC(pet);
            DisplayUtil.removeForParent(pet);
            i++;
         }
         Task142.getMc(this.boss,2,"",function(param1:MovieClip):void
         {
            stopMC(param1.parent);
         });
         NpcDialog.show(NPC.XUANWU,["等你的实力有长足的进步时再来吧！"],["我还是下次再来吧。"],[function():void
         {
            Task142.getMc(boss,2,"",function(param1:MovieClip):void
            {
               var mc:* = undefined;
               mc = param1;
               AnimateManager.playMcAnimate(mc,0,"",function():void
               {
                  if(Boolean(mc.parent))
                  {
                     DisplayUtil.removeForParent(mc.parent);
                     MapManager.changeMap(MapManager.prevMapID);
                  }
               });
            });
         }]);
      }
      
      private function fight6Boss(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         NpcDialog.show(NPC.XUANWU,["我是帕诺星系的守护神，你能进到这里说明你已经是个能独挡一面的精英了，但是真正的挑战现在才开始。"],["不管什么挑战我都不怕。","我还是下次再来吧。"],[function():void
         {
            SocketConnection.addCmdListener(CommandID.FIGHT_OVER,onFightOver1);
            FightInviteManager.fightWithBoss("玄武守护兽",0,true);
         },function():void
         {
            MapManager.changeMap(MapManager.prevMapID);
         }]);
      }
      
      private function fightByItem() : void
      {
         var itemID:int = 0;
         var onCheck:Function = null;
         itemID = 0;
         onCheck = null;
         onCheck = function(param1:ItemEvent):void
         {
            ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,onCheck);
            if(Boolean(ItemManager.getCollectionInfo(itemID)))
            {
               SocketConnection.send(9331);
            }
            else
            {
               Alarm.show("你没有玄武挑战令噢！");
            }
         };
         itemID = 1200424;
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,onCheck);
         ItemManager.upDateCollection(itemID);
      }
      
      private function onFightOver1(param1:SocketEvent) : void
      {
         var _loc2_:FightOverInfo = param1.data as FightOverInfo;
         SocketConnection.removeCmdListener(CommandID.FIGHT_OVER,this.onFightOver1);
         if(_loc2_.winnerID == MainManager.actorInfo.userID)
         {
            xuanWuStatus = 1;
         }
         else
         {
            xuanWuStatus = 2;
         }
      }
      
      private function fightXuanWu(param1:MouseEvent) : void
      {
         SocketConnection.addCmdListener(CommandID.FIGHT_OVER,this.onFightOver2);
         FightInviteManager.fightWithBoss("巴斯特",1,true);
      }
      
      private function onFightOver2(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.FIGHT_OVER,this.onFightOver2);
         if((param1.data as FightOverInfo).winnerID == MainManager.actorID)
         {
            xuanWuStatus = 3;
         }
         else
         {
            xuanWuStatus = 4;
         }
      }
      
      private function onEError13088(param1:RobotEvent) : void
      {
         var event:RobotEvent = param1;
         EventManager.removeEventListener("Error13088",this.onEError13088);
         NpcDialog.show(NPC.XUANWU,["玄武空间出现了异常状况，你必须立刻离开这里。"],["嗯，我知道啦~~"],[function():void
         {
            MapManager.changeMap(MapManager.prevMapID);
         }]);
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         EventManager.removeEventListener("Error13088",this.onEError13088);
         LevelManager.iconLevel.visible = true;
         ToolBarController.panel.show();
         ToolBarController.showOrHideAllUser(true);
         if(Boolean(this.boss))
         {
            this.boss.removeEventListener(MouseEvent.CLICK,this.fight6Boss);
            this.boss.removeEventListener(MouseEvent.CLICK,this.fightXuanWu);
            this.boss = null;
         }
         this.timer.removeEventListener(TimerEvent.TIMER,this.lightning);
         if(Boolean(this.petInArr))
         {
            _loc1_ = 0;
            while(_loc1_ < 6)
            {
               if(Boolean(this.petInArr[_loc1_]))
               {
                  this.petInArr[_loc1_].removeEventListener(MouseEvent.CLICK,this.fight6Boss);
               }
               _loc1_++;
            }
         }
         this.shuanDian = null;
         this.petArr = null;
      }
   }
}

