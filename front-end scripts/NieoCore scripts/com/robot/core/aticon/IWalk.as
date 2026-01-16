package com.robot.core.aticon
{
   import com.robot.core.mode.IActionSprite;
   import flash.geom.Point;
   
   public interface IWalk
   {
      
      function get isPlaying() : Boolean;
      
      function get endP() : Point;
      
      function get remData() : Array;
      
      function init() : void;
      
      function execute(param1:IActionSprite, param2:Object, param3:Boolean = true) : void;
      
      function execute_point(param1:IActionSprite, param2:Point, param3:Boolean = true) : void;
      
      function play() : void;
      
      function stop() : void;
      
      function destroy() : void;
   }
}

