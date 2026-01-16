package com.robot.app.temp
{
   import com.robot.core.CommandID;
   import com.robot.core.info.SystemMsgInfo;
   import com.robot.core.info.SystemTimeInfo;
   import com.robot.core.net.SocketConnection;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.events.SocketEvent;
   
   public class SysMailController
   {
      
      private static var timer:Timer;
      
      private static var obj:Object = new Object();
      
      public function SysMailController()
      {
         super();
      }
      
      public static function setup() : void
      {
         timer = new Timer(600000);
         timer.addEventListener(TimerEvent.TIMER,onTimer);
         timer.start();
      }
      
      private static function onTimer(param1:TimerEvent) : void
      {
         var event:TimerEvent = param1;
         SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,arguments.callee);
            var _loc3_:Date = (param1.data as SystemTimeInfo).date;
            if(_loc3_.getDate() == 5)
            {
               checkDate(_loc3_);
            }
         });
         SocketConnection.send(CommandID.SYSTEM_TIME);
      }
      
      private static function checkDate(param1:Date) : void
      {
         var _loc2_:SystemMsgInfo = new SystemMsgInfo();
         _loc2_.msgTime = param1.getTime() / 1000;
         _loc2_.npc = 3;
      }
   }
}

