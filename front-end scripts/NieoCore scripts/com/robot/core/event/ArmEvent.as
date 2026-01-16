package com.robot.core.event
{
   import com.robot.core.info.team.ArmInfo;
   import flash.events.Event;
   
   public class ArmEvent extends Event
   {
      
      public static const ADD_TO_STORAGE:String = "addToStorage";
      
      public static const REMOVE_TO_STORAGE:String = "removeToStorage";
      
      public static const ADD_TO_MAP:String = "addToMap";
      
      public static const REMOVE_TO_MAP:String = "removeToMaps";
      
      public static const REMOVE_ALL_TO_MAP:String = "removeAllToMaps";
      
      public static const USED_LIST:String = "usedList";
      
      public static const ALL_LIST:String = "allList";
      
      public static const UP_USED_LIST:String = "upUsedList";
      
      public static const UP_ALL_LIST:String = "upAllList";
      
      private var _info:ArmInfo;
      
      public function ArmEvent(param1:String, param2:ArmInfo)
      {
         super(param1,false,false);
         this._info = param2;
      }
      
      public function get info() : ArmInfo
      {
         return this._info;
      }
   }
}

