package com.robot.core.info.task
{
   import flash.utils.IDataInput;
   
   public class MiningCountInfo
   {
      
      private var _miningCout:uint;
      
      public function MiningCountInfo(param1:IDataInput)
      {
         super();
         this._miningCout = param1.readUnsignedInt();
      }
      
      public function get miningCount() : uint
      {
         return this._miningCout;
      }
   }
}

