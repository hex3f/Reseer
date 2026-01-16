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
   
   public class SpeedupCmdListener extends BaseBeanController
   {
      
      private static var two_icon:MovieClip;
      
      private static var three_icon:MovieClip;
      
      public function SpeedupCmdListener()
      {
         super();
      }
      
      public static function showIcon() : void
      {
         if(MainManager.actorInfo.twoTimes > 0)
         {
            two_icon["txt"].text = MainManager.actorInfo.twoTimes.toString();
            ToolTipManager.add(two_icon,"双倍加速器");
            LeftToolBarManager.addIcon(two_icon);
         }
         if(MainManager.actorInfo.threeTimes > 0)
         {
            three_icon["txt"].text = MainManager.actorInfo.threeTimes.toString();
            ToolTipManager.add(three_icon,"三倍加速器");
            LeftToolBarManager.addIcon(three_icon);
         }
      }
      
      public static function delIcon() : void
      {
         if(Boolean(two_icon))
         {
            LeftToolBarManager.delIcon(two_icon);
         }
         if(Boolean(three_icon))
         {
            LeftToolBarManager.delIcon(three_icon);
         }
      }
      
      override public function start() : void
      {
         EventManager.addEventListener(RobotEvent.SPEEDUP_CHANGE,this.onChange);
         if(MainManager.actorInfo.twoTimes > 0 || MainManager.actorInfo.threeTimes > 0)
         {
            two_icon = TaskIconManager.getIcon("speedup_icon") as MovieClip;
            three_icon = TaskIconManager.getIcon("threeSpeedUp_icon") as MovieClip;
            delIcon();
            showIcon();
         }
         SocketConnection.addCmdListener(CommandID.USE_SPEEDUP_ITEM,this.onUseSpeedup);
         finish();
      }
      
      private function onUseSpeedup(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         MainManager.actorInfo.twoTimes = _loc2_.readUnsignedInt();
         MainManager.actorInfo.threeTimes = _loc2_.readUnsignedInt();
         if(MainManager.actorInfo.twoTimes > 0 || MainManager.actorInfo.threeTimes > 0)
         {
            if(!two_icon)
            {
               two_icon = TaskIconManager.getIcon("speedup_icon") as MovieClip;
            }
            if(!three_icon)
            {
               three_icon = TaskIconManager.getIcon("threeSpeedUp_icon") as MovieClip;
            }
            delIcon();
            showIcon();
         }
         else
         {
            delIcon();
         }
      }
      
      private function onChange(param1:RobotEvent) : void
      {
         if(MainManager.actorInfo.twoTimes > 0 || MainManager.actorInfo.threeTimes > 0)
         {
            delIcon();
            showIcon();
         }
         else
         {
            delIcon();
         }
      }
   }
}

