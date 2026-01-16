package com.robot.core.effect.shotBehavior
{
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.SpriteModel;
   
   public interface IShotBehavior
   {
      
      function shot(param1:PKArmModel, param2:SpriteModel) : void;
      
      function destroy() : void;
   }
}

