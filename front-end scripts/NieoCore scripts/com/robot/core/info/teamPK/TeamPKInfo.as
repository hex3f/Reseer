package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamPKInfo
   {
      
      private var _groupID:uint;
      
      private var _homeTeamID:uint;
      
      public function TeamPKInfo(param1:IDataInput)
      {
         super();
         this._groupID = param1.readUnsignedInt();
         this._homeTeamID = param1.readUnsignedInt();
      }
      
      public function get groupID() : uint
      {
         return this._groupID;
      }
      
      public function get homeTeamID() : uint
      {
         return this._homeTeamID;
      }
      
      public function set homeTeamID(param1:uint) : void
      {
         this._homeTeamID = param1;
      }
   }
}

