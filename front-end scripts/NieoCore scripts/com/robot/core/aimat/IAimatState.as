package com.robot.core.aimat
{
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.IAimatSprite;
   
   public interface IAimatState
   {
      
      function get isFinish() : Boolean;
      
      function execute(param1:IAimatSprite, param2:AimatInfo) : void;
      
      function destroy() : void;
   }
}

