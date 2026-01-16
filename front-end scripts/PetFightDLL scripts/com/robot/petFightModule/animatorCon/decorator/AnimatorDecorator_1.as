package com.robot.petFightModule.animatorCon.decorator
{
   import com.robot.petFightModule.animatorCon.AbstractAnimatorCon;
   import com.robot.petFightModule.animatorCon.BaseAnimatorDecorator;
   
   public class AnimatorDecorator_1 extends BaseAnimatorDecorator
   {
      
      public function AnimatorDecorator_1(param1:AbstractAnimatorCon)
      {
         super(param1);
      }
      
      override protected function effect() : void
      {
      }
      
      override public function getDescription() : String
      {
         return animatorCon.getDescription() + ",使用该技能后" + "自身特防等级提高一个等级的同时，下一个回合使用雷电系技能有2倍伤害";
      }
   }
}

