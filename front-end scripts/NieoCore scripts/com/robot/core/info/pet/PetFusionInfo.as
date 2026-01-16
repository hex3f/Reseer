package com.robot.core.info.pet
{
   import flash.utils.IDataInput;
   
   public class PetFusionInfo
   {
      
      public var obtainTime:uint;
      
      public var soulID:uint;
      
      public var starterCpTm:uint;
      
      public var costItemFlag:uint;
      
      public function PetFusionInfo(param1:IDataInput)
      {
         super();
         this.obtainTime = param1.readUnsignedInt();
         this.soulID = param1.readUnsignedInt();
         this.starterCpTm = param1.readUnsignedInt();
         this.costItemFlag = param1.readUnsignedInt();
      }
   }
}

