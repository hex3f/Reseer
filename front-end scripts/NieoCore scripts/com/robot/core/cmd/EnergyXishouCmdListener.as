package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.LeftToolBarManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.display.MovieClip;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   
   public class EnergyXishouCmdListener extends BaseBeanController
   {
      
      private static var icon:MovieClip;
      
      public function EnergyXishouCmdListener()
      {
         super();
      }
      
      public static function showIcon() : void
      {
         icon["txt"].text = MainManager.actorInfo.energyTimes.toString();
         LeftToolBarManager.addIcon(icon);
         ToolTipManager.add(icon,"能量吸收器");
      }
      
      public static function delIcon() : void
      {
         ToolTipManager.remove(icon);
         LeftToolBarManager.delIcon(icon);
      }
      
      override public function start() : void
      {
         EventManager.addEventListener(RobotEvent.ENERGY_TIMES_CHANGE,this.onChange);
         icon = TaskIconManager.getIcon("EnergyClean_ui") as MovieClip;
         SocketConnection.addCmdListener(CommandID.USE_ENERGY_XISHOU,this.onUseEnergyXishou);
         if(MainManager.actorInfo.energyTimes > 0)
         {
            showIcon();
         }
         finish();
      }
      
      private function onUseEnergyXishou(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         MainManager.actorInfo.energyTimes = _loc2_.readUnsignedInt();
         if(MainManager.actorInfo.energyTimes > 0)
         {
            showIcon();
         }
         else
         {
            delIcon();
         }
      }
      
      private function onChange(param1:RobotEvent) : void
      {
         if(MainManager.actorInfo.energyTimes > 0)
         {
            showIcon();
         }
         else
         {
            delIcon();
         }
      }
   }
}

