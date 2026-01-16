package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamPKJoinInfo
   {
      
      private var _homeUserList:Array;
      
      private var _awayUserList:Array;
      
      private var _homeid:uint;
      
      private var _awayid:uint;
      
      public function TeamPKJoinInfo(param1:IDataInput)
      {
         var _loc2_:Number = 0;
         this._homeUserList = [];
         this._awayUserList = [];
         super();
         this._homeid = param1.readUnsignedInt();
         var _loc3_:uint = uint(param1.readUnsignedInt());
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this._homeUserList.push(new TeamPkUserInfo(param1));
            _loc2_++;
         }
         this._awayid = param1.readUnsignedInt();
         var _loc4_:uint = uint(param1.readUnsignedInt());
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            this._awayUserList.push(new TeamPkUserInfo(param1));
            _loc2_++;
         }
      }
      
      public function get homeTeamId() : uint
      {
         return this._homeid;
      }
      
      public function get awayTeamId() : uint
      {
         return this._awayid;
      }
      
      public function get homeUserList() : Array
      {
         return this._homeUserList;
      }
      
      public function get awayUserList() : Array
      {
         return this._awayUserList;
      }
   }
}

