package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.DynamicEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.Utils;
   
   public class TaskCmdListener extends BaseBeanController
   {
      
      public function TaskCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.COMPLETE_TASK,this.onComplete);
         SocketConnection.addCmdListener(CommandID.COMPLETE_DAILY_TASK,this.onComplete);
         finish();
      }
      
      private function onComplete(param1:SocketEvent) : void
      {
         var _loc2_:Class = null;
         var _loc3_:NoviceFinishInfo = param1.data as NoviceFinishInfo;
         TasksManager.setTaskStatus(_loc3_.taskID,TasksManager.COMPLETE);
         EventManager.dispatchEvent(new DynamicEvent(RobotEvent.DAILY_TASK_COMPLETE,_loc3_.taskID));
         var _loc4_:Class = Utils.getClass(TasksManager.PATH + _loc3_.taskID.toString());
         if(Boolean(_loc4_))
         {
            new _loc4_(_loc3_);
         }
         else
         {
            _loc2_ = Utils.getClass("com.robot.app.task.tc.TaskClass");
            if(Boolean(_loc2_))
            {
               new _loc2_(_loc3_);
            }
         }
      }
   }
}

