package com.robot.core.info.pet.update
{
   import flash.utils.IDataInput;
   
   public class PetUpdateSkillInfo
   {
      
      private var _infoArray:Array = [];
      
      public function PetUpdateSkillInfo(param1:IDataInput)
      {
         super();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this._infoArray.push(new UpdateSkillInfo(param1));
            _loc3_++;
         }
      }
      
      public function get infoArray() : Array
      {
         return this._infoArray;
      }
   }
}

