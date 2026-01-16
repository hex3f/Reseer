package com.robot.app.task.tc
{
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   
   public class TaskClass_42
   {
      
      public function TaskClass_42(param1:NoviceFinishInfo)
      {
         super();
         MainManager.actorInfo.coins += 3000;
         PetInStorageAlert.show(param1.petID,"卡塔已经放入了你的精灵仓库。",null,this.showTip);
      }
      
      private function showTip() : void
      {
         Alarm.show("<font color=\'#ff0000\'>时空之门</font>已经放入你的基地仓库中。",function():void
         {
            ItemInBagAlert.show(1,"<font color=\'#ff0000\'>" + 3000 + "</font>个赛尔豆已放入了你的储存箱。",function():void
            {
               TasksController.taskCompleteUI();
            });
         });
      }
   }
}

