package com.robot.core.mode
{
   import flash.display.Sprite;
   
   public interface IFunUnit
   {
      
      function setup(param1:Sprite) : void;
      
      function init(param1:Object = null) : void;
      
      function destroy() : void;
   }
}

