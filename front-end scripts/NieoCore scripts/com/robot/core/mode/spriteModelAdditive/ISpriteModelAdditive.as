package com.robot.core.mode.spriteModelAdditive
{
   import com.robot.core.mode.SpriteModel;
   
   public interface ISpriteModelAdditive
   {
      
      function init() : void;
      
      function get model() : SpriteModel;
      
      function set model(param1:SpriteModel) : void;
      
      function show() : void;
      
      function hide() : void;
      
      function destroy() : void;
   }
}

