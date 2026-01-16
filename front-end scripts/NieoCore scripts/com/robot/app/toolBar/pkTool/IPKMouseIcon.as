package com.robot.app.toolBar.pkTool
{
   import flash.display.Sprite;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   
   public interface IPKMouseIcon extends IEventDispatcher
   {
      
      function get sprite() : Sprite;
      
      function get icon() : Sprite;
      
      function move(param1:Point) : void;
      
      function show() : void;
      
      function hide() : void;
      
      function click() : void;
      
      function destroy() : void;
      
      function reset() : void;
   }
}

