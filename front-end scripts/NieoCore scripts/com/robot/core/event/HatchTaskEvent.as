package com.robot.core.event
{
   import flash.events.Event;
   
   public class HatchTaskEvent extends Event
   {
      
      public static const COMPLETE:String = "complete";
      
      public static const GET_PRO_STATUS:String = "getProStatus";
      
      public static const SET_PRO_STATUS:String = "setProStatus";
      
      public static const GET_PRO_STATUS_LIST:String = "getProStatusList";
      
      private var _actType:String;
      
      private var _taskID:uint;
      
      private var _itemID:uint;
      
      private var _pro:uint;
      
      private var _data:Array;
      
      public function HatchTaskEvent(param1:String, param2:uint, param3:uint, param4:uint, param5:Array = null)
      {
         super(param1 + "_" + param2.toString() + "_" + param3.toString() + param4.toString());
         this._actType = param1;
         this._taskID = param2;
         this._itemID = param3;
         this._pro = param4;
         this._data = param5;
      }
      
      public function get actType() : String
      {
         return this._actType;
      }
      
      public function get taskID() : uint
      {
         return this._taskID;
      }
      
      public function get itemID() : uint
      {
         return this._itemID;
      }
      
      public function get pro() : uint
      {
         return this._pro;
      }
      
      public function get data() : Array
      {
         return this._data;
      }
   }
}

