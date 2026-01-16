package com.robot.core.info.fightInfo
{
   public class PetFightModel
   {
      
      public static var type:uint;
      
      public static var status:uint;
      
      public static var defaultNpcID:uint;
      
      public static const PET_MELEE:uint = 3;
      
      public static const SINGLE_MODE:uint = 1;
      
      public static const MULTI_MODE:uint = 2;
      
      public static const FIGHT_WITH_NPC:uint = 0;
      
      public static const FIGHT_WITH_BOSS:uint = 1;
      
      public static const FIGHT_WITH_PLAYER:uint = 2;
      
      public static const PET_TOPLEVEL:uint = 5;
      
      public static const TOP_WAR_BEYOND:uint = 13;
      
      private static var _mode:uint = MULTI_MODE;
      
      public static var enemyName:String = "";
      
      public function PetFightModel()
      {
         super();
      }
      
      public static function set mode(param1:uint) : void
      {
         _mode = param1;
      }
      
      public static function get mode() : uint
      {
         return _mode;
      }
   }
}

