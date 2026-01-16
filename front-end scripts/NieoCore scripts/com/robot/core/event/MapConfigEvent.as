package com.robot.core.event
{
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class MapConfigEvent extends Event
   {
      
      public static const HIT_MAP_COMPONENT:String = "hitMapComponent";
      
      private var _hitMC:Sprite;
      
      public function MapConfigEvent(param1:String, param2:Sprite, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._hitMC = param2;
      }
      
      public function get hitMC() : Sprite
      {
         return this._hitMC;
      }
   }
}

