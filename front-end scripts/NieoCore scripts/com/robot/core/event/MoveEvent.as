package com.robot.core.event
{
   import flash.events.Event;
   import flash.geom.Point;
   
   public class MoveEvent extends Event
   {
      
      public static const MOVE_START:String = "moveStart";
      
      public static const MOVE_ENTER:String = "moveEnter";
      
      public static const MOVE_END:String = "moveEnd";
      
      public static const MOVE:String = "move";
      
      private var _pos:Point;
      
      public function MoveEvent(param1:String, param2:Point)
      {
         super(param1);
         this._pos = param2;
      }
      
      public function get pos() : Point
      {
         return this._pos;
      }
   }
}

