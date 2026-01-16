package com.robot.app.service
{
   import com.robot.app.vipSession.VipSession;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class Service
   {
      
      setup();
      
      public function Service()
      {
         super();
      }
      
      private static function setup() : void
      {
         SocketConnection.addCmdListener(CommandID.USER_CONTRIBUTE,onContribute);
      }
      
      private static function onContribute(param1:SocketEvent) : void
      {
         Alarm.show("邮件已发送成功！");
      }
      
      public static function contribute(param1:String, param2:String, param3:uint = 0) : Boolean
      {
         if(param1.replace(/ /g,"") == "")
         {
            Alarm.show("请输入标题！");
            return false;
         }
         if(param2.replace(/ /g,"") == "")
         {
            Alarm.show("请输入内容！");
            return false;
         }
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.writeUTFBytes(param1);
         if(_loc4_.length > 120)
         {
            Alarm.show("你输入的标题过长！");
            return false;
         }
         var _loc5_:ByteArray = new ByteArray();
         _loc5_.writeUTFBytes(param2);
         if(120 + _loc5_.length > 3600)
         {
            Alarm.show("你输入的内容过长！");
            return false;
         }
         _loc4_.length = 120;
         var _loc6_:uint = uint(120 + _loc5_.length);
         SocketConnection.send(CommandID.USER_CONTRIBUTE,param3,_loc6_,_loc4_,_loc5_);
         return true;
      }
      
      public static function openNono() : void
      {
         var r:VipSession = new VipSession();
         r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
         {
         });
         r.getSession();
      }
   }
}

