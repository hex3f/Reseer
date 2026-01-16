package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class FightLoadPercentInfo
   {
      
      private var _id:uint;
      
      private var _percent:uint;
      
      public function FightLoadPercentInfo(param1:IDataInput)
      {
         super();
         this._id = param1.readUnsignedInt();
         this._percent = param1.readUnsignedInt();
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get percent() : uint
      {
         return this._percent;
      }
   }
}

