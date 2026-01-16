package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamPkWeekyHistoryInfo
   {
      
      public var killPlayer:uint;
      
      public var killBuilding:uint;
      
      public var mvpNum:uint;
      
      public var winTimes:uint;
      
      public var lostTimes:uint;
      
      public var drawTimes:uint;
      
      public var point:uint;
      
      public function TeamPkWeekyHistoryInfo(param1:IDataInput)
      {
         super();
         this.killPlayer = param1.readUnsignedInt();
         this.killBuilding = param1.readUnsignedInt();
         this.mvpNum = param1.readUnsignedInt();
         this.winTimes = param1.readUnsignedInt();
         this.lostTimes = param1.readUnsignedInt();
         this.drawTimes = param1.readUnsignedInt();
         this.point = param1.readUnsignedInt();
      }
   }
}

