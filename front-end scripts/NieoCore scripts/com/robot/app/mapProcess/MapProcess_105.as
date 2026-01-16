package com.robot.app.mapProcess
{
   import com.robot.app.buyItem.*;
   import com.robot.app.energy.utils.*;
   import com.robot.app.fightNote.*;
   import com.robot.app.spacesurvey.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.task.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.SharedObject;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class MapProcess_105 extends BaseMapProcess
   {
      
      private var mcArr:Array;
      
      private var yoyoMC:MovieClip;
      
      private var isShow:Boolean = false;
      
      private var isCatch:Boolean = false;
      
      private var timer:Timer;
      
      private var clickArray:Array = [];
      
      private var clickMC:MovieClip;
      
      private var waterIndex:Number;
      
      public function MapProcess_105()
      {
         super();
      }
      
      override protected function init() : void
      {
         SpaceSurveyTool.getInstance().show("双子阿尔法星");
         this.timer = new Timer(10 * 1000,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.timerHandler);
         this.yoyoMC = conLevel["yoyoMC"];
         if(TasksManager.getTaskStatus(23) != TasksManager.COMPLETE)
         {
            this.initNewPet();
         }
         conLevel["bridge"].mouseEnabled = false;
         conLevel["bridge"].mouseChildren = false;
      }
      
      private function onCatchMonster(param1:SocketEvent) : void
      {
         var _loc2_:CatchPetInfo = param1.data as CatchPetInfo;
         if(PetFightModel.defaultNpcID == 91 && _loc2_.catchTime > 0)
         {
            this.isCatch = true;
         }
      }
      
      private function initNewPet() : void
      {
         var _loc1_:MovieClip = null;
         this.clickArray = [conLevel["seven"],conLevel["eight"],conLevel["nine"],conLevel["ten"]];
         for each(_loc1_ in this.clickArray)
         {
            _loc1_.buttonMode = true;
            _loc1_.addEventListener(MouseEvent.CLICK,this.clickMCHandler);
         }
      }
      
      private function clickMCHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_ == this.clickMC || this.isShow || this.isCatch)
         {
            return;
         }
         this.clickMC = _loc2_;
         if(Math.random() < 0.1)
         {
            this.yoyoMC.x = this.clickMC.x;
            this.yoyoMC.y = this.clickMC.y;
            conLevel["yoyoHit"].x = this.yoyoMC.x + 100;
            conLevel["yoyoHit"].y = this.yoyoMC.y + 20;
            this.yoyoMC["yoyoMC"].gotoAndStop(2);
            this.isShow = true;
            setTimeout(this.hideYoyo,4000);
         }
      }
      
      private function hideYoyo() : void
      {
         if(Boolean(this.yoyoMC))
         {
            this.yoyoMC.y = -200;
            this.yoyoMC["yoyoMC"].gotoAndStop(1);
         }
         this.isShow = false;
      }
      
      public function fightYoyo() : void
      {
         if(this.isShow)
         {
            PetFightModel.defaultNpcID = 91;
            FightInviteManager.fightWithBoss("悠悠");
         }
      }
      
      private function onComHandler(param1:Array) : void
      {
         this.waterIndex = 0;
         this.mcArr = new Array();
         this.mcArr = [conLevel["one"],conLevel["two"],conLevel["three"],conLevel["four"],conLevel["five"],conLevel["six"]];
         conLevel["bridge"].visible = false;
         if(!param1[2] && Boolean(param1[1]))
         {
            conLevel["animator_mc"].gotoAndStop(11);
            this.playWater();
            conLevel["bridge"].visible = true;
            DisplayUtil.removeForParent(typeLevel["bridge"]);
            conLevel["animator_mc"]["edison"].visible = false;
            conLevel["animator_mc"]["edison"].gotoAndStop(1);
            MapManager.currentMap.makeMapArray();
         }
         else if(!param1[1] && Boolean(param1[0]))
         {
            conLevel["animator_mc"].gotoAndStop(4);
            conLevel["bridge"].visible = false;
         }
         else if(Boolean(param1[2]))
         {
            conLevel["animator_mc"].gotoAndStop(11);
            conLevel["bridge"].visible = true;
            DisplayUtil.removeForParent(typeLevel["bridge"]);
            conLevel["animator_mc"]["edison"].visible = false;
            conLevel["animator_mc"]["edison"].gotoAndStop(1);
            MapManager.currentMap.makeMapArray();
         }
      }
      
      private function playWater() : void
      {
         if(this.waterIndex < 5)
         {
            this.mcArr[this.waterIndex].gotoAndPlay(33);
            ++this.waterIndex;
            setTimeout(this.playWater,400);
            return;
         }
      }
      
      private function onList(param1:ItemEvent) : void
      {
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onList);
         var _loc2_:Array = ItemManager.getClothIDs();
         if(_loc2_.indexOf(100014) != -1 && _loc2_.indexOf(100015) != -1)
         {
            Alarm.show("你已经拥有矿工头盔和采矿钻头了，快去帮忙吧！");
         }
         if(_loc2_.indexOf(100014) == -1)
         {
            ItemAction.buyItem(100014,false);
         }
         if(_loc2_.indexOf(100015) == -1)
         {
            ItemAction.buyItem(100015,false);
         }
      }
      
      public function changeScrene() : void
      {
         MapManager.changeMap(1);
      }
      
      override public function destroy() : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_START,this.onWalk);
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
         this.timer = null;
         SocketConnection.removeCmdListener(CommandID.CATCH_MONSTER,this.onCatchMonster);
         this.yoyoMC = null;
         SpaceSurveyTool.getInstance().hide();
      }
      
      public function alison() : void
      {
         MapManager.changeMap(106);
      }
      
      public function hitMine() : void
      {
         if(!this.checkCloth())
         {
            return;
         }
         EnergyController.exploit();
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_START,this.onWalk);
         SocketConnection.addCmdListener(CommandID.TALK_CATE,this.onSuccess);
         SocketConnection.send(CommandID.TALK_CATE,9);
      }
      
      private function onWalk(param1:RobotEvent) : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_START,this.onWalk);
         this.timer.stop();
         this.timer.reset();
         MainManager.actorModel.scaleX = 1;
         MainManager.actorModel.stop();
         Alarm.show("随便走动是无法挖到蘑菇结晶的!");
      }
      
      private function onSuccess(param1:SocketEvent) : void
      {
         var _loc2_:SharedObject = null;
         MainManager.actorModel.direction = Direction.DOWN;
         MainManager.actorModel.scaleX = 1;
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onSuccess);
         var _loc3_:DayTalkInfo = param1.data as DayTalkInfo;
         var _loc4_:CateInfo = _loc3_.outList[0];
         var _loc5_:String = ItemXMLInfo.getName(_loc4_.id);
         NpcTipDialog.show("看样子你采集到了" + _loc4_.count.toString() + "个" + _loc5_ + "。" + _loc5_ + "都已经放入你的储存箱里了。\n<font color=\'#FF0000\'> " + "   快去飞船动力室看看它有什么用</font>",null,NpcTipDialog.DOCTOR,-80);
         _loc2_ = SOManager.getUserSO(SOManager.MINE_400010);
         if(!_loc2_.data["isCatch"])
         {
            _loc2_.data["isCatch"] = true;
            SOManager.flush(_loc2_);
         }
      }
      
      private function checkCloth() : Boolean
      {
         var _loc1_:Boolean = true;
         if(MainManager.actorInfo.clothIDs.indexOf(100014) == -1 && MainManager.actorInfo.clothIDs.indexOf(100717) == -1)
         {
            _loc1_ = false;
            Alarm.show("你必须装备上" + TextFormatUtil.getRedTxt(ItemXMLInfo.getName(100014)) + "才能进行采集哦！");
         }
         return _loc1_;
      }
   }
}

