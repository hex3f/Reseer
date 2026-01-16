package com.robot.app.mapProcess.active
{
   import com.robot.app.energy.ore.DayOreCount;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class WeeklyGif
   {
      
      private static var _btn:MovieClip;
      
      public function WeeklyGif()
      {
         super();
      }
      
      public static function setup(param1:MovieClip) : void
      {
         _btn = param1;
         _btn.buttonMode = true;
         _btn.addEventListener(MouseEvent.CLICK,clickHandler);
         var _loc2_:DayOreCount = new DayOreCount();
         _loc2_.addEventListener(DayOreCount.countOK,onCount2);
         _loc2_.sendToServer(100);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         SocketConnection.addCmdListener(CommandID.TALK_CATE,onTalk2);
         SocketConnection.send(CommandID.TALK_CATE,100);
      }
      
      private static function onTalk2(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,onTalk2);
         DisplayUtil.removeForParent(_btn);
         Alarm.show("恭喜你获得" + TextFormatUtil.getRedTxt("2000点积累经验") + "，已经存入你的经验分配器中。快回基地看看吧");
      }
      
      private static function onCount2(param1:Event) : void
      {
         if(DayOreCount.oreCount >= 1)
         {
            DisplayUtil.removeForParent(_btn);
         }
      }
   }
}

