package com.robot.app.task.control
{
   import com.robot.app.mapProcess.active.SpecialPetActive;
   import com.robot.app.task.taskscollection.Task775;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   
   public class TaskController_775
   {
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 775;
      
      public function TaskController_775()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_" + TASK_ID),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function start() : void
      {
         if(SpecialPetActive._gaiya)
         {
            NpcDialog.show(NPC.GAIYA,["我会向世界证明！谁才是真正的战神！"],["#101瑞尔斯入魔","与盖亚对战！","哇哦哦！盖亚最牛！"],[function():void
            {
               Task775.acceptTask();
            },function():void
            {
               SpecialPetActive.fightWithGaiYa();
            }]);
         }
         else
         {
            Task775.acceptTask();
         }
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

