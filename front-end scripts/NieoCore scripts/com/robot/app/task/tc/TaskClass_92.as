package com.robot.app.task.tc
{
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   
   public class TaskClass_92
   {
      
      public function TaskClass_92(param1:NoviceFinishInfo)
      {
         super();
         MainManager.actorInfo.coins += 2000;
         PetInStorageAlert.show(param1.petID,"尼布已经放入了你的精灵仓库。",null,this.showTip);
      }
      
      private function showTip() : void
      {
         Alarm.show("<font color=\'#ff0000\'>2000积累经验</font>已经存入你的经验分配器中。",function():void
         {
            ItemInBagAlert.show(1,"<font color=\'#ff0000\'>2000</font>赛尔豆已放入了你的储存箱。",function():void
            {
               TasksController.taskCompleteUI();
            });
         });
      }
   }
}

