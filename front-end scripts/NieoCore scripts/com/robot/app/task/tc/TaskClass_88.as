package com.robot.app.task.tc
{
   import com.robot.app.task.newNovice.NewNoviceGuideTaskController;
   import com.robot.app.task.newNovice.NewNoviceStepFourController;
   import com.robot.app.task.newNovice.NewNpcDiaDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.utils.setTimeout;
   
   public class TaskClass_88
   {
      
      public function TaskClass_88(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         MainManager.actorInfo.coins += 5000;
         TasksManager.setTaskStatus(88,TasksManager.COMPLETE);
         TasksManager.setTaskStatus(4,TasksManager.COMPLETE);
         NewNoviceGuideTaskController.showTip(1);
         if(NewNoviceStepFourController.isPlay)
         {
            MapManager.currentMap.btnLevel["comMc"].gotoAndPlay(2);
            setTimeout(function():void
            {
               ItemInBagAlert.show(1,"5000" + TextFormatUtil.getRedTxt("赛尔豆") + "已经放入你的存储箱",onHandler);
            },3700);
         }
         else
         {
            ItemInBagAlert.show(1,"5000" + TextFormatUtil.getRedTxt("赛尔豆") + "已经放入你的存储箱",this.onHandler);
         }
      }
      
      private function onHandler() : void
      {
         NewNoviceGuideTaskController.destroy();
         NewNpcDiaDialog.destroy();
         MapManager.changeMap(8);
      }
   }
}

