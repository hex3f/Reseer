package com.robot.core.info.fbGame
{
   import flash.utils.IDataInput;
   
   public class FBGameOverInfo
   {
      
      private var _array:Array = [];
      
      public function FBGameOverInfo(param1:IDataInput)
      {
         super();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this._array.push(new GameOverUserInfo(param1));
            _loc3_++;
         }
      }
      
      public function get userList() : Array
      {
         return this._array;
      }
   }
}

