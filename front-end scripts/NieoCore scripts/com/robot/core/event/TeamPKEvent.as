package com.robot.core.event
{
   import flash.events.Event;
   
   public class TeamPKEvent extends Event
   {
      
      public static const GET_BUILDING_LIST:String = "getBuildingList";
      
      public static const OPEN_TOOL:String = "openTool";
      
      public static const CLOSE_TOOL:String = "closeTool";
      
      public static const OPEN_DOOR:String = "openDoor";
      
      public static const COUNT_TIME:String = "countTime";
      
      public function TeamPKEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

