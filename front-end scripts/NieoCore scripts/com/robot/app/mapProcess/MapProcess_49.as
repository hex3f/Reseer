package com.robot.app.mapProcess
{
   import com.robot.app.buyItem.*;
   import com.robot.app.control.*;
   import com.robot.app.energy.utils.*;
   import com.robot.app.fightNote.*;
   import com.robot.app.leiyiTrain.LeiyiTrainController;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.task.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   
   public class MapProcess_49 extends BaseMapProcess
   {
      
      private var bossMC:MovieClip;
      
      private var bossBtn:SimpleButton;
      
      private var station:MovieClip;
      
      private var _panel:AppModel;
      
      private var timer:Timer;
      
      public function MapProcess_49()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.bossMC = conLevel["bossMC"];
         this.bossBtn = conLevel["bossBtn"];
         this.bossBtn.mouseEnabled = false;
         this.bossMC.addEventListener(MouseEvent.CLICK,this.clickBossMC);
         this.bossBtn.addEventListener(MouseEvent.CLICK,this.fightBoss);
         this.timer = new Timer(10 * 1000,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.timerHandler);
      }
      
      override public function destroy() : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_START,this.onWalk);
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.timerHandler);
         this.timer = null;
         if(Boolean(this._panel))
         {
            this._panel.destroy();
         }
         this._panel = null;
         this.bossMC.removeEventListener(MouseEvent.CLICK,this.clickBossMC);
         this.bossBtn.removeEventListener(MouseEvent.CLICK,this.fightBoss);
         this.bossMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
         this.bossBtn = null;
         this.bossMC = null;
      }
      
      private function clickBossMC(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         this.bossMC.gotoAndPlay(2);
         this.bossMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            if(bossMC.currentFrame == bossMC.totalFrames)
            {
               bossMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               bossBtn.mouseEnabled = true;
            }
         });
      }
      
      private function fightBoss(param1:MouseEvent) : void
      {
         var _arg_1:MouseEvent = param1;
         if(TasksManager.getTaskStatus(122) == TasksManager.ALR_ACCEPT)
         {
            if(TasksManager.getTaskStatus(122) == TasksManager.ALR_ACCEPT)
            {
               TasksManager.getProStatusList(122,function(param1:Array):void
               {
                  if(Boolean(param1[0]) && !param1[1])
                  {
                     LeiyiTrainController.initTrain_2(bossBtn);
                  }
                  else if(MapManager.currentMap.id == 49)
                  {
                     FightInviteManager.fightWithBoss("雷纳多");
                  }
               });
            }
         }
         else if(MapManager.currentMap.id == 49)
         {
            FightInviteManager.fightWithBoss("雷纳多");
         }
      }
      
      private function onClickStation(param1:MouseEvent) : void
      {
      }
      
      public function giveThings() : void
      {
         ItemManager.addEventListener(ItemEvent.CLOTH_LIST,this.onList);
         ItemManager.getCloth();
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
      
      public function getStone() : void
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
         SocketConnection.send(CommandID.TALK_CATE,12);
      }
      
      private function onWalk(param1:RobotEvent) : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_START,this.onWalk);
         this.timer.stop();
         this.timer.reset();
         MainManager.actorModel.scaleX = 1;
         MainManager.actorModel.stop();
         Alarm.show("随便走动是无法挖到电能石的!");
      }
      
      private function onSuccess(param1:SocketEvent) : void
      {
         MainManager.actorModel.direction = Direction.DOWN;
         MainManager.actorModel.scaleX = 1;
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onSuccess);
         var _loc2_:DayTalkInfo = param1.data as DayTalkInfo;
         var _loc3_:CateInfo = _loc2_.outList[0];
         var _loc4_:String = ItemXMLInfo.getName(_loc3_.id);
         NpcTipDialog.show("看样子你采集到了" + _loc3_.count.toString() + "个" + _loc4_ + "。" + _loc4_ + "都已经放入你的储存箱里了。\n<font color=\'#FF0000\'> " + "   快去飞船动力室看看它有什么用</font>",null,NpcTipDialog.DOCTOR,-80);
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
      
      public function showStationPanel() : void
      {
         ExploreStationController.showPanel("双子贝塔星");
      }
   }
}

