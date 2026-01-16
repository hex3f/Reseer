package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.info.SystemMsgInfo;
   import com.robot.core.info.SystemTimeInfo;
   import com.robot.core.net.SocketConnection;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class OfflineExpCmdListener
   {
      
      private var num:uint;
      
      private var panel:MovieClip;
      
      public function OfflineExpCmdListener()
      {
         super();
      }
      
      public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.OFF_LINE_EXP,this.onOffline);
      }
      
      private function onOffline(param1:SocketEvent) : void
      {
         var event:SocketEvent = param1;
         var data:ByteArray = event.data as ByteArray;
         this.num = data.readUnsignedInt();
         setTimeout(function():void
         {
            show();
         },10000);
      }
      
      private function show() : void
      {
         SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,arguments.callee);
            var _loc3_:Date = (param1.data as SystemTimeInfo).date;
            var _loc4_:SystemMsgInfo = new SystemMsgInfo();
            _loc4_.npc = 3;
            _loc4_.type = 0;
            _loc4_.msgTime = _loc3_.getTime() / 1000;
            _loc4_.msg = "    亲爱的小赛尔，在你的休息期间，你的精灵们参加了模拟训练，积累的经验已经存入<font color=\'#ffff00\'>经验分配器</font>中。\r    本次获得离线经验<font color=\'#ffff00\'>" + num + "</font>点";
            SysMsgCmdListener.getInstance().addInfo(_loc4_);
         });
         SocketConnection.send(CommandID.SYSTEM_TIME);
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.panel);
      }
   }
}

