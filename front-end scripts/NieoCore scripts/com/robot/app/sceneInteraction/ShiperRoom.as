package com.robot.app.sceneInteraction
{
   import com.robot.core.manager.MapManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class ShiperRoom
   {
      
      private static var firTVMC:MovieClip;
      
      private static var secTVMC:MovieClip;
      
      private static var redBtn:SimpleButton;
      
      private static var blueBtn:SimpleButton;
      
      private static var greenBtn:SimpleButton;
      
      private static var yellowBtn:SimpleButton;
      
      private static var npcMc:MovieClip;
      
      private static var isGreen:Boolean;
      
      private static var isYellow:Boolean;
      
      private static var isBlue:Boolean;
      
      private static var colorMC:MovieClip;
      
      public function ShiperRoom()
      {
         super();
      }
      
      public static function start() : void
      {
         var _loc1_:SimpleButton = MapManager.currentMap.controlLevel["startBtn"] as SimpleButton;
         _loc1_.addEventListener(MouseEvent.CLICK,showColorPanel);
         firTVMC = MapManager.currentMap.controlLevel["firstTV"] as MovieClip;
         firTVMC.addEventListener(MouseEvent.MOUSE_OVER,onOver);
         firTVMC.buttonMode = true;
         firTVMC.mouseChildren = false;
         firTVMC.addEventListener(MouseEvent.MOUSE_OUT,onOut1);
         DisplayUtil.stopAllMovieClip(firTVMC);
         var _loc2_:SimpleButton = MapManager.currentMap.controlLevel["firTVBtn"] as SimpleButton;
         _loc2_.addEventListener(MouseEvent.CLICK,showFTV);
         secTVMC = MapManager.currentMap.controlLevel["tv2"] as MovieClip;
         secTVMC.buttonMode = true;
         DisplayUtil.stopAllMovieClip(secTVMC);
         secTVMC.mouseChildren = false;
         secTVMC.addEventListener(MouseEvent.MOUSE_OVER,onOver2);
         secTVMC.addEventListener(MouseEvent.MOUSE_OUT,onOut2);
         var _loc3_:SimpleButton = MapManager.currentMap.controlLevel["secTVBtn"] as SimpleButton;
         _loc3_.addEventListener(MouseEvent.CLICK,showSTV);
      }
      
      public static function destroy() : void
      {
         firTVMC = null;
         secTVMC = null;
         redBtn = null;
         blueBtn = null;
         greenBtn = null;
         yellowBtn = null;
         npcMc = null;
      }
      
      private static function showColorPanel(param1:MouseEvent) : void
      {
         colorMC.visible = !colorMC.visible;
         MapManager.currentMap.controlLevel["startBtn"].mouseEnabled = false;
      }
      
      private static function onRed(param1:MouseEvent) : void
      {
         if(isBlue)
         {
            isBlue = false;
         }
      }
      
      private static function onOver(param1:MouseEvent) : void
      {
         firTVMC.gotoAndStop(2);
      }
      
      private static function onOver2(param1:MouseEvent) : void
      {
         secTVMC.gotoAndStop(2);
      }
      
      private static function onOut2(param1:MouseEvent) : void
      {
         secTVMC.gotoAndStop(1);
         secTVMC.addEventListener(Event.ENTER_FRAME,onLeft2);
      }
      
      private static function onOut1(param1:MouseEvent) : void
      {
         firTVMC.gotoAndStop(1);
         firTVMC.addEventListener(Event.ENTER_FRAME,onLeft);
      }
      
      private static function onLeft2(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(secTVMC.currentFrame == 1)
         {
            _loc2_ = secTVMC.getChildByName("up") as MovieClip;
            if(Boolean(_loc2_))
            {
               secTVMC.removeEventListener(Event.ENTER_FRAME,onLeft2);
               _loc2_.gotoAndPlay(18);
            }
         }
      }
      
      private static function onLeft(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(firTVMC.currentFrame == 1)
         {
            _loc2_ = firTVMC.getChildByName("up") as MovieClip;
            if(Boolean(_loc2_))
            {
               firTVMC.removeEventListener(Event.ENTER_FRAME,onLeft);
               _loc2_.gotoAndPlay(10);
            }
         }
      }
      
      private static function onBlue(param1:MouseEvent) : void
      {
         if(isYellow)
         {
            isBlue = true;
            isYellow = false;
            isGreen = false;
         }
      }
      
      private static function onGreen(param1:MouseEvent) : void
      {
         isGreen = true;
         isYellow = false;
         isBlue = false;
      }
      
      private static function onYellow(param1:MouseEvent) : void
      {
         if(isGreen)
         {
            isYellow = true;
            isGreen = false;
            isBlue = false;
         }
      }
      
      private static function showFTV(param1:MouseEvent) : void
      {
         firTVMC.gotoAndStop(1);
         firTVMC.addEventListener(Event.ENTER_FRAME,onEnterShow);
      }
      
      private static function showSTV(param1:MouseEvent) : void
      {
         secTVMC.gotoAndStop(1);
         secTVMC.addEventListener(Event.ENTER_FRAME,onEnterShow2);
      }
      
      private static function onEnterShow(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(firTVMC.currentFrame == 1)
         {
            _loc2_ = firTVMC.getChildByName("up") as MovieClip;
            if(Boolean(_loc2_))
            {
               firTVMC.removeEventListener(Event.ENTER_FRAME,onEnterShow);
               _loc2_.gotoAndPlay(2);
            }
         }
      }
      
      private static function onEnterShow2(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(secTVMC.currentFrame == 1)
         {
            _loc2_ = secTVMC.getChildByName("up") as MovieClip;
            if(Boolean(_loc2_))
            {
               secTVMC.removeEventListener(Event.ENTER_FRAME,onEnterShow2);
               _loc2_.gotoAndPlay(2);
            }
         }
      }
   }
}

