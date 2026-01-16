package org.taomee.component.bgFill
{
   import flash.display.Sprite;
   
   public interface IBgFillStyle
   {
      
      function draw(param1:Sprite) : void;
      
      function clear() : void;
      
      function reDraw() : void;
   }
}

