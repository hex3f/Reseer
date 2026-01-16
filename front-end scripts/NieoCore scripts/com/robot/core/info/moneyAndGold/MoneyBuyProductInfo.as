package com.robot.core.info.moneyAndGold
{
   import flash.utils.IDataInput;
   
   public class MoneyBuyProductInfo
   {
      
      private var _payMoney:Number;
      
      private var _money:Number;
      
      public function MoneyBuyProductInfo(param1:IDataInput)
      {
         super();
         param1.readUnsignedInt();
         this._payMoney = param1.readUnsignedInt() / 100;
         this._money = param1.readUnsignedInt() / 100;
      }
      
      public function get payMoney() : Number
      {
         return this._payMoney;
      }
      
      public function get money() : Number
      {
         return this._money;
      }
   }
}

