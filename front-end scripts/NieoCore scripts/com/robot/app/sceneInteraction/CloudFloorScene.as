package com.robot.app.sceneInteraction
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import gs.TweenLite;
   
   public class CloudFloorScene
   {
      
      private static var kettleMC:MovieClip;
      
      private static var switchMC:MovieClip;
      
      private static var k1:MovieClip;
      
      private static var k2:MovieClip;
      
      private static var step:String = "1";
      
      public function CloudFloorScene()
      {
         super();
      }
      
      public static function start() : void
      {
         step = "1";
         var _loc1_:MovieClip = MapManager.currentMap.controlLevel["hitKMC"] as MovieClip;
         MapManager.currentMap.controlLevel.removeChild(_loc1_);
         _loc1_ = null;
         kettleMC = MapManager.currentMap.controlLevel["kettleMC"] as MovieClip;
         switchMC = MapManager.currentMap.controlLevel["switchMC"] as MovieClip;
         switchMC.buttonMode = true;
         switchMC.mouseEnabled = true;
         switchMC.addEventListener(MouseEvent.CLICK,onClick);
         if(kettleMC.currentFrame == 1)
         {
            k1 = kettleMC["k1"];
         }
         k1.gotoAndPlay(2);
         k1.addEventListener(Event.ENTER_FRAME,onEnter);
      }
      
      private static function onEnter(param1:Event) : void
      {
         if(step == "1")
         {
            if(k1.currentLabel == "first")
            {
               k1.removeEventListener(Event.ENTER_FRAME,onEnter);
               k1.stop();
               step = "2";
            }
         }
         else if(step == "2")
         {
            if(k1.currentLabel == "second")
            {
               k1.removeEventListener(Event.ENTER_FRAME,onEnter);
               k1.stop();
               step = "3";
            }
         }
         else if(step == "3")
         {
            if(k1.currentFrame == k1.totalFrames)
            {
               k1.removeEventListener(Event.ENTER_FRAME,onEnter);
               k1.stop();
               kettleMC.gotoAndStop(2);
               kettleMC.addEventListener(Event.ENTER_FRAME,onEnterKettle);
            }
         }
      }
      
      private static function onEnterKettle(param1:Event) : void
      {
         if(kettleMC.currentFrame == 2)
         {
            k2 = kettleMC["k2"] as MovieClip;
            if(Boolean(k2))
            {
               kettleMC.removeEventListener(Event.ENTER_FRAME,onEnterKettle);
               k2.addEventListener(Event.ENTER_FRAME,onEnterK2);
            }
         }
      }
      
      public static function destroy() : void
      {
         if(Boolean(switchMC))
         {
            switchMC.removeEventListener(MouseEvent.CLICK,onClick);
            switchMC = null;
         }
         if(Boolean(k1))
         {
            k1.removeEventListener(Event.ENTER_FRAME,onEnter);
            k1 = null;
         }
         if(Boolean(k2))
         {
            k2.removeEventListener(Event.ENTER_FRAME,onEnterK2);
            k2 = null;
         }
      }
      
      private static function onEnterK2(param1:Event) : void
      {
         if(k2.currentLabel == "start")
         {
            k2.removeEventListener(Event.ENTER_FRAME,onEnterK2);
            MainManager.actorModel.sprite.x = 208;
            MainManager.actorModel.sprite.y -= 10;
            TweenLite.to(MainManager.actorModel.sprite,1,{
               "y":-30,
               "onComplete":changeMap
            });
         }
      }
      
      private static function changeMap() : void
      {
         MapManager.changeMap(26);
      }
      
      private static function onClick(param1:Event) : void
      {
         k1.play();
         k1.addEventListener(Event.ENTER_FRAME,onEnter);
      }
   }
}

