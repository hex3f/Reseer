package com.robot.app.task.tc
{
   import com.robot.app.task.newNovice.NewNoviceStepFourController;
   import com.robot.app.task.newNovice.NewNoviceStepThreeController;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.ItemInBagAlert;
   
   public class TaskClass_87
   {
      
      public function TaskClass_87(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(87,TasksManager.COMPLETE);
         ItemInBagAlert.show(300001,"5 个" + ItemXMLInfo.getName(300001) + "已经放入你的存储箱。",function():void
         {
            ItemInBagAlert.show(300011,"5 瓶" + ItemXMLInfo.getName(300011) + "已经放入你的存储箱。",function():void
            {
               NewNoviceStepThreeController.destroy();
               NewNoviceStepFourController.start();
            });
         });
      }
   }
}

