package com.robot.app.task.tc
{
   import com.robot.app.task.AilixunIntrudeTask.AilixunIntrudeController;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.MapProcessConfig;
   import com.robot.core.ui.alert.PetInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TaskClass_15
   {
      
      private var info:NoviceFinishInfo;
      
      public function TaskClass_15(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(15,TasksManager.COMPLETE);
         var _loc2_:String = "真是个没用的家伙，我还以为你有多厉害呢！让你跟着我可真丢脸，走吧走吧，我不要你了。我继续闪……";
         NpcTipDialog.show(_loc2_,this.luoqi,NpcTipDialog.ALLISON,0,this.luoqi);
         this.info = param1;
      }
      
      private function luoqi() : void
      {
         var timer:Timer = null;
         MapProcessConfig.currentProcessInstance["showAilixunRun"]();
         timer = new Timer(3000,1);
         timer.start();
         timer.addEventListener(TimerEvent.TIMER_COMPLETE,function(param1:TimerEvent):void
         {
            var _loc2_:String = "可怜的奇洛被宇宙海盗艾里逊遗弃了，赛尔<font color=\'#ff0000\'>" + MainManager.actorInfo.nick + "</font>，你来领养它吧，要好好呵护它哦！";
            NpcTipDialog.show(_loc2_,getQiluo,NpcTipDialog.QILUO,0,getQiluo);
         });
      }
      
      private function getQiluo() : void
      {
         PetManager.addEventListener(PetEvent.ADDED,function(param1:PetEvent):void
         {
            PetManager.removeEventListener(PetEvent.ADDED,arguments.callee);
            PetInBagAlert.show(info.petID,"奇洛已经放入了你的精灵背包。");
         });
         if(PetManager.length < 6)
         {
            PetManager.setIn(this.info.captureTm,1);
         }
         else
         {
            PetManager.addStorage(this.info.petID,this.info.captureTm);
            PetInStorageAlert.show(this.info.petID,"奇洛已经放入了你的精灵仓库。");
         }
         AilixunIntrudeController.delIcon();
      }
   }
}

