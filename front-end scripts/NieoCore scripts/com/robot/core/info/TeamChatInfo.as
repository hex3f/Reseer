package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class TeamChatInfo
   {
      
      private var _senderID:uint;
      
      private var _nick:String;
      
      private var _teamID:uint;
      
      private var _msglen:uint;
      
      private var _msg:String;
      
      public var isRead:Boolean = false;
      
      public function TeamChatInfo(param1:IDataInput)
      {
         super();
         this._senderID = param1.readUnsignedInt();
         this._nick = param1.readUTFBytes(16);
         this._teamID = param1.readUnsignedInt();
         this._msglen = param1.readUnsignedInt();
         this._msg = param1.readUTFBytes(this._msglen);
      }
      
      public function get senderID() : uint
      {
         return this._senderID;
      }
      
      public function get nick() : String
      {
         return this._nick;
      }
      
      public function get teamID() : uint
      {
         return this._teamID;
      }
      
      public function get msglen() : uint
      {
         return this._msglen;
      }
      
      public function get msg() : String
      {
         return this._msg;
      }
   }
}

