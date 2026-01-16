package com.robot.app.mapProcess
{
   import com.robot.core.animate.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.ui.alert.*;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import org.taomee.utils.*;
   
   public class MapProcess_331 extends BaseMapProcess
   {
      
      private var startBtn:SimpleButton;
      
      private var bridge:MovieClip;
      
      private var bridgeSound:Sound;
      
      private var bridgeChannel:SoundChannel;
      
      private var _markMc:MovieClip;
      
      private var _gameApp:AppModel;
      
      public function MapProcess_331()
      {
         super();
      }
      
      override protected function init() : void
      {
         conLevel["haidaoBtn"].visible = false;
         var _loc1_:int = 1;
         while(_loc1_ < 6)
         {
            animatorLevel["ai_" + _loc1_].visible = false;
            _loc1_++;
         }
         animatorLevel["shipMc"].visible = false;
         this.startBtn = conLevel["startMc"];
         this.startBtn.mouseEnabled = false;
         this.bridge = animatorLevel["bridgeMc"];
         this.bridge.gotoAndStop(1);
         this.startBtn.addEventListener(MouseEvent.CLICK,this.startBridge);
         this.startBtn.mouseEnabled = true;
      }
      
      private function startBridge(param1:MouseEvent) : void
      {
         this.startBtn.mouseEnabled = false;
         this.bridgeSound = MapLibManager.getSound("brigeSound");
         this.bridgeChannel = this.bridgeSound.play();
         this.bridge.gotoAndPlay(1);
         this.bridge.addEventListener(Event.ENTER_FRAME,this.stopBridge);
      }
      
      private function stopBridge(param1:Event) : void
      {
         if(this.bridge.currentFrame == this.bridge.totalFrames)
         {
            if(Boolean(this.bridgeChannel))
            {
               this.bridgeChannel.stop();
               this.bridgeChannel = null;
            }
            this.bridge.removeEventListener(Event.ENTER_FRAME,this.stopBridge);
            DisplayUtil.removeForParent(typeLevel["areaMC"]);
            MapManager.currentMap.makeMapArray();
         }
      }
      
      override public function destroy() : void
      {
         if(Boolean(this.bridgeChannel))
         {
            this.bridgeChannel.stop();
            this.bridgeChannel = null;
         }
         this.bridge.removeEventListener(Event.ENTER_FRAME,this.stopBridge);
      }
      
      public function changeMap() : void
      {
         Alarm.show("塔内还存在一些不稳定因素！切勿靠近！");
      }
   }
}

