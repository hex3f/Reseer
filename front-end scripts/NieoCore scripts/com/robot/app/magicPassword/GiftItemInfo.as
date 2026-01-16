package com.robot.app.magicPassword
{
   import com.robot.core.ui.alert.Alarm;
   import flash.utils.IDataInput;
   
   public class GiftItemInfo
   {
      
      private var giftList_a:Array;
      
      public function GiftItemInfo(param1:IDataInput)
      {
         var _loc2_:* = 0;
         var _loc3_:Number = 0;
         var _loc4_:* = 0;
         super();
         this.giftList_a = new Array();
         var _loc5_:uint = param1.readUnsignedInt();
         if(_loc5_ == 1)
         {
            _loc2_ = param1.readUnsignedInt();
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = param1.readUnsignedInt();
               this.giftList_a.push(_loc4_);
               _loc3_++;
            }
         }
         else
         {
            Alarm.show("你已经有这些礼物了");
         }
      }
      
      public function get giftList() : Array
      {
         return this.giftList_a;
      }
   }
}

