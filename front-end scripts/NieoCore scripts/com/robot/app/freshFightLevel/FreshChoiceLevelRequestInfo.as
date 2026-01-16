package com.robot.app.freshFightLevel
{
   import flash.utils.IDataInput;
   
   public class FreshChoiceLevelRequestInfo
   {
      
      private var bossId:uint;
      
      private var curFightLevel:uint;
      
      private var _bossIdA:Array;
      
      public function FreshChoiceLevelRequestInfo(param1:IDataInput = null)
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         super();
         if(param1 != null)
         {
            this._bossIdA = [];
            this.curFightLevel = param1.readUnsignedInt();
            _loc2_ = uint(param1.readUnsignedInt());
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this._bossIdA.push(param1.readUnsignedInt());
               _loc3_++;
            }
         }
      }
      
      public function get getBossId() : Array
      {
         return this._bossIdA;
      }
      
      public function get getLevel() : uint
      {
         return this.curFightLevel;
      }
   }
}

