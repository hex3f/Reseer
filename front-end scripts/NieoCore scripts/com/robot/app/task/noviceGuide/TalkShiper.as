package com.robot.app.task.noviceGuide
{
   import com.robot.app.task.control.TaskController_95;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcController;
   import com.robot.core.npc.NpcDialog;
   import flash.display.Sprite;
   
   public class TalkShiper
   {
      
      private static var npcMc:Sprite;
      
      public function TalkShiper()
      {
         super();
      }
      
      public static function start(param1:uint = 0) : void
      {
         var taskID:uint = param1;
         npcMc = NpcController.curNpc.npc.npc;
         if(taskID == 4)
         {
            talkDialog();
         }
         if(taskID == 95)
         {
            TasksManager.getProStatus(95,6,function(param1:Boolean):void
            {
               var b:Boolean = param1;
               if(b)
               {
                  NpcDialog.show(NPC.SHIPER,["摩尔庄园？菩提？葡萄？这可真的是太不思议了！！我想这番经历对你而言也一定受益匪浅吧！这是给你的奖励!！"],["立正！敬礼！"],[function():void
                  {
                     TaskController_95.showTaskPanel(8);
                  }]);
               }
               else
               {
                  NpcDialog.show(NPC.SHIPER,["查明黑色旋涡的缘由分秒必争！你必须抓紧时间！如果赛尔号持续被吸附在黑洞里，我们的能源随时都会耗尽……到时候，后果不堪设想！"],["我这就行动！"]);
               }
            });
         }
      }
      
      private static function talkDialog() : void
      {
         if(TasksManager.getTaskStatus(1) != 3 && GuideTaskModel.statusAry[0] == 1)
         {
            ShiperUnReadDialog.show("",okFun);
            return;
         }
         switch(TasksManager.getTaskStatus(3))
         {
            case 0:
               NpcTipDialog.show("新来的赛尔，你好！我是这艘赛尔号飞船的船长，一些重要的任务都是由我来发布的！",okFun,"",-60,exitFun);
               break;
            case 1:
               if(GuideTaskModel.statusAry[0] == 1)
               {
                  NpcTipDialog.show("你可以通过右上方的任务按钮来了解到你的任务正进行到哪一步。",okFun,"",-60,exitFun);
                  break;
               }
               NpcTipDialog.show("新来的赛尔，你好！我是这艘赛尔号飞船的船长，一些重要的任务都是由我来发布的！",showNextTalk,"",-60,exitFun);
               break;
            case 3:
               NpcTipDialog.show("你可以经常来我这里看看是不是有最新任务的发布。",okFun,"",-60,exitFun);
         }
      }
      
      private static function onAccepteTaskHandler() : void
      {
      }
      
      private static function showNextTalk() : void
      {
         NpcTipDialog.show("你有没有注意到左上角的航行日志呢？航行日志记录着赛尔号每周的最新发现。",okFun,"",-60,exitFun);
      }
      
      private static function okFun() : void
      {
         if(TasksManager.getTaskStatus(3) != 1 || GuideTaskModel.statusAry[0] == 1)
         {
            return;
         }
         GuideTaskModel.setGuideTaskBuf(0,"1");
      }
      
      public static function exitFun() : void
      {
      }
   }
}

