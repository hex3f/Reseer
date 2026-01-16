package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class AchieveListInfo
   {
      
      private var _count:uint = 0;
      
      private var _achieveArr:Array;
      
      public function AchieveListInfo(param1:IDataInput)
      {
         super();
         this._count = param1.readUnsignedInt();
         this._achieveArr = new Array();
         var _loc2_:uint = 0;
         while(_loc2_ < this._count)
         {
            this._achieveArr.push(param1.readUnsignedInt());
            _loc2_++;
         }
      }
      
      public function get achieveArr() : Array
      {
         return this._achieveArr;
      }
   }
}

