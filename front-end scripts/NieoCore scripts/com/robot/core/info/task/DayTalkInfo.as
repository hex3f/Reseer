package com.robot.core.info.task
{
   import flash.utils.IDataInput;
   
   public class DayTalkInfo
   {
      
      private var _cateCount:uint;
      
      private var _cateList:Array = [];
      
      private var _outCount:uint;
      
      private var _outList:Array = [];
      
      public function DayTalkInfo(param1:IDataInput)
      {
         super();
         this._cateCount = param1.readUnsignedInt();
         var _loc2_:int = 0;
         while(_loc2_ < this._cateCount)
         {
            this._cateList.push(new CateInfo(param1));
            _loc2_++;
         }
         this._outCount = param1.readUnsignedInt();
         var _loc3_:int = 0;
         while(_loc3_ < this._outCount)
         {
            this._outList.push(new CateInfo(param1));
            _loc3_++;
         }
      }
      
      public function get cateCount() : uint
      {
         return this._cateCount;
      }
      
      public function get cateList() : Array
      {
         return this._cateList;
      }
      
      public function get outCount() : uint
      {
         return this._outCount;
      }
      
      public function get outList() : Array
      {
         return this._outList;
      }
   }
}

