package com.robot.core.npc
{
   import com.robot.core.mode.NpcModel;
   
   public interface INpc
   {
      
      function get npc() : NpcModel;
      
      function destroy() : void;
   }
}

