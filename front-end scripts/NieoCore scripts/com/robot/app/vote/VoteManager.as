package com.robot.app.vote
{
   import com.robot.app.energy.ore.DayOreCount;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   
   public class VoteManager
   {
      
      private static var _sendId:uint;
      
      public function VoteManager()
      {
         super();
      }
      
      public static function vote(param1:uint, param2:Array, param3:uint) : void
      {
         var id:uint = param1;
         var answer:Array = param2;
         var sendId:uint = param3;
         _sendId = sendId;
         var day:DayOreCount = new DayOreCount();
         day.addEventListener(DayOreCount.countOK,function(param1:Event):void
         {
            var _loc2_:* = 0;
            var _loc3_:Number = 0;
            if(DayOreCount.oreCount < 1)
            {
               for each(_loc3_ in answer)
               {
                  _loc2_ += Math.pow(2,_loc3_);
               }
               SocketConnection.addCmdListener(CommandID.USER_INDAGATE,onIndagate);
               SocketConnection.send(CommandID.USER_INDAGATE,1,id,_loc2_);
            }
            else
            {
               Alarm.show("你已经投过票了");
            }
         });
         day.sendToServer(sendId);
      }
      
      private static function onIndagate(param1:SocketEvent) : void
      {
         SocketConnection.addCmdListener(CommandID.TALK_CATE,onSuccess);
         SocketConnection.send(CommandID.TALK_CATE,_sendId);
      }
      
      private static function onSuccess(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,onSuccess);
         ItemInBagAlert.show(400501,"5个扭蛋牌已经放入你的储存箱");
      }
   }
}

