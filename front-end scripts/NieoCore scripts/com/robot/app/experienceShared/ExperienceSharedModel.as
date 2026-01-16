package com.robot.app.experienceShared
{
   import com.robot.app.petUpdate.PetUpdatePropController;
   import com.robot.core.CommandID;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import org.taomee.events.SocketEvent;
   
   public class ExperienceSharedModel
   {
      
      private static var petUpdatePropCon:PetUpdatePropController;
      
      public static var isGetExp:Boolean = false;
      
      public function ExperienceSharedModel()
      {
         super();
      }
      
      public static function check() : void
      {
         if(TasksManager.getTaskStatus(201) == TasksManager.COMPLETE)
         {
            if(MainManager.actorInfo.studentID == 0)
            {
               Alarm.show("你的学员将在这里分享到你的经验.");
            }
            else
            {
               getMyExp();
            }
         }
         else if(MainManager.actorInfo.teacherID == 0)
         {
            Alarm.show("你是没有教官的自由人,有了自己的教官后,就能到这里来领取经验咯!");
         }
         else
         {
            sendCmd();
         }
      }
      
      private static function getMyExp() : void
      {
         SocketConnection.addCmdListener(CommandID.GETMYEXPERIENCE_COMPLETE,onGetMyExpCompleteHandler);
         SocketConnection.send(CommandID.GETMYEXPERIENCE_COMPLETE);
      }
      
      private static function onGetMyExpCompleteHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.GETMYEXPERIENCE_COMPLETE,onGetMyExpCompleteHandler);
         var _loc2_:GetExperienceInfo = param1.data as GetExperienceInfo;
         if(_loc2_.getExp == 0)
         {
            Alarm.show("你还没有为学员积累经验，加油！");
         }
         else
         {
            Alarm.show("你累积了 " + _loc2_.getExp + " 点经验还未被领取");
         }
      }
      
      private static function sendCmd() : void
      {
         SocketConnection.addCmdListener(CommandID.MYEXPERIENCEPOND_COMPLETE,onGetCompleteHandler);
         SocketConnection.send(CommandID.MYEXPERIENCEPOND_COMPLETE);
      }
      
      private static function onGetCompleteHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.MYEXPERIENCEPOND_COMPLETE,onGetCompleteHandler);
         var _loc2_:MyExperiencePondInfo = param1.data as MyExperiencePondInfo;
         var _loc3_:uint = _loc2_.getMyExp;
         Alert.show("教官已经积累经验值:" + _loc3_ + "\n确定要平均分配给背包里的所有精灵吗?",getExp);
      }
      
      private static function getExp() : void
      {
         SocketConnection.addCmdListener(CommandID.EXPERIENCESHARED_COMPLETE,onSendCompleteHandler);
         SocketConnection.send(CommandID.EXPERIENCESHARED_COMPLETE);
      }
      
      private static function onSendCompleteHandler(param1:SocketEvent) : void
      {
         isGetExp = true;
         SocketConnection.removeCmdListener(CommandID.EXPERIENCESHARED_COMPLETE,onSendCompleteHandler);
         var _loc2_:ExperienceSharedInfo = param1.data as ExperienceSharedInfo;
         Alarm.show("你所有精灵共获得了经验:" + _loc2_.getFraction);
      }
   }
}

