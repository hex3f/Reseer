package com.robot.app.task.SeerInstructor
{
   import com.robot.app.task.taskUtils.baseAction.GetTaskBuf;
   import com.robot.app.task.taskUtils.baseAction.SetTaskBuf;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   
   public class InstructorWaste
   {
      
      private static var buf:String;
      
      private static var mapId:uint;
      
      public function InstructorWaste()
      {
         super();
      }
      
      public static function start() : void
      {
         if(TasksManager.taskList[200] != 1)
         {
            return;
         }
         GetTaskBuf.taskId = 201;
         GetTaskBuf.getBuf();
         EventManager.addEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetWasteOk);
      }
      
      private static function onGetWasteOk(param1:Event) : void
      {
         EventManager.removeEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetWasteOk);
         buf = GetTaskBuf.buf;
         mapId = MapManager.currentMap.id;
         switch(mapId)
         {
            case 11:
               if(buf.indexOf("1") == -1)
               {
                  (MapManager.currentMap.controlLevel["wasteMC"] as MovieClip).visible = true;
               }
               break;
            case 21:
               if(buf.indexOf("2") == -1)
               {
                  (MapManager.currentMap.controlLevel["wasteMC"] as MovieClip).visible = true;
               }
               break;
            case 32:
               if(buf.indexOf("3") == -1)
               {
                  (MapManager.currentMap.controlLevel["wasteMC"] as MovieClip).visible = true;
               }
               break;
            case 17:
               if(buf.indexOf("4") == -1)
               {
                  (MapManager.currentMap.controlLevel["wasteMC"] as MovieClip).visible = true;
               }
               break;
            case 25:
               if(buf.indexOf("5") == -1)
               {
                  (MapManager.currentMap.controlLevel["wasteMC"] as MovieClip).visible = true;
               }
         }
      }
      
      public static function setWasteBuf() : void
      {
         SetTaskBuf.taskId = 201;
         (MapManager.currentMap.controlLevel["wasteMC"] as MovieClip).visible = false;
         switch(mapId)
         {
            case 11:
               SetTaskBuf.buf = buf + "1";
               Alarm.show("你找到了电池");
               break;
            case 21:
               SetTaskBuf.buf = buf + "2";
               Alarm.show("你找到了有毒物质");
               break;
            case 32:
               SetTaskBuf.buf = buf + "3";
               Alarm.show("你找到了废弃电脑");
               break;
            case 17:
               SetTaskBuf.buf = buf + "4";
               Alarm.show("你找到了机油");
               break;
            case 25:
               SetTaskBuf.buf = buf + "5";
               Alarm.show("你找到了核废料");
         }
         SetTaskBuf.setBuf();
      }
   }
}

