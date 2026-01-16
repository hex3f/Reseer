package com.robot.app.temp
{
   import com.robot.app.energy.ore.DayOreCount;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   
   public class GetNDP
   {
      
      public function GetNDP()
      {
         super();
      }
      
      public static function send() : void
      {
         var _loc1_:DayOreCount = new DayOreCount();
         _loc1_.addEventListener(DayOreCount.countOK,onCount);
         _loc1_.sendToServer(1002);
      }
      
      private static function onCount(param1:Event) : void
      {
         if(DayOreCount.oreCount >= 1)
         {
            Alarm.show("你本周已经领取过扭蛋牌了！");
         }
         else
         {
            SocketConnection.addCmdListener(CommandID.TALK_CATE,onSuccess);
            SocketConnection.send(CommandID.TALK_CATE,1002);
         }
      }
      
      private static function onSuccess(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,onSuccess);
         Alarm.show("恭喜你获得一个<font color=\'#ff0000\'>扭蛋牌</font>");
      }
   }
}

