package com.robot.app.mapProcess
{
   import com.robot.app.control.DivingGameController;
   import com.robot.app.games.FerruleGame.FerruleGamePanel;
   import com.robot.app.mapProcess.active.PetListController;
   import com.robot.app.spacesurvey.SpaceSurveyTool;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.DialogBox;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   import org.taomee.events.DynamicEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_51 extends BaseMapProcess
   {
      
      private static var panel:AppModel = null;
      
      private var npc:MovieClip;
      
      private var mushroom:MovieClip;
      
      private var box:DialogBox;
      
      private var timer:Timer;
      
      private var wordArr:Array = ["嗨，大个子！冰系精灵争霸赛已经闭幕咯！我很期待我们明年的比赛哟，有空常来哦！"];
      
      private var timerIndex:uint = 0;
      
      private var snow_mc:MovieClip;
      
      private var iceGameBtn:MovieClip;
      
      private var thimbleGameBtn:MovieClip;
      
      private var divingGameBtn:MovieClip;
      
      private var greenDoor:SimpleButton;
      
      private var bluedoor:MovieClip;
      
      private var milu1:MovieClip;
      
      private var milu2:MovieClip;
      
      private var confirm:SimpleButton;
      
      private var closeBt:SimpleButton;
      
      private var confirm2:SimpleButton;
      
      private var closeBt2:SimpleButton;
      
      private var refuse:SimpleButton;
      
      private var listCon:PetListController;
      
      private var snowBallGameLevel:uint;
      
      private var snowBalldis:DisplayObject;
      
      private var inSnowGame:Boolean = false;
      
      private var gameSwitch:Boolean = false;
      
      private var icePanel:AppModel;
      
      public function MapProcess_51()
      {
         super();
      }
      
      override protected function init() : void
      {
         var i:uint = 0;
         var n:MovieClip = null;
         var snowName:String = null;
         var mc:MovieClip = null;
         this.npc = this.depthLevel["npc"];
         this.timer = new Timer(7000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this.timer.start();
         SpaceSurveyTool.getInstance().show("斯诺星");
         conLevel["door_1"].buttonMode = false;
         conLevel["door_1"].mouseEnabled = false;
         this.mushroom = conLevel["mushroomMC"];
         this.mushroom.gotoAndStop(1);
         this.mushroom.buttonMode = true;
         this.mushroom.addEventListener(MouseEvent.CLICK,this.onClickMushroom);
         i = 0;
         while(i < 6)
         {
            snowName = "snow_" + i;
            mc = conLevel[snowName];
            mc.buttonMode = true;
            mc.gotoAndStop(1);
            mc.addEventListener(MouseEvent.CLICK,this.onClickSnow);
            i++;
         }
         this.listCon = new PetListController(conLevel["manlist"],conLevel["monsterlist"]);
         conLevel["cici_btn"].addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            Alarm.show("每年的这几天是斯诺星最寒冷的时间，入口已经被冰雪堵住了！");
         });
         this.snow_mc = conLevel["snow_mc"];
         this.snow_mc.buttonMode = true;
         this.snow_mc.addEventListener(MouseEvent.CLICK,this.clickSnowMcHandler);
         ToolTipManager.add(this.snow_mc,"米鲁雪地疾走");
         this.iceGameBtn = conLevel["iceGameBtn"];
         this.iceGameBtn.buttonMode = true;
         this.iceGameBtn.addEventListener(MouseEvent.CLICK,this.startIceGame);
         this.thimbleGameBtn = conLevel["thimbleGameBtn"];
         this.thimbleGameBtn.buttonMode = true;
         this.thimbleGameBtn.addEventListener(MouseEvent.CLICK,this.startThimbleGame);
         this.divingGameBtn = conLevel["divingGameBtn"];
         this.divingGameBtn.buttonMode = true;
         this.divingGameBtn.addEventListener(MouseEvent.CLICK,this.startDivingGame);
         ToolTipManager.add(this.iceGameBtn,"智勇闯冰关");
         ToolTipManager.add(this.thimbleGameBtn,"赛尔套圈大赛");
         ToolTipManager.add(this.divingGameBtn,"大脚过木桩");
         this.greenDoor = conLevel["greendoor"];
         this.greenDoor.addEventListener(MouseEvent.CLICK,this.onGreenDoorClickHandler);
         ToolTipManager.add(this.greenDoor,"兑换米鲁套装");
         this.bluedoor = conLevel["bluedoor"];
         this.bluedoor.addEventListener(MouseEvent.CLICK,this.onMiLu1ClickHandler);
         ToolTipManager.add(this.bluedoor,"Hello!米鲁！");
         n = depthLevel["npc"];
      }
      
      private function onGreenDoorClickHandler(param1:MouseEvent) : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getAppModule("MiluClothPanel"),"正在套装兑换面板");
            panel.setup();
            panel.show();
         }
         else
         {
            panel.show();
         }
      }
      
      private function onMiLu1ClickHandler(param1:MouseEvent) : void
      {
         var _arg_1:MouseEvent = param1;
         if(TasksManager.getTaskStatus(463) == TasksManager.COMPLETE)
         {
            Alarm.show("可爱的米鲁已经来到你的身边了！好好照顾它哦！");
         }
         else
         {
            this.milu1 = MapLibManager.getMovieClip("JustinGivePet3");
            DisplayUtil.align(this.milu1,null,AlignType.MIDDLE_CENTER);
            LevelManager.closeMouseEvent();
            this.confirm = this.milu1["ConfirmBtn"];
            this.closeBt = this.milu1["closeBtn"];
            this.closeBt.addEventListener(MouseEvent.CLICK,this.closeMC);
            LevelManager.topLevel.addChild(this.milu1);
            if(MainManager.actorInfo.mapID == 51)
            {
               if(TasksManager.getTaskStatus(463) == TasksManager.UN_ACCEPT)
               {
                  TasksManager.accept(463,function(param1:Boolean):void
                  {
                     TasksManager.setTaskStatus(463,TasksManager.ALR_ACCEPT);
                  });
               }
               this.confirm.addEventListener(MouseEvent.CLICK,this.onMiLu2ClickHandler);
            }
         }
      }
      
      private function onMiLu2ClickHandler(param1:MouseEvent) : void
      {
         this.milu2 = MapLibManager.getMovieClip("JustinGivePet4");
         DisplayUtil.align(this.milu2,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         this.confirm2 = this.milu2["ConfirmBtn"];
         this.refuse = this.milu2["cancelBtn"];
         this.closeBt2 = this.milu2["closeBtn"];
         this.closeBt2.addEventListener(MouseEvent.CLICK,this.closeMC);
         LevelManager.topLevel.addChild(this.milu2);
         this.confirm2.addEventListener(MouseEvent.CLICK,this.Getmilu);
         this.refuse.addEventListener(MouseEvent.CLICK,this.closeMC);
      }
      
      private function Getmilu(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         DisplayUtil.removeForParent(this.milu1,false);
         DisplayUtil.removeForParent(this.milu2,false);
         LevelManager.openMouseEvent();
         if(MainManager.actorInfo.mapID == 51)
         {
            if(TasksManager.getTaskStatus(463) == TasksManager.ALR_ACCEPT)
            {
               TasksManager.complete(463,0,function(param1:Boolean):void
               {
               });
            }
         }
      }
      
      private function closeMC(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.milu1,false);
         DisplayUtil.removeForParent(this.milu2,false);
         LevelManager.openMouseEvent();
      }
      
      private function clickSnowMcHandler(param1:MouseEvent) : void
      {
         this.starGame();
      }
      
      public function starGame() : void
      {
         if(this.gameSwitch)
         {
            return;
         }
         this.gameSwitch = true;
         this.resetGameSwicth();
         SocketConnection.addCmdListener(CommandID.JOIN_GAME,this.onJoin);
         SocketConnection.send(CommandID.JOIN_GAME,3);
      }
      
      public function onBombGameHandler() : void
      {
      }
      
      private function onCompleteHandler(param1:Boolean) : void
      {
      }
      
      private function onJoin(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.JOIN_GAME,this.onJoin);
         var _loc2_:MCLoader = new MCLoader("resource/Games/SnowBallGame.swf",LevelManager.appLevel,1,"正在加载游戏");
         _loc2_.addEventListener(MCLoadEvent.SUCCESS,this.onSuccess);
         _loc2_.doLoad();
      }
      
      private function onSuccess(param1:MCLoadEvent) : void
      {
         this.inSnowGame = true;
         MapManager.destroy();
         this.snowBalldis = param1.getContent();
         LevelManager.gameLevel.addChild(this.snowBalldis);
         this.snowBalldis.addEventListener("outgamenow",this.outSnowBallGame);
      }
      
      private function outSnowBallGame(param1:Event) : void
      {
         var _loc5_:uint = 0;
         if(!this.inSnowGame)
         {
            return;
         }
         this.inSnowGame = false;
         var _loc2_:* = param1.target as Sprite;
         var _loc3_:Object = _loc2_.scoreObj;
         var _loc4_:uint = uint(_loc3_.level) * 10 + 10;
         MapManager.refMap();
         if(_loc4_ > 30 && _loc4_ < 60)
         {
            _loc5_ = 100;
         }
         else if(_loc4_ >= 60 && _loc4_ <= 80)
         {
            _loc5_ = 200;
         }
         else if(_loc4_ > 80)
         {
            _loc5_ = 300;
         }
         SocketConnection.send(CommandID.GAME_OVER,_loc4_,_loc4_);
      }
      
      private function onTimerHandler(param1:TimerEvent) : void
      {
         if(this.timerIndex == this.wordArr.length)
         {
            this.timerIndex = 0;
         }
         var _loc2_:DialogBox = new DialogBox();
         _loc2_.show(this.wordArr[this.timerIndex],10,-45,this.npc["mc"]);
         ++this.timerIndex;
      }
      
      private function onClickSnow(param1:MouseEvent) : void
      {
         var mc:MovieClip = null;
         var evt:MouseEvent = param1;
         mc = null;
         mc = evt.currentTarget as MovieClip;
         mc.buttonMode = false;
         mc.mouseEnabled = false;
         mc.gotoAndStop(2);
         setTimeout(function():void
         {
            TweenLite.to(mc,2,{"alpha":0});
         },1500);
         setTimeout(this.snowBackStatus,3500,mc);
      }
      
      private function snowBackStatus(param1:MovieClip) : void
      {
         var mc:MovieClip = param1;
         mc.gotoAndStop(1);
         TweenLite.to(mc,2,{"alpha":1});
         setTimeout(function():void
         {
            mc.buttonMode = true;
            mc.mouseEnabled = true;
         },3500,mc);
      }
      
      private function onClickMushroom(param1:MouseEvent = null) : void
      {
         var evt:MouseEvent = param1;
         this.mushroom.buttonMode = false;
         this.mushroom.removeEventListener(MouseEvent.CLICK,this.onClickMushroom);
         this.mushroom.gotoAndStop(2);
         setTimeout(function():void
         {
            conLevel["door_1"].buttonMode = true;
            conLevel["door_1"].mouseEnabled = true;
         },2500);
      }
      
      override public function destroy() : void
      {
         this.listCon.destroy();
         this.listCon = null;
         if(Boolean(this.timer))
         {
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimerHandler);
            this.timer = null;
         }
         if(Boolean(this.box))
         {
            this.box.destroy();
            this.box = null;
         }
         SpaceSurveyTool.getInstance().hide();
         DivingGameController.destroy();
      }
      
      private function startIceGame(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         if(this.gameSwitch)
         {
            return;
         }
         this.gameSwitch = true;
         this.resetGameSwicth();
         SocketConnection.addCmdListener(CommandID.JOIN_GAME,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.JOIN_GAME,arguments.callee);
            if(!icePanel)
            {
               icePanel = ModuleManager.getModule(ClientConfig.getGameModule("PetSkateGame"),"正在加载游戏");
               icePanel.setup();
            }
            icePanel.show();
         });
         SocketConnection.send(CommandID.JOIN_GAME,2);
      }
      
      private function startThimbleGame(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         if(this.gameSwitch)
         {
            return;
         }
         this.gameSwitch = true;
         this.resetGameSwicth();
         SocketConnection.addCmdListener(CommandID.JOIN_GAME,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.JOIN_GAME,arguments.callee);
            FerruleGamePanel.getInstance().loadGame();
         });
         SocketConnection.send(CommandID.JOIN_GAME,4);
      }
      
      private function startDivingGame(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         if(this.gameSwitch)
         {
            return;
         }
         this.gameSwitch = true;
         this.resetGameSwicth();
         SocketConnection.addCmdListener(CommandID.JOIN_GAME,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.JOIN_GAME,arguments.callee);
            DivingGameController.showGame();
            EventManager.addEventListener("DivingGame_Pass",passDivingGame);
            EventManager.addEventListener("DivingGame_Over",loseDivingGame);
         });
         SocketConnection.send(CommandID.JOIN_GAME,1);
      }
      
      private function passDivingGame(param1:DynamicEvent) : void
      {
         SocketConnection.send(CommandID.GAME_OVER,100,100);
      }
      
      private function loseDivingGame(param1:DynamicEvent) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = param1.paramObject as uint;
         if(_loc3_ < 4)
         {
            _loc2_ = 0;
         }
         if(_loc3_ >= 4 && _loc3_ < 7)
         {
            _loc2_ = 40;
         }
         if(_loc3_ >= 7 && _loc3_ < 10)
         {
            _loc2_ = 80;
         }
         SocketConnection.send(CommandID.GAME_OVER,_loc2_,_loc2_);
      }
      
      private function resetGameSwicth() : void
      {
         setTimeout(function():void
         {
            gameSwitch = false;
         },1000);
      }
   }
}

