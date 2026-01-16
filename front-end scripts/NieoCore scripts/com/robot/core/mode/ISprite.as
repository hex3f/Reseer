package com.robot.core.mode
{
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface ISprite
   {
      
      function destroy() : void;
      
      function set direction(param1:String) : void;
      
      function get direction() : String;
      
      function set pos(param1:Point) : void;
      
      function get pos() : Point;
      
      function get sprite() : Sprite;
      
      function get centerPoint() : Point;
      
      function get hitRect() : Rectangle;
      
      function addPos(param1:Point) : void;
      
      function subtractPos(param1:Point) : void;
   }
}

