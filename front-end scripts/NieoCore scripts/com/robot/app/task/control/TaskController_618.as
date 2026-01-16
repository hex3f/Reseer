package com.robot.app.task.control
{
   import com.robot.app.task.taskscollection.Task618;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   
   public class TaskController_618
   {
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 618;
      
      public function TaskController_618()
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
         NpcDialog.show(NPC.DOCTOR,[MainManager.actorInfo.nick + "，你来的正好！真奇怪，飞船的能量探测仪刚刚接收到比格星发出的一股神秘电波。"],["……神秘电波？","我一会再来找你吧。"],[function():void
         {
            NpcDialog.show(NPC.DOCTOR,["嗯！这股电波由两种不同的能量融合而成，其中一股和盖亚的十分相似，但是与此前相比，虚弱了许多！"],["啊？难道盖亚有危险？"],[function():void
            {
               NpcDialog.show(NPC.DOCTOR,["目前还无法确定另外一股能量，" + MainManager.actorInfo.nick + "，希望你能立刻过去探测一下……"],["好的，博士，我这就出发！"],[function():void
               {
                  TasksManager.accept(TASK_ID,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        Task618.initTask();
                     }
                  });
               }]);
            }]);
         }]);
      }
      
      public static function startPro() : void
      {
         TasksManager.getProStatusList(TASK_ID,function(param1:Array):void
         {
            var array:Array = param1;
            if(Boolean(array[0]) && Boolean(array[1]) && !array[2])
            {
               NpcDialog.show(NPC.DOCTOR,["原来是这样，" + MainManager.actorInfo.nick + "，多亏你的及时帮助，希望盖亚能早日康复！"],["嗯！博士，相信盖亚不会那么容易倒下的！"],[function():void
               {
                  NpcDialog.show(NPC.DOCTOR,["对了，听说沃尔夫洞穴内存在某种能检测盖亚能力的神秘装置，0xffff00快带上你的盖亚去看看吧0xffffff！"],["好的，博士，我知道了！"],[function():void
                  {
                     TasksManager.complete(TASK_ID,2,function(param1:Boolean):void
                     {
                        if(param1)
                        {
                        }
                     });
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

