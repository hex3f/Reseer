package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class GetPlateInfo
   {
      
      private var _count:uint = 0;
      
      public function GetPlateInfo(param1:IDataInput)
      {
         super();
         this._count = param1.readUnsignedInt();
      }
      
      public function get PlateCount() : uint
      {
         return this._count;
      }
   }
}

