package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamPKBuildingListInfo
   {
      
      private var _homeList:Array = [];
      
      private var _awayList:Array = [];
      
      public function TeamPKBuildingListInfo(param1:IDataInput)
      {
         super();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:uint = uint(param1.readUnsignedInt());
         var _loc4_:Number = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            this._homeList.push(new TeamPkBuildingInfo(param1,_loc3_));
            _loc4_++;
         }
         var _loc5_:uint = uint(param1.readUnsignedInt());
         _loc3_ = uint(param1.readUnsignedInt());
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            this._awayList.push(new TeamPkBuildingInfo(param1,_loc3_));
            _loc4_++;
         }
      }
      
      public function get homeList() : Array
      {
         return this._homeList;
      }
      
      public function get awayList() : Array
      {
         return this._awayList;
      }
   }
}

