package com.robot.app.mapProcess
{
   import com.robot.app.buyItem.ItemAction;
   import com.robot.app.energy.utils.EnergyController;
   import com.robot.app.fightNote.*;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.BasePeoleModel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_404 extends BaseMapProcess
   {
      
      private var _greenOne:MovieClip;
      
      private var _blueOne:MovieClip;
      
      private var _redOne:MovieClip;
      
      private var _btnDisk:MovieClip;
      
      private var _btnHole:MovieClip;
      
      private var _tailMC:MovieClip;
      
      private var _bossAppearMovie:MovieClip;
      
      private var _ftWithBossMC:MovieClip;
      
      private var _progBarMC:MovieClip;
      
      private var _handMC:MovieClip;
      
      private var _frameTimer:Timer;
      
      private var _clickFrame:int = 1;
      
      public function MapProcess_404()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._greenOne = conLevel["greenOne"];
         this._blueOne = btnLevel["blueOne"];
         this._redOne = conLevel["redOne"];
         this._btnDisk = conLevel["btnDisk"];
         this._btnHole = conLevel["btnHole"];
         this._greenOne.buttonMode = true;
         this._blueOne.buttonMode = true;
         this._redOne.buttonMode = true;
         this._btnDisk.buttonMode = true;
         this._btnHole.buttonMode = true;
         this._btnHole.stop();
         this._btnDisk.gotoAndStop(2);
         this.addListener();
         EventManager.addEventListener(RobotEvent.CREATED_MAP_USER,this.onUserHandler);
         this.initCatchBoss();
      }
      
      private function onUserHandler(param1:RobotEvent) : void
      {
         this.configModel(0.4,1.2);
      }
      
      private function configModel(param1:Number, param2:Number) : void
      {
         var _loc3_:BasePeoleModel = null;
         MainManager.actorModel.scaleX = MainManager.actorModel.scaleY = param1;
         if(Boolean(MainManager.actorModel.pet))
         {
            MainManager.actorModel.pet.scaleX = MainManager.actorModel.pet.scaleY = param2;
         }
         for each(_loc3_ in UserManager.getUserModelList())
         {
            if(Boolean(_loc3_))
            {
               _loc3_.scaleX = _loc3_.scaleY = param1;
               if(Boolean(_loc3_.pet))
               {
                  _loc3_.pet.scaleX = _loc3_.pet.scaleY = param2;
               }
            }
         }
      }
      
      private function addListener() : void
      {
         this._blueOne.addEventListener(MouseEvent.CLICK,this.onClickHandler(6));
         this._blueOne.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
         this._blueOne.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         this._redOne.addEventListener(MouseEvent.CLICK,this.onClickHandler(7));
         this._redOne.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
         this._redOne.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         this._greenOne.addEventListener(MouseEvent.CLICK,this.onClickHandler(8));
         this._greenOne.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
         this._greenOne.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         this._btnHole.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
         this._btnHole.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
      }
      
      private function onClickMoveHandler(param1:MouseEvent) : void
      {
         MapManager.changeMap(414);
      }
      
      private function onClickHandler(param1:int) : Function
      {
         var _i:int = 0;
         _i = param1;
         var func:Function = function(param1:Event):void
         {
            ItemAction.buyItem(600000 + _i,false);
         };
         return func;
      }
      
      private function onRollOverHandler(param1:MouseEvent) : void
      {
         (param1.target as MovieClip).gotoAndStop(2);
      }
      
      private function onRollOutHandler(param1:MouseEvent) : void
      {
         (param1.target as MovieClip).gotoAndStop(1);
      }
      
      private function removeListener() : void
      {
         if(Boolean(this._blueOne))
         {
            this._blueOne.removeEventListener(MouseEvent.CLICK,this.onClickHandler(6));
            this._blueOne.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
            this._blueOne.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         }
         if(Boolean(this._redOne))
         {
            this._redOne.removeEventListener(MouseEvent.CLICK,this.onClickHandler(7));
            this._redOne.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
            this._redOne.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         }
         if(Boolean(this._greenOne))
         {
            this._greenOne.removeEventListener(MouseEvent.CLICK,this.onClickHandler(8));
            this._greenOne.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
            this._greenOne.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         }
         if(Boolean(this._btnHole))
         {
            this._btnHole.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
            this._btnHole.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         }
      }
      
      override public function destroy() : void
      {
         MainManager.actorModel.scaleX = MainManager.actorModel.scaleY = 1;
         if(Boolean(MainManager.actorModel.pet))
         {
            MainManager.actorModel.pet.scaleX = MainManager.actorModel.pet.scaleY = 1;
         }
         EventManager.removeEventListener(RobotEvent.CREATED_MAP_USER,this.onUserHandler);
         this.removeListener();
         this._greenOne = null;
         this._blueOne = null;
         this._redOne = null;
         this.reset();
         this._frameTimer.removeEventListener(TimerEvent.TIMER,this.onFrameTimer);
      }
      
      private function initCatchBoss() : void
      {
         this._tailMC = conLevel["tailMC"];
         this._tailMC.gotoAndStop(1);
         this._tailMC.buttonMode = true;
         this._tailMC.addEventListener(MouseEvent.MOUSE_OVER,this.onTailMosOver);
         this._tailMC.addEventListener(MouseEvent.MOUSE_OUT,this.onTailMosOut);
         this._tailMC.addEventListener(MouseEvent.CLICK,this.onTailClick);
         this._bossAppearMovie = animatorLevel["bossAppearMovie"];
         this._bossAppearMovie.visible = false;
         this._ftWithBossMC = conLevel["ftWithBossMC"];
         this._progBarMC = MapLibManager.getMovieClip("ProgBarMC");
         this._handMC = MapLibManager.getMovieClip("CatchHandMC");
         this._frameTimer = new Timer(300);
         this._frameTimer.addEventListener(TimerEvent.TIMER,this.onFrameTimer);
      }
      
      private function onTailMosOver(param1:MouseEvent) : void
      {
         this.showHand();
      }
      
      private function onTailMosOut(param1:MouseEvent = null) : void
      {
         this.reset();
      }
      
      private function reset() : void
      {
         this._tailMC.gotoAndStop(1);
         this._clickFrame = 1;
         this._frameTimer.stop();
         this.hideHand();
         DisplayUtil.removeForParent(this._progBarMC,false);
      }
      
      private function onFrameTimer(param1:TimerEvent) : void
      {
         --this._clickFrame;
         this._progBarMC.gotoAndStop(this._clickFrame);
         this._tailMC.gotoAndStop(Math.floor(this._clickFrame / 2));
         if(this._clickFrame < 1)
         {
            this.reset();
         }
      }
      
      private function onTailClick(param1:MouseEvent) : void
      {
         this._tailMC.gotoAndStop(Math.ceil(this._clickFrame / 2));
         this.showProgBar();
         this._clickFrame += 2;
         this._frameTimer.start();
      }
      
      private function showProgBar() : void
      {
         topLevel.addChild(this._progBarMC);
         this._progBarMC.x = 228;
         this._progBarMC.y = 135;
         this._progBarMC.gotoAndStop(this._clickFrame);
         if(this._clickFrame >= this._progBarMC.totalFrames)
         {
            this._clickFrame = 1;
            this.showBoss();
         }
      }
      
      private function showHand() : void
      {
         MainManager.getStage().addChild(this._handMC);
         this._handMC.mouseEnabled = false;
         this._handMC.mouseChildren = false;
         this._handMC.addEventListener(Event.ENTER_FRAME,this.onHandEntFrame);
         Mouse.hide();
      }
      
      private function onHandEntFrame(param1:Event) : void
      {
         this._handMC.x = MainManager.getStage().mouseX;
         this._handMC.y = MainManager.getStage().mouseY;
      }
      
      private function hideHand() : void
      {
         this._handMC.removeEventListener(Event.ENTER_FRAME,this.onHandEntFrame);
         DisplayUtil.removeForParent(this._handMC,false);
         Mouse.show();
      }
      
      private function showBoss() : void
      {
         this.reset();
         DisplayUtil.removeForParent(this._tailMC);
         this._bossAppearMovie.visible = true;
         AnimateManager.playMcAnimate(this._bossAppearMovie,0,"",function():void
         {
            _ftWithBossMC.buttonMode = true;
            _ftWithBossMC.addEventListener(MouseEvent.CLICK,onFtWithBoss);
         });
      }
      
      private function onFtWithBoss(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("霹雳兽",0);
      }
      
      public function exploitOre() : void
      {
         EnergyController.exploit(32);
      }
   }
}

