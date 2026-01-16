package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamPKNoteInfo
   {
      
      private var _selfTeamID:uint;
      
      private var _homeTeamID:uint;
      
      private var _awayTeamID:uint;
      
      private var _event:uint;
      
      private var _time:int;
      
      public function TeamPKNoteInfo(param1:IDataInput)
      {
         super();
         this._selfTeamID = param1.readUnsignedInt();
         this._homeTeamID = param1.readUnsignedInt();
         this._awayTeamID = param1.readUnsignedInt();
         this._event = param1.readUnsignedInt();
         this._time = param1.readInt();
      }
      
      public function get homeTeamID() : uint
      {
         return this._homeTeamID;
      }
      
      public function get awayTeamID() : uint
      {
         return this._awayTeamID;
      }
      
      public function get selfTeamID() : uint
      {
         return this._selfTeamID;
      }
      
      public function get event() : uint
      {
         return this._event;
      }
   }
}

