package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.task.control.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.app.temp.*;
   import com.robot.core.event.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.utils.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_315 extends BaseMapProcess
   {
      
      private var clothesArr:Array = [];
      
      private var timer:Timer;
      
      private var randomTime:uint = 2000;
      
      private var canSee:Boolean = false;
      
      private var canAbsorb:Boolean = false;
      
      private var pet1:RandomPet;
      
      private var pet2:RandomPet;
      
      private var pet0:RandomPet;
      
      private var cartoon_mc:MovieClip;
      
      private var shou_mc:MovieClip;
      
      private var shou_int:int = 0;
      
      private var typeInt:int;
      
      private var door_switch:MovieClip;
      
      private var door_effect:MovieClip;
      
      private var carver:Carver;
      
      private var megnetAlloyMC:MovieClip;
      
      public function MapProcess_315()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.visibleShou();
         this.clothesArr = MainManager.actorInfo.clothIDs;
         this.checkVisible();
         this.checkAbsorb();
         EventManager.addEventListener(PeopleActionEvent.CLOTH_CHANGE,this.onClothChange);
         this.cartoon_mc = topLevel["cartoon_mc"];
         this.shou_mc = this.cartoon_mc["shou_mc"];
         this.cartoon_mc.gotoAndStop(1);
         this.shou_mc.gotoAndStop(1);
         this.cartoon_mc.visible = false;
         this.addPet();
         this.randomTime = 4000 * Math.random() + 1000;
         this.timer = new Timer(this.randomTime,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.start();
         this.carver = new Carver(this);
         this.door_switch = conLevel["door_switch_mc"];
         this.door_switch.buttonMode = true;
         this.door_switch.gotoAndStop(1);
         this.door_effect = conLevel["door_effect"];
         this.door_effect.visible = false;
         this.door_effect.gotoAndStop(1);
         conLevel["door_2"].gotoAndStop(1);
         conLevel["door_2"].visible = false;
      }
      
      private function addPet() : void
      {
         this.pet1 = new RandomPet();
         this.pet1.buttonMode = true;
         MapManager.currentMap.depthLevel.addChild(this.pet1);
         this.pet1.visible = this.canSee;
         this.pet1.addEventListener(MouseEvent.CLICK,this.onClickSprite);
         this.pet2 = new RandomPet();
         this.pet2.buttonMode = true;
         MapManager.currentMap.depthLevel.addChild(this.pet2);
         this.pet2.visible = this.canSee;
         this.pet2.addEventListener(MouseEvent.CLICK,this.onClickSprite);
         this.pet0 = new RandomPet();
         this.pet0.buttonMode = true;
         MapManager.currentMap.depthLevel.addChild(this.pet0);
         this.pet0.visible = this.canSee;
         this.pet0.addEventListener(MouseEvent.CLICK,this.onClickSprite);
         this.pet1.name = "pet1";
         this.pet2.name = "pet2";
         this.pet0.name = "pet0";
      }
      
      override public function destroy() : void
      {
         if(Boolean(this.timer))
         {
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.timer = null;
         }
         if(Boolean(this.pet0))
         {
            MapManager.currentMap.depthLevel.removeChild(this.pet0);
            this.pet0.destroy();
         }
         if(Boolean(this.pet1))
         {
            MapManager.currentMap.depthLevel.removeChild(this.pet1);
            this.pet1.destroy();
         }
         if(Boolean(this.pet2))
         {
            MapManager.currentMap.depthLevel.removeChild(this.pet2);
            this.pet2.destroy();
         }
         this.pet0 = null;
         this.pet1 = null;
         this.pet2 = null;
         this.cartoon_mc = null;
         this.shou_mc = null;
         this.clothesArr = null;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this.randomTime = 4000 * Math.random() + 3000;
         this.timer.stop();
         this.timer.reset();
         this.timer.start();
         if(Boolean(this.pet0))
         {
            MapManager.currentMap.depthLevel.removeChild(this.pet0);
            this.pet0.destroy();
         }
         if(Boolean(this.pet1))
         {
            MapManager.currentMap.depthLevel.removeChild(this.pet1);
            this.pet1.destroy();
         }
         if(Boolean(this.pet2))
         {
            MapManager.currentMap.depthLevel.removeChild(this.pet2);
            this.pet2.destroy();
         }
         this.addPet();
      }
      
      private function shouEnterFrameHandler(param1:Event) : void
      {
         if(this.cartoon_mc.currentFrame == 20)
         {
            this.cartoon_mc.removeEventListener(Event.ENTER_FRAME,this.shouEnterFrameHandler);
            this.cartoon_mc.visible = false;
            this.cartoon_mc.gotoAndStop(1);
            this.shou_mc.gotoAndStop(1);
            LevelManager.openMouseEvent();
         }
      }
      
      private function showShouPet(param1:int, param2:int) : void
      {
         topLevel["m" + param1].visible = true;
         if(param2 == 0)
         {
            DisplayUtil.FillColor(topLevel["m" + param1],16711680);
         }
         else
         {
            DisplayUtil.FillColor(topLevel["m" + param1],16777215);
         }
      }
      
      private function visibleShou() : void
      {
         topLevel["m0"].visible = false;
         topLevel["m1"].visible = false;
         topLevel["m2"].visible = false;
         topLevel["m3"].visible = false;
         topLevel["m4"].visible = false;
      }
      
      private function onClickSprite(param1:MouseEvent) : void
      {
         var temp:RandomPet = null;
         var str:String = null;
         var evt:MouseEvent = param1;
         if(this.shou_int == 5)
         {
            if(this.typeInt == 0)
            {
               NpcTipDialog.show("非常好，已经吸满五个红色暗影，你有机会抓住这只精灵哦。接下来是否希望和精灵进行对战？",function():void
               {
                  FightInviteManager.fightWithBoss("波古");
               },NpcTipDialog.DOCTOR);
            }
            else
            {
               NpcTipDialog.show("非常好，已经吸满五个白色暗影，你有机会抓住这只精灵哦。接下来是否希望和精灵进行对战？",function():void
               {
                  FightInviteManager.fightWithBoss("波古");
               },NpcTipDialog.DOCTOR);
            }
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.timer = null;
            return;
         }
         if(this.canAbsorb)
         {
            temp = evt.currentTarget as RandomPet;
            str = temp.color;
            if(str == "red")
            {
               if(this.shou_int == 0)
               {
                  this.typeInt = 0;
                  this.showShouPet(this.shou_int,this.typeInt);
               }
               else
               {
                  if(this.typeInt != 0)
                  {
                     this.shou_int = 0;
                     NpcTipDialog.show("两种不同颜色的暗影是相互排斥的，你要重新来过咯！",null,NpcTipDialog.DOCTOR);
                     this.visibleShou();
                     return;
                  }
                  this.showShouPet(this.shou_int,this.typeInt);
               }
               DisplayUtil.FillColor(this.shou_mc,16711680);
            }
            else
            {
               if(this.shou_int == 0)
               {
                  this.typeInt = 1;
                  this.showShouPet(this.shou_int,this.typeInt);
               }
               else
               {
                  if(this.typeInt != 1)
                  {
                     NpcTipDialog.show("两种不同颜色的暗影是相互排斥的，你要重新来过咯！",null,NpcTipDialog.DOCTOR);
                     this.shou_int = 0;
                     this.visibleShou();
                     return;
                  }
                  this.showShouPet(this.shou_int,this.typeInt);
               }
               DisplayUtil.FillColor(this.shou_mc,16777215);
            }
            this.cartoon_mc.visible = true;
            this.cartoon_mc.gotoAndPlay(1);
            this.shou_mc.gotoAndPlay(1);
            this.cartoon_mc.addEventListener(Event.ENTER_FRAME,this.shouEnterFrameHandler);
            MapManager.currentMap.depthLevel.removeChild(temp);
            temp.destroy();
            ++this.shou_int;
            LevelManager.closeMouseEvent();
            if(temp.name == "pet0")
            {
               this.pet0 = null;
            }
            if(temp.name == "pet1")
            {
               this.pet1 = null;
            }
            if(temp.name == "pet2")
            {
               this.pet2 = null;
            }
         }
      }
      
      private function onClothChange(param1:Event) : void
      {
         this.clothesArr = MainManager.actorInfo.clothIDs;
         this.checkVisible();
         this.checkAbsorb();
      }
      
      private function checkVisible() : void
      {
         var _loc1_:uint = 0;
         for each(_loc1_ in this.clothesArr)
         {
            if(_loc1_ == 100162)
            {
               if(Boolean(this.pet0))
               {
                  this.pet0.visible = true;
                  this.pet1.visible = true;
                  this.pet2.visible = true;
               }
               this.canSee = true;
               return;
            }
         }
         if(Boolean(this.pet0))
         {
            this.pet0.visible = false;
            this.pet1.visible = false;
            this.pet2.visible = false;
         }
         this.canSee = false;
      }
      
      private function checkAbsorb() : void
      {
         var _loc1_:uint = 0;
         for each(_loc1_ in this.clothesArr)
         {
            if(_loc1_ == 100223)
            {
               this.canAbsorb = true;
               return;
            }
         }
         this.canAbsorb = false;
      }
      
      public function clickOpenDoor() : void
      {
         this.carver.onClickOpenDoor();
      }
      
      public function onStand(param1:MovieClip) : void
      {
         conLevel["door_2"].visible = true;
         conLevel["door_2"].gotoAndPlay(4);
         conLevel["door_2"].buttonMode = true;
         this.door_effect.visible = true;
         this.door_effect.gotoAndStop(1);
         NpcTipDialog.show("时空之门已经开启！\r\n点击时空之门穿越回千年前的赫尔卡星吧！",null,NpcTipDialog.IRIS);
      }
      
      public function onChangeMap(param1:MovieClip) : void
      {
         var mc:MovieClip = param1;
         this.door_effect.gotoAndPlay(2);
         this.door_effect.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            var evt:Event = param1;
            if(door_effect.currentFrame == door_effect.totalFrames)
            {
               door_effect.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               if(TasksManager.getTaskStatus(42) == TasksManager.ALR_ACCEPT)
               {
                  TasksManager.complete(TaskController_42.TASK_ID,0,null);
               }
               setTimeout(function():void
               {
                  door_effect.gotoAndStop(1);
                  setTimeout(function():void
                  {
                     MapManager.changeMap(320);
                  },200);
               },500);
            }
         });
      }
   }
}

