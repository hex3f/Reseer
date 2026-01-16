package com.robot.app.npc.npcClass
{
   import com.robot.app.task.noviceGuide.TalkShiper;
   import com.robot.app.task.publicizeenvoy.PublicizeEnvoyDialog;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.manager.NpcTaskManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NpcInfo;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class NpcClass_1 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      public function NpcClass_1(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onNpcClick);
         this._curNpcModel.addEventListener(NpcEvent.TASK_WITHOUT_DES,this.onTaskWithoutDes);
         NpcTaskManager.addTaskListener(50001,this.onTaskHandler);
      }
      
      private function onTaskWithoutDes(param1:NpcEvent) : void
      {
         var _loc2_:uint = uint(param1.taskID);
         var _loc3_:* = getDefinitionByName("com.robot.app.task.control.TaskController_" + _loc2_) as Class;
         _loc3_.start();
      }
      
      private function onNpcClick(param1:NpcEvent) : void
      {
         this._curNpcModel.refreshTask();
         TalkShiper.start(param1.taskID);
      }
      
      private function onTaskHandler(param1:Event) : void
      {
         var event:Event = param1;
         if(TasksManager.getTaskStatus(25) != TasksManager.ALR_ACCEPT)
         {
            PublicizeEnvoyDialog.getInstance().show();
            return;
         }
         TasksManager.getProStatusList(25,function(param1:Array):void
         {
            var _loc2_:Boolean = Boolean(TasksManager.isComNoviceTask());
            var _loc3_:Boolean = TasksManager.getTaskStatus(4) == TasksManager.COMPLETE;
            var _loc4_:Boolean = TasksManager.getTaskStatus(94) == TasksManager.COMPLETE;
            var _loc5_:Boolean = TasksManager.getTaskStatus(19) == TasksManager.COMPLETE;
            if(_loc2_ && _loc3_ && _loc4_ && _loc5_)
            {
               TasksManager.complete(25,5);
            }
            else
            {
               PublicizeEnvoyDialog.getInstance().show();
            }
         });
      }
      
      public function destroy() : void
      {
         if(Boolean(this._curNpcModel))
         {
            this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onNpcClick);
            this._curNpcModel.destroy();
            this._curNpcModel = null;
         }
      }
      
      public function get npc() : NpcModel
      {
         return this._curNpcModel;
      }
   }
}

