package com.robot.core.cmd.nono
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.NonoActionEvent;
   import com.robot.core.event.NonoEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class NonoPlayCmdListener extends BaseBeanController
   {
      
      public function NonoPlayCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_PLAY,this.onChanged);
         finish();
      }
      
      private function onChanged(param1:SocketEvent) : void
      {
         var _loc2_:* = 0;
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:uint = _loc3_.readUnsignedInt();
         var _loc6_:uint = ItemXMLInfo.getPlayID(_loc5_);
         if(_loc6_ != 0)
         {
            NonoManager.dispatchAction(_loc4_,NonoActionEvent.NONO_PLAY,_loc6_);
         }
         if(_loc4_ != MainManager.actorID)
         {
            return;
         }
         if(Boolean(NonoManager.info))
         {
            NonoManager.info.power = _loc3_.readUnsignedInt() / 1000;
            _loc2_ = _loc3_.readUnsignedShort();
            if(_loc2_ > NonoManager.info.ai)
            {
               NonoManager.dispatchEvent(new NonoEvent(NonoEvent.INFO_CHANGE,NonoManager.info));
            }
            NonoManager.info.ai = _loc2_;
            NonoManager.info.mate = _loc3_.readUnsignedInt() / 1000;
            NonoManager.info.iq = _loc3_.readUnsignedInt();
         }
      }
   }
}