import com.robot.app.task.taskUtils.taskDialog.*;
import com.robot.core.info.NonoInfo;
import com.robot.core.manager.*;
import com.robot.core.manager.map.config.BaseMapProcess;
import flash.display.MovieClip;
import flash.events.*;
import org.taomee.utils.*;

class Carver
{
   
   private var map:BaseMapProcess;
   
   private var openDoorMC:MovieClip;
   
   private var nonoOpenDoor:MovieClip;
   
   private var supNonoOpenDoor:MovieClip;
   
   private var door_1:MovieClip;
   
   private var isOpeingDoor:Boolean = false;
   
   public function Carver(param1:BaseMapProcess)
   {
      super();
      this.map = param1;
      this.nonoOpenDoor = this.map.conLevel["nonoOpenDoor"];
      this.nonoOpenDoor.gotoAndStop(1);
      this.nonoOpenDoor.visible = false;
      this.supNonoOpenDoor = this.map.conLevel["supNonoOpenDoor"];
      this.supNonoOpenDoor.gotoAndStop(1);
      this.supNonoOpenDoor.visible = false;
      this.openDoorMC = this.map.conLevel["openDoorMC"];
      this.door_1 = this.map.conLevel["door_1"];
      this.door_1.mouseEnabled = false;
   }
   
