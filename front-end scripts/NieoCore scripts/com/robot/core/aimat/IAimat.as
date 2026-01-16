package com.robot.core.aimat
{
   import com.robot.core.info.AimatInfo;
   
   public interface IAimat
   {
      
      function execute(param1:AimatInfo) : void;
      
      function destroy() : void;
   }
}

