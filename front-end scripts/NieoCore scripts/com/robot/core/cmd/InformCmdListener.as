package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.info.InformInfo;
   import com.robot.core.manager.MessageManager;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.DynamicEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class InformCmdListener
   {
      
      public function InformCmdListener()
      {
         super();
      }
      
      private static function onInform(param1:SocketEvent) : void
      {
         var _loc2_:InformInfo = param1.data as InformInfo;
         if(_loc2_.type == 1004)
         {
            EventManager.dispatchEvent(new DynamicEvent("DS_TASK",_loc2_.accept));
         }
         else
         {
            MessageManager.addInformInfo(_loc2_);
         }
      }
      
      public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.INFORM,onInform);
      }
   }
}

