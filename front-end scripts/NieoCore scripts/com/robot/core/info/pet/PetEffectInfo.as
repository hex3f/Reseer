package com.robot.core.info.pet
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   public class PetEffectInfo
   {
      
      public var itemId:uint;
      
      public var status:uint;
      
      public var leftCount:uint;
      
      public var effectID:uint;
      
      public var param:ByteArray;
      
      public var args:String;
      
      public function PetEffectInfo(param1:IDataInput)
      {
         super();
         this.itemId = param1.readUnsignedInt();
         this.status = param1.readUnsignedByte();
         this.leftCount = param1.readUnsignedByte();
         this.effectID = param1.readUnsignedShort();
         var _loc2_:uint = uint(param1.readUnsignedByte());
         param1.readUnsignedByte();
         var _loc3_:uint = uint(param1.readUnsignedByte());
         if(_loc3_ != 0)
         {
            this.args = _loc2_ + " " + _loc3_;
         }
         else
         {
            this.args = _loc2_.toString();
         }
         param1.readUTFBytes(13);
      }
   }
}

