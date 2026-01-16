package com.robot.app.npc
{
   import com.robot.app.taskPanel.TaskPanelController;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.info.NpcTaskInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NpcController;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class NpcInfoController extends BaseBeanController
   {
      
      public function NpcInfoController()
      {
         super();
      }
      
      private static function onDelTask(param1:SocketEvent) : void
      {
         var _loc2_:uint = (param1.data as ByteArray).readUnsignedInt();
         TasksManager.setTaskStatus(_loc2_,TasksManager.UN_ACCEPT);
         NpcController.refreshTaskInfo();
      }
      
      private static function onAddBuf(param1:SocketEvent) : void
      {
         NpcController.refreshTaskInfo();
      }
      
      private static function onCompTask(param1:SocketEvent) : void
      {
         var _loc2_:NoviceFinishInfo = param1.data as NoviceFinishInfo;
         TasksManager.setTaskStatus(_loc2_.taskID,TasksManager.COMPLETE);
         NpcController.refreshTaskInfo();
      }
      
      override public function start() : void
      {
         EventManager.addEventListener(NpcEvent.SHOW_TASK_LIST,this.npcClickHandler);
         EventManager.addEventListener(NpcEvent.COMPLETE_TASK,this.completeTaskHandler);
         SocketConnection.addCmdListener(CommandID.ADD_TASK_BUF,onAddBuf);
         SocketConnection.addCmdListener(CommandID.COMPLETE_TASK,onCompTask);
         SocketConnection.addCmdListener(CommandID.DELETE_TASK,onDelTask);
         finish();
      }
      
      private function npcClickHandler(param1:NpcEvent) : void
      {
         var _loc2_:NpcModel = param1.model;
         var _loc3_:NpcTaskInfo = _loc2_.taskInfo;
         if(_loc2_.taskInfo.acceptList.length > 0)
         {
            TaskPanelController.show(_loc2_);
         }
         else if(_loc2_.des != "")
         {
            NpcDialog.show(_loc2_.npcInfo.npcId,[_loc2_.des],_loc2_.npcInfo.questionA);
         }
         else
         {
            _loc2_.dispatchEvent(new NpcEvent(NpcEvent.NPC_CLICK,_loc2_));
         }
      }
      
      private function completeTaskHandler(param1:NpcEvent) : void
      {
         var model:NpcModel = null;
         var id:uint = 0;
         var event:NpcEvent = param1;
         model = null;
         id = 0;
         model = event.model;
         if(model.taskInfo.completeList.length > 0)
         {
            id = uint(model.taskInfo.completeList.slice().shift());
            TasksManager.complete(id,TasksXMLInfo.getTaskPorCount(id) - 1,function(param1:Boolean):void
            {
               if(param1)
               {
                  TasksManager.setTaskStatus(id,TasksManager.COMPLETE);
                  model.refreshTask();
               }
               else
               {
                  Alarm.show("提交任务失败，请稍后再试");
               }
            });
         }
      }
   }
}

