package com.robot.app.task.control
{
   import com.robot.app.mapProcess.active.SpecialPetActive;
   import com.robot.app.task.taskscollection.Task748;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   
   public class TaskController_748
   {
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 748;
      
      public function TaskController_748()
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
      
      public static function startPro() : void
      {
         if(SpecialPetActive._gaiya)
         {
            NpcDialog.show(NPC.GAIYA,["我会向世界证明！谁才是真正的战神！"],["#101王者对决","与盖亚对战！","哇哦哦！盖亚最牛！"],[function():void
            {
               Task748.taskHandler();
            },function():void
            {
               SpecialPetActive.fightWithGaiYa();
            }]);
         }
         else
         {
            Task748.taskHandler();
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

