package com.robot.core.info.mail
{
   import flash.utils.IDataInput;
   
   public class MailListInfo
   {
      
      private var _total:uint;
      
      private var _mailList:Array = [];
      
      public function MailListInfo(param1:IDataInput)
      {
         super();
         this._total = param1.readUnsignedInt();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this._mailList.push(new SingleMailInfo(param1));
            _loc3_++;
         }
      }
      
      public function get total() : uint
      {
         return this._total;
      }
      
      public function get mailList() : Array
      {
         return this._mailList;
      }
   }
}

