package com.robot.petFightModule
{
   import com.robot.app.automaticFight.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.*;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class FightOverPanel
   {
      
      private static var bmp:Bitmap;
      
      private static var overData:FightOverInfo;
      
      public function FightOverPanel()
      {
         super();
      }
      
      public static function showLost(param1:Bitmap, param2:FightOverInfo) : void
      {
         if(AutomaticFightManager.isStart)
         {
            AutomaticFightManager.fightOver(param1);
            return;
         }
         overData = param2;
         bmp = param1;
         var _loc3_:MovieClip = new FightLostPanel();
         DisplayUtil.align(_loc3_,null,AlignType.MIDDLE_CENTER);
         MainManager.getStage().addChild(_loc3_);
         var _loc4_:SimpleButton = _loc3_["okBtn"];
         _loc4_.addEventListener(MouseEvent.CLICK,clickHandler);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         var _loc2_:SimpleButton = param1.currentTarget as SimpleButton;
         DisplayUtil.removeForParent(_loc2_.parent);
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.PET_UPDATE_PROP,bmp));
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.ALARM_CLICK,overData));
      }
      
      public static function showWin(param1:Bitmap, param2:FightOverInfo) : void
      {
         if(AutomaticFightManager.isStart)
         {
            AutomaticFightManager.fightOver(param1);
            return;
         }
         overData = param2;
         bmp = param1;
         var _loc3_:MovieClip = new FightWinPanel();
         DisplayUtil.align(_loc3_,null,AlignType.MIDDLE_CENTER);
         MainManager.getStage().addChild(_loc3_);
         var _loc4_:SimpleButton = _loc3_["okBtn"];
         _loc4_.addEventListener(MouseEvent.CLICK,clickHandler);
      }
   }
}

