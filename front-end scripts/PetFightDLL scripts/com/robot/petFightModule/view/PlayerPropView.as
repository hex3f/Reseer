package com.robot.petFightModule.view
{
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class PlayerPropView extends BaseFighterPropView
   {
      
      public function PlayerPropView(param1:Sprite)
      {
         super(param1);
      }
      
      override protected function showName(param1:BaseFighterMode) : void
      {
         name_txt.text = MainManager.actorInfo.nick;
      }
      
      override protected function addIcon(param1:MovieClip) : void
      {
         var _loc2_:Number = 195 + (param1.width + 4) * effectIcons.length;
         var _loc3_:Number = 30;
         var _loc4_:Point = _propWin.parent.globalToLocal(_propWin.localToGlobal(new Point(_loc2_,_loc3_)));
         param1.x = _loc4_.x;
         param1.y = _loc4_.y;
         _propWin.parent.addChild(param1);
      }
      
      override protected function initExp(param1:BaseFighterMode) : void
      {
         var _loc2_:PetInfo = PetManager.getPetInfo(param1.catchTime);
         var _loc3_:Number = _loc2_.exp / _loc2_.nextLvExp;
      }
   }
}

