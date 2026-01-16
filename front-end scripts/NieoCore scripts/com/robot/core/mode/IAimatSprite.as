package com.robot.core.mode
{
   import com.robot.core.aimat.AimatStateManamer;
   import com.robot.core.info.AimatInfo;
   
   public interface IAimatSprite extends ISprite
   {
      
      function get aimatStateManager() : AimatStateManamer;
      
      function aimatState(param1:AimatInfo) : void;
   }
}

