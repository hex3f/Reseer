package com.robot.core.utils
{
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   
   public class PopKeys
   {
      
      private static var aState:Array = [];
      
      public function PopKeys()
      {
         super();
      }
      
      public static function addStageLis(param1:Stage) : void
      {
         if(Boolean(param1))
         {
            param1.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
            param1.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
         }
      }
      
      public static function clearStageLis(param1:Stage) : void
      {
         param1.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
         param1.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
         aState = [];
      }
      
      public static function isDown(param1:uint) : Boolean
      {
         return aState[param1] == true;
      }
      
      public static function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:uint = param1.keyCode;
         aState[_loc2_] = true;
      }
      
      public static function onKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:uint = param1.keyCode;
         aState[_loc2_] = false;
      }
   }
}

