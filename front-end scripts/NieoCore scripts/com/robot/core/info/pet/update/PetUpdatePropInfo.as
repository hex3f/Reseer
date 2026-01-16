package com.robot.core.info.pet.update
{
   import flash.utils.IDataInput;
   
   public class PetUpdatePropInfo
   {
      
      private var _addition:uint;
      
      private var _dataArray:Array = [];
      
      public function PetUpdatePropInfo(param1:IDataInput)
      {
         super();
         this._addition = param1.readUnsignedInt();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this._dataArray.push(new UpdatePropInfo(param1));
            _loc3_++;
         }
      }
      
      public function get dataArray() : Array
      {
         return this._dataArray;
      }
      
      public function get addition() : Number
      {
         return this._addition / 100;
      }
      
      public function get addPer() : uint
      {
         return this._addition;
      }
   }
}

