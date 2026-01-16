package com.robot.app.mapProcess
{
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.events.*;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.utils.*;
   
   public class MapProcess_326 extends BaseMapProcess
   {
      
      private var my_timedProcess:Number;
      
      private var my_timedProcess2:Number;
      
      private var stoneChannel:SoundChannel;
      
      public function MapProcess_326()
      {
         super();
      }
      
      override protected function init() : void
      {
         conLevel["npcMC"].visible = false;
         conLevel["weisikeMC"].visible = false;
         conLevel["haidaoMC"].visible = false;
         this.initForAll();
      }
      
      private function initForAll() : void
      {
         conLevel["icon" + 0].buttonMode = true;
         conLevel["icon" + 0].addEventListener(MouseEvent.MOUSE_DOWN,this.startDr);
         conLevel["icon" + 0].addEventListener(MouseEvent.MOUSE_UP,this.stopDr);
         var _loc1_:uint = 1;
         while(_loc1_ < 3)
         {
            conLevel["icon" + _loc1_]["mc"].gotoAndStop(1);
            _loc1_++;
         }
         animatorLevel["anmain"]["mc"].gotoAndStop(1);
         var _loc2_:uint = 1;
         while(_loc2_ < 7)
         {
            conLevel["soundPlay" + _loc2_].gotoAndStop(1);
            conLevel["soundPlay" + _loc2_].buttonMode = true;
            conLevel["soundPlay" + _loc2_].addEventListener(MouseEvent.CLICK,this.soudPlay);
            _loc2_++;
         }
      }
      
      private function startDr(param1:MouseEvent) : void
      {
         param1.currentTarget.startDrag();
      }
      
      private function stopDr(param1:MouseEvent) : void
      {
         var _loc2_:Sound = null;
         var _loc3_:Sound = null;
         var _loc5_:uint = 0;
         param1.currentTarget.stopDrag();
         var _loc4_:String = param1.currentTarget.name;
         _loc4_ = _loc4_.substr(4,_loc4_.length);
         while(_loc5_ < 3)
         {
            if(Boolean(conLevel["icon" + _loc4_].hitTestObject(conLevel["Nicon" + _loc5_])))
            {
               if(uint(_loc4_) == _loc5_)
               {
                  _loc2_ = MapLibManager.getSound("downStone");
                  this.stoneChannel = _loc2_.play();
                  this.stoneChannel.addEventListener(Event.SOUND_COMPLETE,this.otherSound);
                  param1.currentTarget["mc"].gotoAndPlay(2);
                  if(_loc5_ == 0)
                  {
                     param1.currentTarget.x = 383;
                     param1.currentTarget.y = 425;
                     conLevel["icon" + 0].mouseEnabled = false;
                     conLevel["icon" + 0].mouseChildren = false;
                     conLevel["icon" + 0].removeEventListener(MouseEvent.MOUSE_DOWN,this.startDr);
                     conLevel["icon" + 0].removeEventListener(MouseEvent.MOUSE_UP,this.stopDr);
                     conLevel["icon" + 1].buttonMode = true;
                     conLevel["icon" + 1]["mc"].gotoAndStop(1);
                     conLevel["icon" + 1].addEventListener(MouseEvent.MOUSE_DOWN,this.startDr);
                     conLevel["icon" + 1].addEventListener(MouseEvent.MOUSE_UP,this.stopDr);
                     return;
                  }
                  if(_loc5_ == 1)
                  {
                     param1.currentTarget.x = 577;
                     param1.currentTarget.y = 465;
                     conLevel["icon" + 1].mouseEnabled = false;
                     conLevel["icon" + 1].mouseChildren = false;
                     conLevel["icon" + 1].removeEventListener(MouseEvent.MOUSE_DOWN,this.startDr);
                     conLevel["icon" + 1].removeEventListener(MouseEvent.MOUSE_UP,this.stopDr);
                     conLevel["icon" + 2].buttonMode = true;
                     conLevel["icon" + 2]["mc"].gotoAndStop(1);
                     conLevel["icon" + 2].addEventListener(MouseEvent.MOUSE_DOWN,this.startDr);
                     conLevel["icon" + 2].addEventListener(MouseEvent.MOUSE_UP,this.stopDr);
                     return;
                  }
                  this.stoneChannel.removeEventListener(Event.SOUND_COMPLETE,this.otherSound);
                  param1.currentTarget.x = 748;
                  param1.currentTarget.y = 326;
                  _loc3_ = MapLibManager.getSound("openStone");
                  _loc3_.play();
                  conLevel["icon" + 2].mouseEnabled = false;
                  conLevel["icon" + 2].mouseChildren = false;
                  conLevel["icon" + 2].removeEventListener(MouseEvent.MOUSE_DOWN,this.startDr);
                  conLevel["icon" + 2].removeEventListener(MouseEvent.MOUSE_UP,this.stopDr);
                  LevelManager.closeMouseEvent();
                  this.my_timedProcess = setTimeout(this.setTime1,2000);
                  return;
               }
            }
            _loc5_++;
         }
      }
      
      private function otherSound(param1:Event) : void
      {
         this.stoneChannel.removeEventListener(Event.SOUND_COMPLETE,this.otherSound);
         var _loc2_:Sound = MapLibManager.getSound("lightSound");
         _loc2_.play();
      }
      
      private function setTime1() : void
      {
         clearTimeout(this.my_timedProcess);
         animatorLevel["anmain"]["mc"].gotoAndPlay(1);
         animatorLevel["anmain"].gotoAndPlay(2);
         this.my_timedProcess2 = setTimeout(this.setTime2,5000);
      }
      
      private function setTime2() : void
      {
         LevelManager.openMouseEvent();
         clearTimeout(this.my_timedProcess2);
         MapManager.changeMap(327);
      }
      
      private function soudPlay(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.name;
         _loc2_ = _loc2_.substr(9,_loc2_.length);
         var _loc3_:uint = uint(_loc2_);
         conLevel["soundPlay" + _loc3_].gotoAndPlay(1);
         var _loc4_:Sound = MapLibManager.getSound("oneSound" + _loc3_);
         _loc4_.play();
      }
      
      private function destroyForAll() : void
      {
         var _loc1_:uint = 1;
         while(_loc1_ < 7)
         {
            conLevel["soundPlay" + _loc1_].removeEventListener(MouseEvent.CLICK,this.soudPlay);
            _loc1_++;
         }
         if(Boolean(this.stoneChannel))
         {
            this.stoneChannel.removeEventListener(Event.SOUND_COMPLETE,this.otherSound);
            this.stoneChannel.stop();
            this.stoneChannel = null;
         }
         if(this.my_timedProcess > 0)
         {
            clearTimeout(this.my_timedProcess);
            this.my_timedProcess = 0;
         }
         if(this.my_timedProcess2 > 0)
         {
            clearTimeout(this.my_timedProcess2);
            this.my_timedProcess2 = 0;
         }
      }
      
      override public function destroy() : void
      {
         this.destroyForAll();
      }
   }
}