   public function onClickOpenDoor() : void
   {
      var info:NonoInfo = null;
      var supNonoColorMC:MovieClip = null;
      var nonoColorMC:MovieClip = null;
      var str:String = null;
      if(this.isOpeingDoor)
      {
         return;
      }
      this.isOpeingDoor = true;
      info = null;
      supNonoColorMC = null;
      nonoColorMC = null;
      if(Boolean(MainManager.actorModel.nono))
      {
         info = NonoManager.info;
         if(info.superNono)
         {
            MainManager.actorModel.hideNono();
            this.supNonoOpenDoor.visible = true;
            this.supNonoOpenDoor.gotoAndStop(2);
            this.openDoorMC.buttonMode = false;
            this.openDoorMC.mouseEnabled = false;
            supNonoColorMC = this.supNonoOpenDoor["supNonoColorMC"];
            DisplayUtil.FillColor(supNonoColorMC,MainManager.actorInfo.nonoColor);
            supNonoColorMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               var evt:Event = param1;
               if(supNonoColorMC.currentFrame == supNonoColorMC.totalFrames)
               {
                  supNonoColorMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  DisplayUtil.removeForParent(supNonoOpenDoor);
                  MainManager.actorModel.showNono(info,MainManager.actorInfo.actionType);
                  openDoorMC.gotoAndPlay(2);
                  openDoorMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
                  {
                     if(openDoorMC.currentFrame == openDoorMC.totalFrames)
                     {
                        openDoorMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                        door_1.mouseEnabled = true;
                        door_1.buttonMode = true;
                        isOpeingDoor = false;
                     }
                  });
               }
            });
         }
         else if(Boolean(info.func[700006 - 700001]))
         {
            MainManager.actorModel.hideNono();
            this.nonoOpenDoor.visible = true;
            this.nonoOpenDoor.gotoAndStop(2);
            this.openDoorMC.buttonMode = false;
            this.openDoorMC.mouseEnabled = false;
            nonoColorMC = this.nonoOpenDoor["nonoColorMC"];
            nonoColorMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               var evt:Event = param1;
               if(nonoColorMC.currentFrame == nonoColorMC.totalFrames)
               {
                  nonoColorMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  DisplayUtil.removeForParent(nonoOpenDoor);
                  MainManager.actorModel.showNono(info,MainManager.actorInfo.actionType);
                  openDoorMC.gotoAndPlay(2);
                  openDoorMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
                  {
                     if(openDoorMC.currentFrame == openDoorMC.totalFrames)
                     {
                        openDoorMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                        door_1.mouseEnabled = true;
                        door_1.buttonMode = true;
                        isOpeingDoor = false;
                     }
                  });
               }
            });
         }
         else
         {
            NpcTipDialog.show("要给你的NoNo装上机械臂哦，去发明室查查看合成手册，给NoNo装好芯片再来试试看吧！",null,NpcTipDialog.IRIS);
         }
      }
      else
      {
         str = "这扇门需要NoNo帮忙才能开启啊，带上你的NoNo再来试试看吧！";
         NpcTipDialog.show(str,null,NpcTipDialog.IRIS);
         this.isOpeingDoor = false;
      }
   }
}
