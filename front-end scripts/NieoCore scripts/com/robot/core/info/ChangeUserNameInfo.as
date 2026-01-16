package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class ChangeUserNameInfo
   {
      
      private var _userId:uint;
      
      private var _nickName:String;
      
      public function ChangeUserNameInfo(param1:IDataInput)
      {
         super();
         this._userId = param1.readUnsignedInt();
         this._nickName = param1.readUTFBytes(16);
      }
      
      public function get userId() : uint
      {
         return this._userId;
      }
      
      public function get nickName() : String
      {
         return this._nickName;
      }
   }
}

