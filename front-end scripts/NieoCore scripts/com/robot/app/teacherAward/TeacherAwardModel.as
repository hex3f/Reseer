package com.robot.app.teacherAward
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import org.taomee.events.SocketEvent;
   
   public class TeacherAwardModel
   {
      
      public function TeacherAwardModel()
      {
         super();
      }
      
      public static function sendCmd() : void
      {
         SocketConnection.addCmdListener(CommandID.TEACHERREWARD_COMPLETE,onSendCompleteHandler);
         SocketConnection.send(CommandID.TEACHERREWARD_COMPLETE);
      }
      
      private static function onSendCompleteHandler(param1:SocketEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         SocketConnection.removeCmdListener(CommandID.TEACHERREWARD_COMPLETE,onSendCompleteHandler);
         var _loc4_:TeacherAwardInfo = param1.data as TeacherAwardInfo;
         if(_loc4_.getInfo.length > 0)
         {
            _loc2_ = "";
            _loc3_ = 0;
            while(_loc3_ < _loc4_.getInfo.length)
            {
               _loc2_ += ItemXMLInfo.getName(_loc4_.getInfo[_loc3_]) + ",";
               _loc3_++;
            }
            Alarm.show("你是一名优秀的教官，奖励你:" + _loc2_ + "希望你更加努力，培养更多精英。");
         }
      }
   }
}

