package com.robot.core.cmd.nono
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.NonoActionEvent;
   import com.robot.core.event.NonoEvent;
   import com.robot.core.info.NonoImplementsToolResquestInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.SocketEvent;
   
   public class ToolCmdListener extends BaseBeanController
   {
      
      public function ToolCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_IMPLEMENT_TOOL,this.onChange);
         finish();
      }
      
      private function onChange(param1:SocketEvent) : void
      {
         var _loc2_:NonoImplementsToolResquestInfo = param1.data as NonoImplementsToolResquestInfo;
         if(_loc2_.id != MainManager.actorID)
         {
            return;
         }
         if(Boolean(NonoManager.info))
         {
            NonoManager.info.power = _loc2_.power;
            if(_loc2_.ai > NonoManager.info.ai)
            {
               NonoManager.dispatchEvent(new NonoEvent(NonoEvent.INFO_CHANGE,NonoManager.info));
            }
            NonoManager.info.ai = _loc2_.ai;
            NonoManager.info.mate = _loc2_.mate;
            NonoManager.info.iq = _loc2_.iq;
            if(_loc2_.itemId <= 700060)
            {
               NonoManager.info.func[_loc2_.itemId - 700001] = true;
            }
         }
         var _loc3_:uint = ItemXMLInfo.getPlayID(_loc2_.itemId);
         if(_loc3_ != 0)
         {
            NonoManager.dispatchAction(_loc2_.id,NonoActionEvent.NONO_PLAY,_loc3_);
         }
      }
   }
}

