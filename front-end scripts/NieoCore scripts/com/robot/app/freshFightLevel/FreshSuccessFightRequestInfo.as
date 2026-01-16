package com.robot.app.freshFightLevel
{
   import flash.utils.IDataInput;
   
   public class FreshSuccessFightRequestInfo
   {
      
      private var bossId:Array;
      
      private var curLevel:uint;
      
      private var _bossIdA:Array;
      
      public function FreshSuccessFightRequestInfo(param1:IDataInput)
      {
         super();
         this._bossIdA = [];
         this.curLevel = param1.readUnsignedInt();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this._bossIdA.push(param1.readUnsignedInt());
            _loc3_++;
         }
      }
      
      public function get getBossId() : Array
      {
         return this._bossIdA;
      }
      
      public function get getCurLevel() : uint
      {
         return this.curLevel;
      }
   }
}

