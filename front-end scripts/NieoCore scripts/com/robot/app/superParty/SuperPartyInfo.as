package com.robot.app.superParty
{
   public class SuperPartyInfo
   {
      
      private var _mapID:uint;
      
      private var _petIDs:Array;
      
      private var _oreIDs:Array;
      
      private var _games:Array;
      
      public function SuperPartyInfo()
      {
         super();
      }
      
      public function get mapID() : uint
      {
         return this._mapID;
      }
      
      public function set mapID(param1:uint) : void
      {
         this._mapID = param1;
      }
      
      public function get petIDs() : Array
      {
         return this._petIDs;
      }
      
      public function set petIDs(param1:Array) : void
      {
         this._petIDs = param1;
      }
      
      public function get oreIDs() : Array
      {
         return this._oreIDs;
      }
      
      public function set oreIDs(param1:Array) : void
      {
         this._oreIDs = param1;
      }
      
      public function get games() : Array
      {
         return this._games;
      }
      
      public function set games(param1:Array) : void
      {
         this._games = param1;
      }
   }
}

