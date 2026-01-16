package com.robot.app.info.fightInvite
{
   import flash.utils.IDataInput;
   
   public class InviteHandleInfo
   {
      
      private var _userID:uint;
      
      private var _nickName:String;
      
      private var _result:uint;
      
      public function InviteHandleInfo(param1:IDataInput)
      {
         super();
         this._userID = param1.readUnsignedInt();
         this._nickName = param1.readUTFBytes(16);
         this._result = param1.readUnsignedInt();
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function get nickName() : String
      {
         return this._nickName;
      }
      
      public function get result() : uint
      {
         return this._result;
      }
   }
}

