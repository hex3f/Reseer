package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   
   public class TaskController_131
   {
      
      public static const TASK_ID:uint = 131;
      
      private static var panel:AppModel = null;
      
      public function TaskController_131()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         var _loc1_:String = "TaskPanel_" + TASK_ID;
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule(_loc1_),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
         NpcDialog.show(NPC.JUSTIN,["你知道关于那座从火星港来的星战堡垒-英佩恩的事吗？☏1☏"],["星战堡垒，那到底是什么呢？！"],[function():void
         {
            NpcDialog.show(NPC.JUSTIN,["那是一种巨大的金属人工星体，除了外部的各种武器和护盾设备外，内部还有大量的训练用设施，对于优秀的赛尔勇士来说简直是一个天堂！"],["我也能去看看吗？！"],[function():void
            {
               NpcDialog.show(NPC.JUSTIN,["嗯，我这里正好有一个编队训练项目需要有人去试试，你愿意为我去英佩恩堡垒走一趟吗？"],["遵命！","我还没准备好..."],[function():void
               {
                  TasksManager.accept(TASK_ID);
               }]);
            }]);
         }]);
      }
      
      public static function startPro() : void
      {
         TasksManager.getProStatusList(TASK_ID,function(param1:Array):void
         {
            var arr:Array = param1;
            if(Boolean(arr[2]) && !arr[3])
            {
               NpcDialog.show(NPC.JUSTIN,["你和你的伙伴可真令我吃惊，好像目前只有为数不多的赛尔通过的那项训练。"],["嗯！"],[function():void
               {
                  NpcDialog.show(NPC.JUSTIN,["自从上次斯科尔星发现海盗踪迹以后，我一直对赛尔号的警戒有所担心，如果你可以加紧编队作战练习的话，我或许还会给你更多的机会表现哦!"],["我一定不会辜负您的！"],[function():void
                  {
                     NpcDialog.show(NPC.JUSTIN,["你可以更多尝试组队作战，下次我还会让你参加关于组队阵型的训练项目。嗯，这些是奖励，可别松懈自己的训练哦。"],["我会加油的！"],[function():void
                     {
                        TasksManager.complete(TASK_ID,3,null,true);
                     }]);
                  }]);
               }]);
            }
         });
      }
      
      public static function destroy() : void
      {
         if(Boolean(panel))
         {
            panel.destroy();
            panel = null;
         }
      }
   }
}

