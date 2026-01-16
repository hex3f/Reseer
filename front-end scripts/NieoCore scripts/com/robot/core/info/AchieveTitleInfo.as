package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class AchieveTitleInfo
   {
      
      private var _count:uint = 0;
      
      private var _titleArr:Array;
      
      public function AchieveTitleInfo(param1:IDataInput)
      {
         super();
         this._count = param1.readUnsignedInt();
         this._titleArr = new Array();
         var _loc2_:uint = 0;
         while(_loc2_ < this._count)
         {
            this._titleArr.push(param1.readUnsignedInt());
            _loc2_++;
         }
      }
      
      public function get titleArr() : Array
      {
         return this._titleArr;
      }
   }
}

