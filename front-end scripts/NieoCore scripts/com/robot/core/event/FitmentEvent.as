package com.robot.core.event
{
   import com.robot.core.info.FitmentInfo;
   import flash.events.Event;
   
   public class FitmentEvent extends Event
   {
      
      public static const ADD_TO_STORAGE:String = "addToStorage";
      
      public static const REMOVE_TO_STORAGE:String = "removeToStorage";
      
      public static const ADD_TO_MAP:String = "addToMap";
      
      public static const REMOVE_TO_MAP:String = "removeToMaps";
      
      public static const REMOVE_ALL_TO_MAP:String = "removeAllToMaps";
      
      public static const USED_LIST:String = "usedList";
      
      public static const STORAGE_LIST:String = "storageList";
      
      public static const DRAG_IN_MAP:String = "dragInMap";
      
      private var _info:FitmentInfo;
      
      public function FitmentEvent(param1:String, param2:FitmentInfo)
      {
         super(param1,false,false);
         this._info = param2;
      }
      
      public function get info() : FitmentInfo
      {
         return this._info;
      }
   }
}

