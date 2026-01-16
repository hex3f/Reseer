package com.robot.petFightModule
{
   import com.robot.petFightModule.mode.*;
   
   public class RemainHpManager
   {
      
      private static var array:Array = [];
      
      public function RemainHpManager()
      {
         super();
      }
      
      public static function add(param1:BaseFighterMode, param2:uint) : void
      {
         array.push({
            "mode":param1,
            "remainHP":param2
         });
      }
      
      public static function showChange() : void
      {
         var _loc1_:Object = null;
         var _loc2_:BaseFighterMode = null;
         for each(_loc1_ in array)
         {
            _loc2_ = _loc1_["mode"] as BaseFighterMode;
            _loc2_.remainHp(_loc1_["remainHP"]);
         }
         array = [];
      }
      
      public static function clear() : void
      {
         array = [];
      }
   }
}

