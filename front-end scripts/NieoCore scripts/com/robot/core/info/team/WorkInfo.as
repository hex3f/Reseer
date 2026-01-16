package com.robot.core.info.team
{
   import flash.utils.IDataInput;
   
   public class WorkInfo
   {
      
      public var buyTime:uint;
      
      public var id:uint;
      
      public var resID:uint;
      
      public var workCount:uint;
      
      public var totalRes:uint;
      
      public function WorkInfo(param1:IDataInput)
      {
         super();
         this.buyTime = param1.readUnsignedInt();
         this.id = param1.readUnsignedInt();
         this.resID = param1.readUnsignedInt();
         this.workCount = param1.readUnsignedInt();
         this.totalRes = param1.readUnsignedInt();
      }
   }
}

