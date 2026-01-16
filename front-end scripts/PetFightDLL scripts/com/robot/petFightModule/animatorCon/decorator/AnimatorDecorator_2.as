package com.robot.petFightModule.animatorCon.decorator
{
   import com.robot.petFightModule.animatorCon.AbstractAnimatorCon;
   import com.robot.petFightModule.animatorCon.BaseAnimatorDecorator;
   
   public class AnimatorDecorator_2 extends BaseAnimatorDecorator
   {
      
      public function AnimatorDecorator_2(param1:AbstractAnimatorCon)
      {
         super(param1);
      }
      
      override protected function effect() : void
      {
      }
      
      override public function getDescription() : String
      {
         return animatorCon.getDescription() + ",啊哟";
      }
   }
}

