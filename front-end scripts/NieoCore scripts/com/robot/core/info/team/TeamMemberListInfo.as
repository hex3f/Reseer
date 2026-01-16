package com.robot.core.info.team
{
   import flash.utils.IDataInput;
   
   public class TeamMemberListInfo
   {
      
      private var _teamID:uint;
      
      private var _userList:Array = [];
      
      private var _superCoreNum:uint;
      
      public function TeamMemberListInfo(param1:IDataInput)
      {
         super();
         this._teamID = param1.readUnsignedInt();
         this._superCoreNum = param1.readUnsignedInt();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this._userList.push(new TeamMemberInfo(param1));
            _loc3_++;
         }
      }
      
      public function get teamID() : uint
      {
         return this._teamID;
      }
      
      public function get superCoreNum() : uint
      {
         return this._superCoreNum;
      }
      
      public function get memberList() : Array
      {
         return this._userList;
      }
   }
}

