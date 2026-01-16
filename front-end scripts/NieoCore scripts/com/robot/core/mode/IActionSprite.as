package com.robot.core.mode
{
   public interface IActionSprite extends ISprite
   {
      
      function set actionType(param1:String) : void;
      
      function get actionType() : String;
      
      function play() : void;
      
      function stop() : void;
      
      function get speed() : Number;
   }
}

