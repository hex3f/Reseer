package com.robot.core.info.pet
{
   import flash.utils.IDataInput;
   
   public class PetListInfo
   {
      
      public var id:uint;
      
      public var catchTime:uint;
      
      public var course:uint;
      
      public var level:uint;
      
      public var skinID:uint;
      
      public function PetListInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            this.id = param1.readUnsignedInt();
            this.catchTime = param1.readUnsignedInt();
            this.skinID = param1.readUnsignedInt();
         }
      }
   }
}

