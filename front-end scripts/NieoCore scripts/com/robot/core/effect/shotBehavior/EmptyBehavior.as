package com.robot.core.effect.shotBehavior
{
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.SpriteModel;
   
   public class EmptyBehavior implements IShotBehavior
   {
      
      public function EmptyBehavior()
      {
         super();
      }
      
      public function shot(param1:PKArmModel, param2:SpriteModel) : void
      {
      }
      
      public function destroy() : void
      {
      }
   }
}

