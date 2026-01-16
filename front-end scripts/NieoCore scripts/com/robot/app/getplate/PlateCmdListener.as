package com.robot.app.getplate
{
   import com.robot.core.CommandID;
   import com.robot.core.info.GetPlateInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import org.taomee.events.SocketEvent;
   
   public class PlateCmdListener extends BaseBeanController
   {
      
      public function PlateCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.MEDAL_GET_COUNT,this.onPlateGet);
         finish();
      }
      
      private function onPlateGet(param1:SocketEvent) : void
      {
         var _loc2_:GetPlateInfo = param1.data as GetPlateInfo;
         Alarm.show("恭喜你获得了" + _loc2_.PlateCount + "枚<font color=\'#FF0000\'>斯诺冰牌</font>");
         MainManager.actorInfo.monBtlMedal += _loc2_.PlateCount;
      }
   }
}

