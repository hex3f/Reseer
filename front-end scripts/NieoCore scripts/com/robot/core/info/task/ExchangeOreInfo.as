package com.robot.core.info.task
{
   import flash.utils.IDataInput;
   
   public class ExchangeOreInfo
   {
      
      private var _paiDou:uint;
      
      private var _oreCount:uint;
      
      public function ExchangeOreInfo(param1:IDataInput)
      {
         super();
         this._oreCount = param1.readUnsignedInt();
         this._paiDou = param1.readUnsignedInt();
      }
      
      public function get paiDou() : uint
      {
         return this._paiDou;
      }
      
      public function get oreCount() : uint
      {
         return this._oreCount;
      }
   }
}

