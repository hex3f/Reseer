package com.robot.app.messagetool
{
   import com.robot.app.task.control.TaskController_38;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MessageTool
   {
      
      public static var messageTool:MovieClip;
      
      private static var timer:Timer;
      
      public function MessageTool()
      {
         super();
      }
      
      public static function start() : void
      {
         if(TasksManager.getTaskStatus(TaskController_38.TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatus(TaskController_38.TASK_ID,1,function(param1:Boolean):void
            {
               var b:Boolean = param1;
               if(b)
               {
                  messageTool = TaskIconManager.getIcon("message_icon") as MovieClip;
                  messageTool.x = 55;
                  messageTool.y = 100;
                  messageTool.mouseChildren = false;
                  ToolTipManager.add(messageTool,"消息器");
                  messageTool.buttonMode = true;
                  LevelManager.iconLevel.addChild(messageTool);
                  messageTool.gotoAndStop(2);
                  timer = new Timer(3000);
                  timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
                  {
                     timer.stop();
                     timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
                     messageTool.gotoAndStop(1);
                  });
                  messageTool.addEventListener(MouseEvent.MOUSE_OVER,function():void
                  {
                     messageTool.gotoAndStop(2);
                  });
                  messageTool.addEventListener(MouseEvent.MOUSE_OUT,function():void
                  {
                     messageTool.gotoAndStop(1);
                  });
                  messageTool.addEventListener(MouseEvent.CLICK,showMessagePanel);
               }
            });
         }
      }
      
      public static function destroy() : void
      {
         messageTool.removeEventListener(MouseEvent.CLICK,showMessagePanel);
         ToolTipManager.remove(messageTool);
         DisplayUtil.removeForParent(messageTool);
         messageTool = null;
      }
      
      public static function showMessagePanel(param1:Event) : void
      {
         var e:Event = param1;
         TasksManager.getProStatusList(TaskController_38.TASK_ID,function(param1:Array):void
         {
            if(Boolean(param1[1]) && !param1[4])
            {
               NpcTipDialog.show("为了保证任务的顺利完成，完美专业的装备是非常必要的。\n    快去做准备吧！",null,NpcTipDialog.IRIS);
            }
         });
         TasksManager.getProStatusList(TaskController_38.TASK_ID,function(param1:Array):void
         {
            if(Boolean(param1[4]) && !param1[8])
            {
               NpcTipDialog.show("在飞船上不要被周围的奇怪现象吓住，找出问题的核心。\n    继续努力哦！",null,NpcTipDialog.IRIS);
            }
         });
         TasksManager.getProStatus(TaskController_38.TASK_ID,8,function(param1:Boolean):void
         {
            if(param1)
            {
               NpcTipDialog.show("侦查眼罩可以发现飞船中的各种奇异显现。\n    吸纳仪帮你抓住状况不明的精灵。\n    NoNo的雷达芯片可以从迷宫环境中解救你哦！",null,NpcTipDialog.IRIS);
            }
         });
      }
   }
}

