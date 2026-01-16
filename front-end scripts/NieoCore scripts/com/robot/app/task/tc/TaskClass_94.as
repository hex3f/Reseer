package com.robot.app.task.tc
{
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   
   public class TaskClass_94
   {
      
      public function TaskClass_94(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(94,TasksManager.COMPLETE);
         MainManager.actorInfo.coins += 2000;
         NpcDialog.show(NPC.CICI,["哇！你竟然这么快采集到了黄晶矿和甲烷气！这些可都是我们赛尔号上的重要能源哦！我想你应该多储备一些，以后很多地方都会利用到它们！"],["好的！我知道了!"],[function():void
         {
            NpcDialog.show(NPC.CICI,["另外，你在其他星球上还会发现很多新型的矿石，有些还需要用0xff0000电能锯子0xffffff才能切割下来。"],["电能锯子？去哪弄呢？"],[function():void
            {
               NpcDialog.show(NPC.CICI,["那可不是赛尔豆可以购买到的工具哦！通过0xff0000赫尔卡星0xffffff的拆弹考验才能获得它！好吧，我就说到这里咯，这是给你的小礼物呢！快打开看看吧！#1"],["会是什么样的礼物呢？"],[function():void
               {
                  Alarm.show("<font color=\'#ff0000\'>500积累经验</font>已经存入你的经验分配器中。",function():void
                  {
                     ItemInBagAlert.show(1,"<font color=\'#ff0000\'>1000</font>赛尔豆已放入了你的储存箱。",function():void
                     {
                        NpcDialog.show(NPC.CICI,["对了，每个新登船的小赛尔，我们的发明家肖恩老师都会为他介绍一位旅行好伙伴！至于它是谁……保密！赶快去发明室找肖恩老师，让他为你揭开谜底吧！"],["我这就去发明室看看！"],[function():void
                        {
                           TasksController.taskCompleteUI();
                        }]);
                     });
                  });
               }]);
            }]);
         }]);
      }
   }
}

