package com.robot.core.info.teamPK
{
   import com.robot.core.info.team.SimpleTeamInfo;
   
   public class TeamPKTeamInfo
   {
      
      private var _ename:String;
      
      private var _eleader:String;
      
      private var _elevel:uint;
      
      private var _myLevel:uint;
      
      private var _myLeader:String;
      
      private var _myName:String;
      
      private var _eInfo:SimpleTeamInfo;
      
      private var _myInfo:SimpleTeamInfo;
      
      public function TeamPKTeamInfo()
      {
         super();
      }
      
      public function set myInfo(param1:SimpleTeamInfo) : void
      {
         this._myInfo = param1;
      }
      
      public function get myInfo() : SimpleTeamInfo
      {
         return this._myInfo;
      }
      
      public function set eInfo(param1:SimpleTeamInfo) : void
      {
         this._eInfo = param1;
      }
      
      public function get eInfo() : SimpleTeamInfo
      {
         return this._eInfo;
      }
      
      public function get myName() : String
      {
         return this._myName;
      }
      
      public function set myName(param1:String) : void
      {
         this._myName = param1;
      }
      
      public function get myLevel() : uint
      {
         return this._myLevel;
      }
      
      public function set myLevel(param1:uint) : void
      {
         this._myLevel = param1;
      }
      
      public function get elevel() : uint
      {
         return this._elevel;
      }
      
      public function set elevel(param1:uint) : void
      {
         this._elevel = param1;
      }
      
      public function set myLeader(param1:String) : void
      {
         this._myLeader = param1;
      }
      
      public function get myLeader() : String
      {
         return this._myLeader;
      }
      
      public function get eLeader() : String
      {
         return this._eleader;
      }
      
      public function set eLeader(param1:String) : void
      {
         this._eleader = param1;
      }
      
      public function set ename(param1:String) : void
      {
         this._ename = param1;
      }
      
      public function get ename() : String
      {
         return this._ename;
      }
   }
}

