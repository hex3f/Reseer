package com.robot.app.mapProcess.active.randomPet
{
   import flash.display.Sprite;
   
   public interface IRandomPet
   {
      
      function get sprite() : Sprite;
      
      function show(param1:uint) : void;
      
      function destroy() : void;
   }
}

