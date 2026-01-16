package com.robot.petFightModule.data
{
   import com.robot.core.info.fightInfo.ChangePetInfo;
   
   public class NpcChangePetData
   {
      
      private static var array:Array = [];
      
      public static var npcPetChenged:Boolean = false;
      
      public function NpcChangePetData()
      {
         super();
      }
      
      public static function add(param1:ChangePetInfo) : void
      {
         array.push(param1);
         npcPetChenged = true;
      }
      
      public static function first() : ChangePetInfo
      {
         return array.shift() as ChangePetInfo;
      }
   }
}

