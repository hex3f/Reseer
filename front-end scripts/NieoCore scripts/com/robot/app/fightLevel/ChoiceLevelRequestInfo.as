package com.robot.app.fightLevel
{
   import flash.utils.IDataInput;
   
   public class ChoiceLevelRequestInfo
   {
      
      private var bossId:uint;
      
      private var curFightLevel:uint;
      
      private var _bossIdA:Array;
      
      public function ChoiceLevelRequestInfo(param1:IDataInput)
      {
         super();
         this._bossIdA = [];
         this.curFightLevel = param1.readUnsignedInt();
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
      
      public function get getLevel() : uint
      {
         return this.curFightLevel;
      }
   }
}

