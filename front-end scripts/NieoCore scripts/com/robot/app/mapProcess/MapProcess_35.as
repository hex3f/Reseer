package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.task.control.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.dayGift.*;
   import com.robot.core.event.*;
   import com.robot.core.info.task.CateInfo;
   import com.robot.core.info.task.DayTalkInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import com.robot.core.net.*;
   import com.robot.core.npc.*;
   import com.robot.core.ui.alert.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   
   public class MapProcess_35 extends BaseMapProcess
   {
      
      private var gameTrig:MovieClip;
      
      private var panel:AppModel;
      
      private var inTask42Flag:Boolean = false;
      
      private var makePetPassFlag:Boolean = false;
      
      public function MapProcess_35()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.gameTrig = conLevel["game_trig"];
         this.gameTrig.visible = false;
         this.gameTrig.buttonMode = true;
         if(TasksManager.getTaskStatus(42) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(42,function(param1:Array):void
            {
               if(Boolean(param1[3]) && !param1[4])
               {
                  inTask42Flag = true;
                  gameInit();
               }
            });
         }
         else if(TasksManager.getTaskStatus(42) == TasksManager.COMPLETE)
         {
            this.gameInit();
         }
         conLevel["btn1"].addEventListener(MouseEvent.CLICK,this.onBtn1ClickHandler);
         conLevel["btn2"].addEventListener(MouseEvent.CLICK,this.onBtn2ClickHandler);
      }
      
      private function gameInit() : void
      {
         this.gameTrig.visible = true;
         this.gameTrig.addEventListener(MouseEvent.CLICK,this.onGameTrigClickHand);
      }
      
      private function onGameTrigClickHand(param1:MouseEvent) : void
      {
         if(!this.panel)
         {
            this.panel = new AppModel(ClientConfig.getGameModule("SpritePieceTogether"),"正在打开...");
            this.panel.setup();
            this.panel.sharedEvents.addEventListener("GamePass",this.onGamePassHandler);
            this.panel.sharedEvents.addEventListener("GameFail",this.onGameFailHandler);
            this.panel.sharedEvents.addEventListener("GameClose",this.onGameCloseHandler);
         }
         this.panel.show();
         SocketConnection.addCmdListener(CommandID.JOIN_GAME,this.onJoinGameHandler);
         SocketConnection.send(CommandID.JOIN_GAME,1);
      }
      
      private function onJoinGameHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.JOIN_GAME,this.onJoinGameHandler);
      }
      
      private function gameOverHandler(param1:uint = 0, param2:uint = 0) : void
      {
         SocketConnection.addCmdListener(CommandID.GAME_OVER,this.onGameOverHandler);
         SocketConnection.send(CommandID.GAME_OVER,param1,param2);
      }
      
      private function onGameOverHandler(param1:SocketEvent) : void
      {
         var e:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.GAME_OVER,this.onGameOverHandler);
         if(this.inTask42Flag)
         {
            if(this.makePetPassFlag)
            {
               NpcTipDialog.show("天！太棒了！你为什么可以制造出这样完美的机械精灵？你究竟是谁？",function():void
               {
                  NpcTipDialog.show("我只是一个星球旅行者",function():void
                  {
                     NpcTipDialog.show("太棒了！赛尔！这下赫尔卡星就有救了！我们快回去告诉爱丽丝这个好消息吧！",function():void
                     {
                        TasksManager.complete(TaskController_42.TASK_ID,4,function():void
                        {
                           TaskController_42.showPanel();
                        });
                     },NpcTipDialog.NONO);
                  },NpcTipDialog.SEER);
               },NpcTipDialog.ELDER);
            }
            else
            {
               NpcTipDialog.show("别着急，一定能成功制造出比卡塔精灵更厉害的机械精灵的！",null,NpcTipDialog.NONO);
            }
         }
      }
      
      private function onGameCloseHandler(param1:Event) : void
      {
         this.panel.sharedEvents.removeEventListener("GameClose",this.onGameCloseHandler);
         this.panel.destroy();
         this.panel = null;
         this.gameOverHandler();
         this.makePetPassFlag = false;
      }
      
      private function onGameFailHandler(param1:Event) : void
      {
         this.panel.sharedEvents.removeEventListener("GameFail",this.onGameFailHandler);
         this.panel.destroy();
         this.panel = null;
         this.gameOverHandler();
         this.makePetPassFlag = false;
         Alarm.show("哦噢！很抱歉，制造机械精灵任务失败！");
      }
      
      private function onGamePassHandler(param1:Event) : void
      {
         this.panel.sharedEvents.removeEventListener("GamePass",this.onGamePassHandler);
         this.panel.destroy();
         this.panel = null;
         this.makePetPassFlag = true;
         this.gameOverHandler(100,100);
      }
      
      private function onBtn1ClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:DayGiftController = new DayGiftController(1502,1,"你已经领取过胶囊了");
         _loc2_.addEventListener(DayGiftController.COUNT_SUCCESS,this.onCountSuccess);
         _loc2_.getCount();
         conLevel["btn1"].removeEventListener(MouseEvent.CLICK,this.onBtn1ClickHandler);
         conLevel["btn1"].mouseEnabled = false;
      }
      
      private function onCountSuccess(param1:Event) : void
      {
         var gift:DayGiftController = null;
         var mc:MovieClip = null;
         var event:Event = param1;
         gift = null;
         mc = null;
         gift = event.currentTarget as DayGiftController;
         mc = conLevel["mc2"];
         mc.gotoAndPlay(2);
         mc.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            var e:Event = param1;
            if(mc.currentFrame == mc.totalFrames)
            {
               mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               gift.sendToServer(function(param1:DayTalkInfo):void
               {
                  var _loc2_:CateInfo = null;
                  var _loc3_:uint = 0;
                  var _loc4_:uint = 0;
                  for each(_loc2_ in param1.outList)
                  {
                     _loc3_ = uint(_loc2_.id);
                     _loc4_ = uint(_loc2_.count);
                     ItemInBagAlert.show(_loc3_,_loc4_ + "个<font color=\'#ff0000\'>" + ItemXMLInfo.getName(_loc3_) + "</font>已经放入你的储存箱中");
                  }
               });
            }
         });
      }
      
      private function onBtn2ClickHandler(param1:MouseEvent) : void
      {
         conLevel["btn2"].removeEventListener(MouseEvent.CLICK,this.onBtn2ClickHandler);
         conLevel["btn2"].mouseEnabled = false;
      }
      
      public function onMc3HitHandler() : void
      {
         conLevel["mc3"].gotoAndPlay(2);
      }
      
      override public function destroy() : void
      {
         conLevel["btn1"].removeEventListener(MouseEvent.CLICK,this.onBtn1ClickHandler);
         conLevel["btn2"].removeEventListener(MouseEvent.CLICK,this.onBtn2ClickHandler);
         this.gameTrig.removeEventListener(MouseEvent.CLICK,this.onGameTrigClickHand);
         this.gameTrig = null;
      }
   }
}

