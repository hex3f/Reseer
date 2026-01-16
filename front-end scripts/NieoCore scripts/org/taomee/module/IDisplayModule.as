package org.taomee.module
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   public interface IDisplayModule extends IModule
   {
      
      function get sprite() : Sprite;
      
      function get parentContainer() : DisplayObjectContainer;
   }
}

