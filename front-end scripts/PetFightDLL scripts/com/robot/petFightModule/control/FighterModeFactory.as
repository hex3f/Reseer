package com.robot.petFightModule.control
{
   import com.robot.core.info.fightInfo.FightPetInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.mode.PlayerMode;
   import flash.display.Sprite;
   
   public class FighterModeFactory
   {
      
      public static var playerMode:BaseFighterMode;
      
      public static var enemyMode:BaseFighterMode;
      
      public function FighterModeFactory()
      {
         super();
      }
      
      public static function clear() : void
      {
         playerMode = null;
         enemyMode = null;
      }
      
      public static function createMode(param1:FightPetInfo, param2:Sprite) : BaseFighterMode
      {
         var _loc3_:BaseFighterMode = null;
         if(param1.userID == MainManager.actorID)
         {
            _loc3_ = new PlayerMode(param1,param2);
            playerMode = _loc3_;
         }
         else
         {
            _loc3_ = new BaseFighterMode(param1,param2);
            enemyMode = _loc3_;
         }
         return _loc3_;
      }
   }
}

