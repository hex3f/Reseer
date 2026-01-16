package com.robot.app.task.tc
{
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.PetInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   
   public class TaskClass_36
   {
      
      private var info:NoviceFinishInfo;
      
      public function TaskClass_36(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(36,TasksManager.COMPLETE);
         this.info = param1;
         this.getLabo();
      }
      
      private function getLabo() : void
      {
         PetManager.addEventListener(PetEvent.ADDED,function(param1:PetEvent):void
         {
            PetManager.removeEventListener(PetEvent.ADDED,arguments.callee);
            PetInBagAlert.show(info.petID,"拉博已经放入了你的精灵背包。");
         });
         if(PetManager.length < 6)
         {
            PetManager.setIn(this.info.captureTm,1);
         }
         else
         {
            PetManager.addStorage(this.info.petID,this.info.captureTm);
            PetInStorageAlert.show(this.info.petID,"拉博已经放入了你的精灵仓库。");
         }
      }
   }
}

