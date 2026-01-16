package com.robot.app.games.FerruleGame
{
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.DialogBox;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import org.taomee.utils.DisplayUtil;
   
   public class FerruleGamePanel
   {
      
      private static var _instance:FerruleGamePanel;
      
      private var PATH:String = "resource/Games/FerruleGame.swf";
      
      private var loader:MCLoader;
      
      private var curGame:MovieClip;
      
      private var gamePanel:MovieClip;
      
      private var _closeBtn:SimpleButton;
      
      private var _startBtn:SimpleButton;
      
      private var _miluMC:MovieClip;
      
      private var _seer1MC:MovieClip;
      
      private var _seer2MC:MovieClip;
      
      private var _seer3MC:MovieClip;
      
      private var _balakeMC:MovieClip;
      
      private var _circleClass:Class;
      
      private var _circleTipClass:Class;
      
      private var _circleMC:MovieClip;
      
      private var _bgMC:MovieClip;
      
      private var _txt:TextField;
      
      private var _tipMC:MovieClip;
      
      private var circleCount:uint = 10;
      
      private var seer1Count:uint = 1;
      
      private var seer2Count:uint = 1;
      
      private var seer3Count:uint = 1;
      
      private var speed:uint = 8;
      
      private var score:uint = 0;
      
      private var box:DialogBox;
      
      private var timer:Timer;
      
      private var directnum:int = 1;
      
      private var directbalake:int = 1;
      
      private var isThrow:Boolean = false;
      
      private var isHit:Boolean = false;
      
      private var angel:Number = 0;
      
      public function FerruleGamePanel()
      {
         super();
      }
      
      public static function getInstance() : FerruleGamePanel
      {
         if(!_instance)
         {
            _instance = new FerruleGamePanel();
         }
         return _instance;
      }
      
      public function loadGame() : void
      {
         this.loader = new MCLoader(this.PATH,LevelManager.topLevel,1,"正在加载趣味圈圈小游戏");
         this.loader.addEventListener(MCLoadEvent.SUCCESS,this.onLoad);
         this.loader.doLoad();
      }
      
      private function onLoad(param1:MCLoadEvent) : void
      {
         this.loader.removeEventListener(MCLoadEvent.SUCCESS,this.onLoad);
         LevelManager.topLevel.addChild(param1.getContent());
         this.curGame = param1.getContent() as MovieClip;
         this.gamePanel = this.curGame["MainGamePanel"];
         this.gamePanel.addEventListener("CLOSEGAME",this.onGameCloseHandler);
         this.gamePanel.addEventListener("CLOSENAME1",this.onGameCloseHandler);
         this.gamePanel.addEventListener("CLOSENAME2",this.onGameCloseHandler);
         this.gamePanel.addEventListener("BEGAINAME",this.onBegainGameHandler);
         this._startBtn = this.gamePanel["start_btn"];
         this._startBtn.addEventListener(MouseEvent.CLICK,this.onStartClickHandler);
      }
      
      private function onBegainGameHandler(param1:Event) : void
      {
         this.gamePanel.removeEventListener("BEGAINAME",this.onBegainGameHandler);
         this.gamePanel.gotoAndStop(2);
         setTimeout(this.init,300);
      }
      
      private function onGameCloseHandler(param1:Event) : void
      {
         this.remove();
      }
      
      private function onStartClickHandler(param1:MouseEvent) : void
      {
         this._startBtn.removeEventListener(MouseEvent.CLICK,this.onStartClickHandler);
         this.gamePanel.gotoAndStop(2);
         setTimeout(this.init,300);
      }
      
      private function init() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = null;
         this._txt = this.gamePanel["txt"];
         this._txt.text = this.score.toString();
         this._miluMC = this.gamePanel["milu"];
         this._seer1MC = this.gamePanel["seer1"];
         this._seer2MC = this.gamePanel["seer2"];
         this._seer3MC = this.gamePanel["seer3"];
         this._balakeMC = this.gamePanel["balake"];
         this._closeBtn = this.gamePanel["close_btn1"];
         this._tipMC = this.gamePanel["tip"];
         this._balakeMC.gotoAndStop(1);
         this._bgMC = this.gamePanel["bg"];
         this._circleClass = this.loader.loader.contentLoaderInfo.applicationDomain.getDefinition("CircleMC") as Class;
         var _loc2_:Number = 0;
         while(_loc2_ < this.circleCount)
         {
            this._circleTipClass = this.loader.loader.contentLoaderInfo.applicationDomain.getDefinition("circletip") as Class;
            _loc1_ = new this._circleTipClass() as MovieClip;
            _loc1_.scaleX = 0.3;
            _loc1_.scaleY = 0.3;
            _loc1_.x = _loc2_ * 20;
            this._tipMC.addChild(_loc1_);
            _loc2_++;
         }
         this.timer = new Timer(7000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this.timer.start();
         this.addEvent();
      }
      
      private function onTimerHandler(param1:TimerEvent) : void
      {
         this.box = new DialogBox();
         this.box.scaleX = 2;
         this.box.scaleY = 2;
         this.box.show("喂！你要是套到我，我就扣你10分！！！",0,-80,this._balakeMC);
      }
      
      private function addEvent() : void
      {
         this.gamePanel.addEventListener(Event.ENTER_FRAME,this.onFrameHandler);
         this.gamePanel.addEventListener(MouseEvent.CLICK,this.onGamePanelClickHandler);
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseHandler);
      }
      
      private function removeEvent() : void
      {
         this.gamePanel.removeEventListener(Event.ENTER_FRAME,this.onFrameHandler);
         this.gamePanel.removeEventListener(MouseEvent.CLICK,this.onGamePanelClickHandler);
         if(Boolean(this._closeBtn))
         {
            this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onCloseHandler);
         }
      }
      
      private function onCloseHandler(param1:MouseEvent) : void
      {
         this.remove();
      }
      
      private function onFrameHandler(param1:Event) : void
      {
         if(!this.isThrow)
         {
            this._miluMC.rotation += 5 * this.directnum;
            if(this._miluMC.rotation > 60)
            {
               this.directnum = -1;
            }
            else if(this._miluMC.rotation < -60)
            {
               this.directnum = 1;
            }
         }
         if(!this.isHit)
         {
            this._balakeMC.x += 3 * this.directbalake;
            if(this._balakeMC.x > 960)
            {
               this.directbalake = -1;
               this._balakeMC.gotoAndStop(2);
            }
            else if(this._balakeMC.x < 0)
            {
               this.directbalake = 1;
               this._balakeMC.gotoAndStop(1);
            }
         }
      }
      
      private function onGamePanelClickHandler(param1:MouseEvent) : void
      {
         if(!this.isThrow)
         {
            this.isThrow = true;
            this._miluMC.gotoAndStop(2);
            this._miluMC.addEventListener("ShowCircleNow",this.onShowCircleHandler);
            --this.circleCount;
            this._tipMC.removeChildAt(this.circleCount + 1);
         }
      }
      
      private function onShowCircleHandler(param1:Event) : void
      {
         this._miluMC.removeEventListener("ShowCircleNow",this.onShowCircleHandler);
         this._circleMC = new this._circleClass() as MovieClip;
         this.angel = this._miluMC.rotation * Math.PI / 180;
         this._circleMC.x = this._miluMC.x + Math.sin(this.angel) * this._miluMC.height;
         this._circleMC.y = this._miluMC.y - Math.cos(this.angel) * this._miluMC.height;
         this.gamePanel.addChildAt(this._circleMC,this.gamePanel.numChildren - 1);
         this.circleRun();
      }
      
      private function circleRun() : void
      {
         this._circleMC.addEventListener(Event.ENTER_FRAME,this.onCircleFrameHandler);
      }
      
      private function onCircleFrameHandler(param1:Event) : void
      {
         this._circleMC.x += Math.sin(this.angel) * this.speed;
         this._circleMC.y -= Math.cos(this.angel) * this.speed;
         this.circleHit();
      }
      
      private function onCircleMCEffectEndHandler(param1:Event) : void
      {
         this.circleStop();
         this.miluReuse();
      }
      
      private function onbalakeMCEffectEndHandler(param1:Event) : void
      {
         this.isHit = false;
         if(this.directbalake > 0)
         {
            this._balakeMC.gotoAndStop(1);
         }
         else
         {
            this._balakeMC.gotoAndStop(2);
         }
         this.miluReuse();
      }
      
      private function onSeerMCEffectEndHandler(param1:Event) : void
      {
         this.miluReuse();
      }
      
      private function circleHit() : void
      {
         if(HitTest.complexHitTestObject(this._circleMC,this._seer1MC).width > 0)
         {
            this.score += 20;
            this._txt.text = this.score.toString();
            ++this.seer1Count;
            this._seer1MC.gotoAndStop(this.seer1Count);
            this._seer1MC.addEventListener("EffectEnd",this.onSeerMCEffectEndHandler);
            this.circleStop();
            return;
         }
         if(HitTest.complexHitTestObject(this._circleMC,this._seer2MC).width > 0)
         {
            ++this.seer2Count;
            this.score += 30;
            this._txt.text = this.score.toString();
            this._seer2MC.gotoAndStop(this.seer2Count);
            this._seer2MC.addEventListener("EffectEnd",this.onSeerMCEffectEndHandler);
            this.circleStop();
            return;
         }
         if(HitTest.complexHitTestObject(this._circleMC,this._seer3MC).width > 0)
         {
            ++this.seer3Count;
            this.score += 10;
            this._txt.text = this.score.toString();
            this._seer3MC.gotoAndStop(this.seer3Count);
            this._seer3MC.addEventListener("EffectEnd",this.onSeerMCEffectEndHandler);
            this.circleStop();
            return;
         }
         if(HitTest.complexHitTestObject(this._circleMC,this._balakeMC).width > 0)
         {
            this.isHit = true;
            if(this.directbalake > 0)
            {
               this._balakeMC.gotoAndStop(3);
               this._balakeMC.addEventListener("EffectEnd",this.onbalakeMCEffectEndHandler);
            }
            else
            {
               this._balakeMC.gotoAndStop(4);
               this._balakeMC.addEventListener("EffectEnd",this.onbalakeMCEffectEndHandler);
            }
            this.circleStop();
            if(this.score > 0)
            {
               this.score -= 10;
               this._txt.text = this.score.toString();
            }
            return;
         }
         if(HitTest.complexHitTestObject(this._circleMC,this.gamePanel["bg1"]).width > 0 || HitTest.complexHitTestObject(this._circleMC,this._bgMC).width > 0 || HitTest.complexHitTestObject(this._circleMC,this.gamePanel["bg2"]).width > 0)
         {
            this._circleMC.removeEventListener(Event.ENTER_FRAME,this.onCircleFrameHandler);
            this._circleMC.gotoAndStop(2);
            this._circleMC.addEventListener("EffectEnd",this.onCircleMCEffectEndHandler);
            return;
         }
      }
      
      private function circleStop() : void
      {
         if(this._circleMC.hasEventListener(Event.ENTER_FRAME))
         {
            this._circleMC.removeEventListener(Event.ENTER_FRAME,this.onCircleFrameHandler);
         }
         DisplayUtil.removeForParent(this._circleMC);
         if(this.circleCount == 0)
         {
            this.gamePanel.gotoAndStop(4);
         }
      }
      
      private function miluReuse() : void
      {
         this.isThrow = false;
         this._miluMC.gotoAndStop(1);
      }
      
      private function remove(param1:Boolean = false) : void
      {
         SocketConnection.send(CommandID.GAME_OVER,Math.ceil(this.score / 3),this.score);
         this.removeEvent();
         this.gamePanel.removeEventListener("CLOSEGAME",this.onGameCloseHandler);
         this.gamePanel.removeEventListener("CLOSENAME1",this.onGameCloseHandler);
         this._startBtn.removeEventListener(MouseEvent.CLICK,this.onStartClickHandler);
         LevelManager.topLevel.removeChild(this.curGame);
         this.destroy();
      }
      
      private function destroy() : void
      {
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
         this.loader = null;
         _instance = null;
      }
   }
}

