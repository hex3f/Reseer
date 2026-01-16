package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamPkHistoryInfo
   {
      
      public var killPlayer:uint;
      
      public var killBuilding:uint;
      
      public var mvpNum:uint;
      
      public var winTimes:uint;
      
      public var lostTimes:uint;
      
      public var drawTimes:uint;
      
      public var point:uint;
      
      private var _week:int;
      
      public function TeamPkHistoryInfo(param1:IDataInput)
      {
         super();
         this.killPlayer = param1.readUnsignedInt();
         this.killBuilding = param1.readUnsignedInt();
         this.mvpNum = param1.readUnsignedInt();
         this.winTimes = param1.readUnsignedInt();
         this.lostTimes = param1.readUnsignedInt();
         this.drawTimes = param1.readUnsignedInt();
         this.point = param1.readUnsignedInt();
         this._week = param1.readInt();
      }
      
      public function get week() : uint
      {
         if(this._week <= 0)
         {
            return 1;
         }
         return this._week;
      }
   }
}

