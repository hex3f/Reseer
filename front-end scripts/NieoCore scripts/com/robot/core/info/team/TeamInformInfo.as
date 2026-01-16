package com.robot.core.info.team
{
   import flash.utils.IDataInput;
   
   public class TeamInformInfo
   {
      
      private var _type:uint;
      
      private var _userID:uint;
      
      private var _nick:String;
      
      private var _data1:uint;
      
      private var _data2:uint;
      
      public function TeamInformInfo(param1:IDataInput)
      {
         super();
         this._type = param1.readUnsignedInt();
         this._userID = param1.readUnsignedInt();
         this._nick = param1.readUTFBytes(16);
         this._data1 = param1.readUnsignedInt();
         this._data2 = param1.readUnsignedInt();
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
      
      public function get data1() : uint
      {
         return this._data1;
      }
      
      public function get data2() : uint
      {
         return this._data2;
      }
   }
}

