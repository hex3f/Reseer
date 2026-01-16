package com.robot.core.info
{
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import flash.utils.IDataInput;
   
   public class ChangeClothInfo
   {
      
      private var _userID:uint;
      
      private var _clothArray:Array;
      
      public function ChangeClothInfo(param1:IDataInput)
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         this._clothArray = [];
         super();
         this._userID = param1.readUnsignedInt();
         var _loc4_:uint = uint(param1.readUnsignedInt());
         var _loc5_:Number = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = uint(param1.readUnsignedInt());
            _loc3_ = uint(param1.readUnsignedInt());
            this._clothArray.push(new PeopleItemInfo(_loc2_,_loc3_));
            _loc5_++;
         }
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function get clothArray() : Array
      {
         return this._clothArray;
      }
   }
}

