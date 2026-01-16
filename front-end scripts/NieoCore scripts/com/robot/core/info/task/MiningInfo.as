package com.robot.core.info.task
{
   import flash.utils.IDataInput;
   
   public class MiningInfo
   {
      
      private var _oreCount:uint;
      
      public function MiningInfo(param1:IDataInput)
      {
         super();
         this._oreCount = param1.readUnsignedInt();
      }
      
      public function get oreCount() : uint
      {
         return this._oreCount;
      }
   }
}

