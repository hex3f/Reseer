package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_28;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.PetInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   
   public class TaskClass_28
   {
      
      private var info:NoviceFinishInfo;
      
      public function TaskClass_28(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(28,TasksManager.COMPLETE);
         this.info = param1;
         var _loc2_:String = "数千万年以前的赫尔卡星人拥有过人的智慧，很久以前就开始研究建立机械精灵的开发系统。这只精灵就是他们智慧的结晶，送给你咯，好好照顾它吧！";
         NpcTipDialog.show(_loc2_,this.getQita,NpcTipDialog.DOCTOR,0,this.getQita);
      }
      
      private function getQita() : void
      {
         PetManager.addEventListener(PetEvent.ADDED,function(param1:PetEvent):void
         {
            PetManager.removeEventListener(PetEvent.ADDED,arguments.callee);
            PetInBagAlert.show(info.petID,"奇塔已经放入了你的精灵背包。");
         });
         if(PetManager.length < 6)
         {
            PetManager.setIn(this.info.captureTm,1);
         }
         else
         {
            PetManager.addStorage(this.info.petID,this.info.captureTm);
            PetInStorageAlert.show(this.info.petID,"奇塔已经放入了你的精灵仓库。");
         }
         TaskController_28.delIcon();
      }
   }
}

