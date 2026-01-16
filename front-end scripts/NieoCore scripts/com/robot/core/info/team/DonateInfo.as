package com.robot.core.info.team
{
   import flash.utils.IDataInput;
   
   public class DonateInfo
   {
      
      public var buyTime:uint;
      
      public var id:uint;
      
      public var resID:uint;
      
      public var donateCount:uint;
      
      public var totalRes:uint;
      
      public function DonateInfo(param1:IDataInput)
      {
         super();
         this.buyTime = param1.readUnsignedInt();
         this.id = param1.readUnsignedInt();
         this.resID = param1.readUnsignedInt();
         this.donateCount = param1.readUnsignedInt();
         this.totalRes = param1.readUnsignedInt();
      }
   }
}

