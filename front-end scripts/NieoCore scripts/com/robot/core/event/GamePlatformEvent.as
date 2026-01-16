package com.robot.core.event
{
   import flash.events.Event;
   
   public class GamePlatformEvent extends Event
   {
      
      public static const GAME_WIN:String = "gameWin";
      
      public static const GAME_LOST:String = "gameLost";
      
      public function GamePlatformEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

