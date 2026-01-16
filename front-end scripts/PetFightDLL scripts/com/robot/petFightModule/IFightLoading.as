package com.robot.petFightModule
{
   import flash.display.Sprite;
   
   public interface IFightLoading
   {
      
      function get sprite() : Sprite;
      
      function setMyPro(param1:uint) : void;
      
      function setOtherPro(param1:uint) : void;
      
      function destroy() : void;
      
      function ok(param1:uint) : void;
   }
}

