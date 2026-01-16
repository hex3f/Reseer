package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class InformInfo
   {
      
      private var _type:uint;
      
      private var _userID:uint;
      
      private var _nick:String;
      
      private var _accept:uint;
      
      private var _serverID:uint;
      
      private var _mapType:uint;
      
      private var _mapID:uint;
      
      private var _mapName:String;
      
      public function InformInfo(param1:IDataInput)
      {
         super();
         this._type = param1.readUnsignedInt();
         this._userID = param1.readUnsignedInt();
         this._nick = param1.readUTFBytes(16);
         this._accept = param1.readUnsignedInt();
         this._serverID = param1.readUnsignedInt();
         this._mapType = param1.readUnsignedInt();
         this._mapID = param1.readUnsignedInt();
         this._mapName = param1.readUTFBytes(64);
      }
      
      public function get type() : uint
      {
         return this._type;
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function get nick() : String
      {
         return this._nick;
      }
      
      public function get accept() : uint
      {
         return this._accept;
      }
      
      public function get serverID() : uint
      {
         return this._serverID;
      }
      
      public function get mapID() : uint
      {
         return this._mapID;
      }
      
      public function get mapType() : uint
      {
         return this._mapType;
      }
      
      public function get mapName() : String
      {
         return this._mapName;
      }
   }
}

