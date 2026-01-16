package com.robot.app.mapProcess
{
   import com.robot.app.sceneInteraction.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.*;
   import flash.events.*;
   import flash.utils.*;
   import org.taomee.utils.*;
   
   public class MapProcess_313 extends BaseMapProcess
   {
      
      private var stelae_0:MovieClip;
      
      private var stelae_1:MovieClip;
      
      private var stelae_2:MovieClip;
      
      private var zhuzi_0:MovieClip;
      
      private var zhuzi_1:MovieClip;
      
      private var clickStelae:MovieClip;
      
      private var hit_0:MovieClip;
      
      private var hit_1:MovieClip;
      
      private var blockHit:MovieClip;
      
      private var blockMC:MovieClip;
      
      private var startArr:Array = [];
      
      private var checkArr:Array = [false,false];
      
      private var isHit:Boolean = false;
      
      private var mcDepth:uint = 0;
      
      public function MapProcess_313()
      {
         super();
      }
      
      override protected function init() : void
      {
         MazeController.setup();
         this.stelae_0 = conLevel["stelae_0"];
         this.stelae_1 = conLevel["stelae_1"];
         this.stelae_0.addEventListener(MouseEvent.CLICK,this.onClickStelae);
         this.stelae_0.buttonMode = true;
         this.stelae_0.mouseChildren = false;
         this.stelae_1.mouseChildren = false;
         this.stelae_0.gotoAndStop(1);
         this.stelae_1.gotoAndStop(1);
         this.hit_0 = conLevel["hit_0"];
         this.hit_1 = conLevel["hit_1"];
         this.stelae_2 = conLevel["stelae_2"];
         this.blockMC = conLevel["blockMC"];
         this.blockMC.gotoAndStop(1);
         this.blockMC.mouseChildren = false;
         this.blockMC.mouseEnabled = false;
         this.zhuzi_0 = conLevel["zhuzi_0"];
         this.zhuzi_1 = conLevel["zhuzi_1"];
         this.blockHit = conLevel["blockHit"];
         this.blockHit.gotoAndStop(1);
         this.blockHit.mouseChildren = false;
         this.blockHit.mouseEnabled = false;
      }
      
      override public function destroy() : void
      {
         MazeController.destroy();
         MainManager.actorModel.removeEventListener(Event.ENTER_FRAME,this.onActorEntFrame);
      }
      
      private function onClickStelae(param1:MouseEvent) : void
      {
         var mc:MovieClip = null;
         var timer:Timer = null;
         var evt:MouseEvent = param1;
         mc = null;
         timer = null;
         mc = evt.currentTarget as MovieClip;
         mc.removeEventListener(MouseEvent.CLICK,this.onClickStelae);
         this.startArr = [mc.x,mc.y];
         mc.gotoAndStop(2);
         this.mcDepth = MapManager.currentMap.controlLevel.getChildIndex(mc);
         timer = new Timer(1200,1);
         timer.addEventListener(TimerEvent.TIMER,function():void
         {
            timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
            timer.stop();
            timer = null;
            MapManager.currentMap.topLevel.addChild(mc);
         });
         mc.addEventListener(MouseEvent.CLICK,this.onStartDragStelae);
      }
      
      private function onStartDragStelae(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.removeEventListener(MouseEvent.CLICK,this.onStartDragStelae);
         _loc2_.addEventListener(Event.ENTER_FRAME,this.dragStelea);
         _loc2_.mouseChildren = false;
         this.clickStelae = _loc2_;
         _loc2_.addEventListener(MouseEvent.CLICK,this.onHitZhuzi);
      }
      
      private function dragStelea(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.x = LevelManager.stage.mouseX;
         _loc2_.y = LevelManager.stage.mouseY + 60;
      }
      
      private function onHitZhuzi(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.removeEventListener(MouseEvent.CLICK,this.onHitZhuzi);
         if(this.clickStelae == null)
         {
            this.clickStelae = _loc2_;
         }
         if(this.clickStelae.hitTestObject(this.hit_0) && this.checkArr[0] == false)
         {
            this.zhuzi_0.gotoAndPlay(2);
            DisplayUtil.removeForParent(this.clickStelae);
            this.checkArr[0] = true;
            this.stelae_1.addEventListener(MouseEvent.CLICK,this.onClickStelae);
            this.stelae_1.buttonMode = true;
         }
         else if(this.clickStelae.hitTestObject(this.hit_1) && this.checkArr[1] == false)
         {
            this.zhuzi_1.gotoAndPlay(2);
            DisplayUtil.removeForParent(this.clickStelae);
            this.checkArr[1] = true;
            this.stelae_1.addEventListener(MouseEvent.CLICK,this.onClickStelae);
            this.stelae_1.buttonMode = true;
         }
         else
         {
            this.clickStelae.removeEventListener(Event.ENTER_FRAME,this.dragStelea);
            MapManager.currentMap.controlLevel.addChildAt(_loc2_,this.mcDepth);
            this.clickStelae.x = this.startArr[0];
            this.clickStelae.y = this.startArr[1];
            this.clickStelae.gotoAndStop(1);
            this.clickStelae.addEventListener(MouseEvent.CLICK,this.onClickStelae);
         }
         if(this.checkArr[0] == true && this.checkArr[1] == true)
         {
            MainManager.actorModel.addEventListener(Event.ENTER_FRAME,this.onActorEntFrame);
            this.blockHit.gotoAndStop(2);
         }
      }
      
      private function onActorEntFrame(param1:Event) : void
      {
         if(MainManager.actorModel.hitTestObject(this.blockHit))
         {
            this.isHit = true;
            this.stelae_2.buttonMode = true;
            this.stelae_2.addEventListener(MouseEvent.CLICK,this.onChangeMap);
         }
         else
         {
            this.isHit = false;
            this.stelae_2.buttonMode = false;
            this.stelae_2.removeEventListener(MouseEvent.CLICK,this.onChangeMap);
         }
      }
      
      private function onChangeMap(param1:MouseEvent) : void
      {
         var timer:Timer = null;
         var evt:MouseEvent = param1;
         timer = null;
         if(this.isHit)
         {
            this.blockMC.gotoAndStop(2);
            MainManager.actorModel.removeEventListener(Event.ENTER_FRAME,this.onActorEntFrame);
            timer = new Timer(500,1);
            timer.addEventListener(TimerEvent.TIMER,function():void
            {
               timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
               timer.stop();
               timer = null;
               MapManager.changeMap(315);
            });
            timer.start();
         }
      }
   }
}

