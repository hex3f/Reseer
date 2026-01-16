package com.robot.app.mapProcess
{
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.utils.*;
   
   public class MapProcess_501 extends BaseMapProcess
   {
      
      private var shootMC:MovieClip;
      
      private var mirrorUpMC:MovieClip;
      
      private var mirrorDownMC:MovieClip;
      
      private var bridgeMC:MovieClip;
      
      private var pillarMC:MovieClip;
      
      private var clickCount:uint = 0;
      
      public function MapProcess_501()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:SimpleButton = null;
         this.shootMC = conLevel["shootMC"];
         this.shootMC.buttonMode = true;
         this.shootMC.addEventListener(MouseEvent.CLICK,this.onShootMCHandler);
         this.shootMC.addEventListener(MouseEvent.ROLL_OVER,this.onShootOverHandler);
         this.mirrorUpMC = conLevel["mirrorUpMC"];
         this.mirrorUpMC.buttonMode = true;
         this.mirrorUpMC.addEventListener(MouseEvent.CLICK,this.onMirrorMCHandler);
         this.mirrorDownMC = conLevel["mirrorDownMC"];
         this.mirrorDownMC.buttonMode = true;
         this.mirrorDownMC.addEventListener(MouseEvent.CLICK,this.onMirrorMCHandler);
         this.bridgeMC = conLevel["bridgeMC"];
         this.pillarMC = animatorLevel["pillarMC"];
         var _loc2_:uint = 1;
         while(_loc2_ < 5)
         {
            _loc1_ = conLevel["btn" + _loc2_];
            _loc1_.addEventListener(MouseEvent.CLICK,this.onBtnClickHandler);
            _loc2_++;
         }
         conLevel["door_1"].mouseEnabled = false;
      }
      
      override public function destroy() : void
      {
         var _loc1_:SimpleButton = null;
         var _loc2_:uint = 1;
         while(_loc2_ < 5)
         {
            _loc1_ = conLevel["btn" + _loc2_];
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onBtnClickHandler);
            _loc2_++;
         }
         this.shootMC.removeEventListener(MouseEvent.CLICK,this.onShootMCHandler);
         this.shootMC.removeEventListener(MouseEvent.ROLL_OVER,this.onShootOverHandler);
         this.mirrorUpMC.removeEventListener(MouseEvent.CLICK,this.onMirrorMCHandler);
         this.mirrorDownMC.removeEventListener(MouseEvent.CLICK,this.onMirrorMCHandler);
         if(this.mirrorDownMC.hasEventListener(Event.ENTER_FRAME))
         {
            this.mirrorDownMC.removeEventListener(Event.ENTER_FRAME,this.onMirrorDownMCFrameHandler);
         }
         if(this.mirrorUpMC.hasEventListener(Event.ENTER_FRAME))
         {
            this.mirrorUpMC.removeEventListener(Event.ENTER_FRAME,this.onMirrorUpMCFrameHandler);
         }
         if(this.pillarMC.hasEventListener(Event.ENTER_FRAME))
         {
            this.pillarMC.removeEventListener(Event.ENTER_FRAME,this.onPillarMCFrameHandler);
         }
         if(this.shootMC.hasEventListener(Event.ENTER_FRAME))
         {
            this.shootMC.removeEventListener(Event.ENTER_FRAME,this.onShootMCFrameHandler);
         }
         this.shootMC = null;
         this.mirrorUpMC = null;
         this.mirrorDownMC = null;
         this.bridgeMC = null;
         this.pillarMC = null;
      }
      
      private function onBtnClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:SimpleButton = param1.currentTarget as SimpleButton;
         _loc2_.mouseEnabled = false;
         conLevel["light_" + uint(_loc2_.name.substr(-1,1))].visible = false;
         ++this.clickCount;
         this.checkClickCount();
      }
      
      private function checkClickCount() : void
      {
         if(this.clickCount >= 4)
         {
            conLevel["door_1"].mouseEnabled = true;
         }
      }
      
      private function onPillarMCFrameHandler(param1:Event) : void
      {
         if(this.pillarMC.currentFrame == this.pillarMC.totalFrames)
         {
            this.pillarMC.removeEventListener(Event.ENTER_FRAME,this.onPillarMCFrameHandler);
            this.bridgeMC.gotoAndStop(4);
            DisplayUtil.removeForParent(typeLevel["maskMC"]);
            MapManager.currentMap.makeMapArray();
         }
      }
      
      private function onMirrorDownMCFrameHandler(param1:Event) : void
      {
         if(this.mirrorDownMC.currentFrame == this.mirrorDownMC.totalFrames)
         {
            this.mirrorDownMC.removeEventListener(Event.ENTER_FRAME,this.onMirrorDownMCFrameHandler);
            this.pillarMC.gotoAndPlay(2);
            this.pillarMC.addEventListener(Event.ENTER_FRAME,this.onPillarMCFrameHandler);
         }
      }
      
      private function onMirrorUpMCFrameHandler(param1:Event) : void
      {
         if(this.mirrorUpMC.currentFrame == this.mirrorUpMC.totalFrames)
         {
            this.mirrorUpMC.removeEventListener(Event.ENTER_FRAME,this.onMirrorUpMCFrameHandler);
            if(this.mirrorDownMC.currentLabel == "up" || this.mirrorDownMC.currentLabel == "upstate")
            {
               this.mirrorDownMC.gotoAndPlay("lightup");
               return;
            }
            if(this.mirrorDownMC.currentLabel == "horiz" || this.mirrorDownMC.currentLabel == "horizstate")
            {
               this.mirrorDownMC.gotoAndPlay("lighthoriz");
               return;
            }
            this.mirrorDownMC.gotoAndPlay("lightdown");
            this.mirrorDownMC.addEventListener(Event.ENTER_FRAME,this.onMirrorDownMCFrameHandler);
         }
      }
      
      private function onShootMCFrameHandler(param1:Event) : void
      {
         if(this.shootMC.currentFrame == this.shootMC.totalFrames)
         {
            this.shootMC.removeEventListener(Event.ENTER_FRAME,this.onShootMCFrameHandler);
            if(this.mirrorUpMC.currentLabel == "up" || this.mirrorUpMC.currentLabel == "upstate")
            {
               this.mirrorUpMC.gotoAndPlay("lightup");
               return;
            }
            if(this.mirrorUpMC.currentLabel == "horiz" || this.mirrorUpMC.currentLabel == "horizstate")
            {
               this.mirrorUpMC.gotoAndPlay("lighthoriz");
               return;
            }
            this.mirrorUpMC.gotoAndPlay("lightdown");
            this.mirrorUpMC.addEventListener(Event.ENTER_FRAME,this.onMirrorUpMCFrameHandler);
         }
      }
      
      private function onShootMCHandler(param1:MouseEvent) : void
      {
         this.shootMC.gotoAndPlay("fire");
         this.shootMC.addEventListener(Event.ENTER_FRAME,this.onShootMCFrameHandler);
      }
      
      private function onShootOverHandler(param1:MouseEvent) : void
      {
         this.shootMC.gotoAndPlay(1);
      }
      
      private function onMirrorMCHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         switch(_loc2_.currentLabel)
         {
            case "up":
               _loc2_.gotoAndStop("horiz");
               return;
            case "horiz":
               _loc2_.gotoAndStop("down");
               return;
            case "down":
               _loc2_.gotoAndStop("up");
               return;
            case "upstate":
               _loc2_.gotoAndStop("horiz");
               return;
            case "horizstate":
               _loc2_.gotoAndStop("down");
               return;
            case "downstate":
               _loc2_.gotoAndStop("up");
         }
      }
      
      private function onBridgeMCHandler(param1:MouseEvent) : void
      {
      }
   }
}

