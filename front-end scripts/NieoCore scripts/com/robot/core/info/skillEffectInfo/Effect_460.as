package com.robot.core.info.skillEffectInfo
{
   public class Effect_460 extends AbstractEffectInfo
   {
      
      public function Effect_460()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率令对手害怕，若对手处于能力强化状态则额外附加" + param1[1] + "%几率";
      }
   }
}

