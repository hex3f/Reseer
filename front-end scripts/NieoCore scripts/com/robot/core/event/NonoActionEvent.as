package com.robot.core.event
{
   import flash.events.Event;
   
   public class NonoActionEvent extends Event
   {
      
      public static const COLOR_CHANGE:String = "colorChange";
      
      public static const NAME_CHANGE:String = "nameChange";
      
      public static const CLOSE_OPEN:String = "closeOpen";
      
      public static const CHARGEING:String = "chargeing";
      
      public static const NONO_PLAY:String = "nonoPlay";
      
      private var _actionType:String;
      
      private var _data:Object;
      
      public function NonoActionEvent(param1:String, param2:String, param3:Object)
      {
         super(param1);
         this._actionType = param2;
         this._data = param3;
      }
      
      public function get actionType() : String
      {
         return this._actionType;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
   }
}

