package com.robot.core.effect.shotBehavior
{
   import com.robot.core.effect.LightEffect;
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.SpriteModel;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class LightBehavior implements IShotBehavior
   {
      
      public function LightBehavior()
      {
         super();
      }
      
      public function shot(param1:PKArmModel, param2:SpriteModel) : void
      {
         var _loc3_:LightEffect = new LightEffect();
         var _loc4_:Rectangle = param1.getRect(param1);
         _loc3_.show(new Point(param1.pos.x,param1.pos.y + _loc4_.y + 15),param2.pos);
      }
      
      public function destroy() : void
      {
      }
   }
}

