package com.robot.core.dayGift
{
   import com.robot.core.CommandID;
   import com.robot.core.info.task.DayTalkInfo;
   import com.robot.core.info.task.MiningCountInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.taomee.events.SocketEvent;
   
   [Event(name="countSuccess",type="com.robot.core.dayGift.DayGiftController")]
   public class DayGiftController extends EventDispatcher
   {
      
      public static const COUNT_SUCCESS:String = "countSuccess";
      
      private var type:uint;
      
      private var errortipStr:String;
      
      private var maxCount:uint;
      
      private var fun:Function;
      
      private var isError:Boolean = false;
      
      private var isGetCount:Boolean = false;
      
      private var isBuf:Boolean = false;
      
      public function DayGiftController(param1:uint, param2:uint, param3:String = "", param4:Boolean = false)
      {
         super();
         this.type = param1;
         this.errortipStr = param3;
         this.maxCount = param2;
         if(param4)
         {
            this.getCount();
         }
      }
      
      public function getCount() : void
      {
         this.isGetCount = false;
         SocketConnection.addCmdListener(CommandID.TALK_COUNT,this.onCount);
         SocketConnection.send(CommandID.TALK_COUNT,this.type);
      }
      
      private function onCount(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_COUNT,this.onCount);
         var _loc2_:MiningCountInfo = param1.data as MiningCountInfo;
         var _loc3_:uint = _loc2_.miningCount;
         this.isGetCount = true;
         this.isError = _loc3_ >= this.maxCount;
         if(this.isError)
         {
            if(this.errortipStr != "")
            {
               Alarm.show(this.errortipStr);
            }
         }
         else
         {
            dispatchEvent(new Event(COUNT_SUCCESS));
            if(this.isBuf)
            {
               this.send();
            }
         }
      }
      
      public function sendToServer(param1:Function = null) : void
      {
         this.fun = param1;
         if(!this.isGetCount)
         {
            this.isBuf = true;
            return;
         }
         this.send();
      }
      
      private function send() : void
      {
         if(this.isError)
         {
            return;
         }
         SocketConnection.addCmdListener(CommandID.TALK_CATE,this.onSend);
         SocketConnection.send(CommandID.TALK_CATE,this.type);
      }
      
      private function onSend(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onSend);
         if(this.fun != null)
         {
            this.fun(param1.data as DayTalkInfo);
         }
      }
   }
}

