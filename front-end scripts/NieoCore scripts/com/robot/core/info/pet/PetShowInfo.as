package com.robot.core.info.pet
{
   import flash.utils.IDataInput;
   
   public class PetShowInfo
   {
      
      public var userID:uint;
      
      public var catchTime:uint;
      
      public var petID:uint;
      
      public var flag:uint;
      
      public var dv:uint;
      
      public var skinID:uint;
      
      public function PetShowInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            this.userID = param1.readUnsignedInt();
            this.catchTime = param1.readUnsignedInt();
            this.petID = param1.readUnsignedInt();
            this.flag = param1.readUnsignedInt();
            this.dv = param1.readUnsignedInt();
            this.skinID = param1.readUnsignedInt();
         }
      }
   }
}

