package com.robot.app.info
{
   import flash.utils.IDataInput;
   
   public class ArenaInfo
   {
      
      private var _flag:uint;
      
      private var _hostID:uint;
      
      private var _hostNick:String;
      
      private var _hostWins:uint;
      
      private var _challengerID:uint;
      
      public function ArenaInfo(param1:IDataInput)
      {
         super();
         this._flag = param1.readUnsignedInt();
         this._hostID = param1.readUnsignedInt();
         this._hostNick = param1.readUTFBytes(16);
         this._hostWins = param1.readUnsignedInt();
         this._challengerID = param1.readUnsignedInt();
      }
      
      public function get flag() : uint
      {
         return this._flag;
      }
      
      public function get hostID() : uint
      {
         return this._hostID;
      }
      
      public function get hostNick() : String
      {
         return this._hostNick;
      }
      
      public function get hostWins() : uint
      {
         return this._hostWins;
      }
      
      public function get challengerID() : uint
      {
         return this._challengerID;
      }
   }
}

