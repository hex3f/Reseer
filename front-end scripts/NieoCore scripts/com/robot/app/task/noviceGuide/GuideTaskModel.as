package com.robot.app.task.noviceGuide
{
   import com.robot.app.newspaper.NewsPaper;
   import com.robot.app.task.taskUtils.baseAction.GetTaskBuf;
   import com.robot.app.task.taskUtils.baseAction.SetTaskBuf;
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   
   public class GuideTaskModel
   {
      
      private static var iconMc:SimpleButton;
      
      private static var bufTmp:String;
      
      private static var _loader:MCLoader;
      
      public static var statusAry:Array = [0,1,0,1,1];
      
      public static var bAcptTask:Boolean = false;
      
      public static const NOVICE_TASK_COMPLETE:String = "noviceTaskComplete";
      
      public static var bDone:Boolean = true;
      
      private static var PATH:String = "resource/task/novice.swf";
      
      public static var bTaskDoctor:Boolean = false;
      
      public static var bReadMonBook:Boolean = false;
      
      public static var bReadFlyBook:Boolean = false;
      
      public function GuideTaskModel()
      {
         super();
      }
      
      public static function checkTaskStatus() : void
      {
         var _loc1_:Array = TasksManager.taskList;
         if(TasksManager.taskList[1] == 3 && TasksManager.taskList[2] == 0)
         {
            DoGuideTask.doTask();
            return;
         }
         if(TasksManager.taskList[2] == 0 || TasksManager.taskList[3] == 3)
         {
            return;
         }
         if(_loader == null)
         {
            loadGuideTaskUI();
         }
         else
         {
            getTaskBuf();
         }
      }
      
      private static function loadGuideTaskUI() : void
      {
         _loader = new MCLoader(PATH,LevelManager.topLevel,1,"正在加载新手任务资源");
         _loader.addEventListener(MCLoadEvent.SUCCESS,onComplete);
         _loader.doLoad();
      }
      
      private static function onComplete(param1:MCLoadEvent) : void
      {
         _loader.removeEventListener(MCLoadEvent.SUCCESS,onComplete);
         var _loc2_:ApplicationDomain = param1.getApplicationDomain();
         TaskUIManage.loadHash.add(4,param1.getLoader());
         if(iconMc == null)
         {
            iconMc = TaskUIManage.getButton("guideTaskIcon",4);
            iconMc.addEventListener(MouseEvent.CLICK,showTaskPanel);
            TaskIconManager.addIcon(iconMc);
            ToolTipManager.add(iconMc,"新船员任务");
         }
         getTaskBuf();
      }
      
      private static function onSetTaskBufOk(param1:Event) : void
      {
         EventManager.removeEventListener(SetTaskBuf.SET_BUF_OK,onSetTaskBufOk);
         checkTaskStatus();
      }
      
      private static function getTaskBuf() : void
      {
         GetTaskBuf.taskId = 3;
         GetTaskBuf.getBuf();
         EventManager.addEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetBufOk);
      }
      
      private static function showTaskPanel(param1:MouseEvent) : void
      {
         GuideTaskController.showPanel();
      }
      
      public static function submitTask() : void
      {
         bDone = true;
         var _loc1_:int = 0;
         while(_loc1_ < statusAry.length)
         {
            if(statusAry[_loc1_] != 1)
            {
               bDone = false;
               break;
            }
            _loc1_++;
         }
         if(bDone && bReadMonBook)
         {
            SocketConnection.send(CommandID.COMPLETE_TASK,3,1);
         }
      }
      
      public static function removeIcon() : void
      {
         if(Boolean(iconMc))
         {
            TaskIconManager.delIcon(iconMc);
            ToolTipManager.remove(iconMc);
         }
      }
      
      public static function setGuideTaskBuf(param1:uint, param2:String) : void
      {
         if(statusAry[param1] == 1)
         {
            return;
         }
         if(TasksManager.taskList[2] == 1)
         {
            statusAry[param1] = 1;
            setTaskBuf(param2);
         }
         if(TasksManager.taskList[0] != 3 && statusAry[0] == 1)
         {
            (NewsPaper.timeIcon["ball"] as MovieClip).play();
            (NewsPaper.timeIcon["ball"] as MovieClip).visible = true;
         }
      }
      
      public static function setTaskBuf(param1:String) : void
      {
         GetTaskBuf.taskId = 3;
         GetTaskBuf.getBuf();
         EventManager.addEventListener(GetTaskBuf.GET_TASK_BUF_OK,onChangeBuf);
         bufTmp = param1;
      }
      
      private static function onChangeBuf(param1:Event) : void
      {
         EventManager.removeEventListener(GetTaskBuf.GET_TASK_BUF_OK,onChangeBuf);
         SetTaskBuf.taskId = 3;
         bufTmp += GetTaskBuf.taskBuf.buf;
         SetTaskBuf.buf = bufTmp;
         SetTaskBuf.setBuf();
         EventManager.addEventListener(SetTaskBuf.SET_BUF_OK,onSetTaskBufOk);
      }
      
      private static function onGetBufOk(param1:Event) : void
      {
         EventManager.removeEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetBufOk);
         var _loc2_:String = GetTaskBuf.buf;
         var _loc3_:int = 0;
         while(_loc3_ < statusAry.length)
         {
            if(_loc2_.indexOf((_loc3_ + 1).toString()) != -1)
            {
               statusAry[_loc3_] = 1;
            }
            _loc3_++;
         }
         if(_loc2_.indexOf("9") != -1)
         {
            bAcptTask = true;
         }
         if(_loc2_.indexOf("8") != -1)
         {
            bTaskDoctor = true;
            statusAry[2] = 1;
         }
         if(_loc2_.indexOf("7") != -1)
         {
            bReadMonBook = true;
         }
         if(_loc2_.indexOf("6") != -1)
         {
            bReadFlyBook = true;
         }
         if(TasksManager.taskList[0] == 3)
         {
            statusAry[0] = 1;
         }
         if(TasksManager.taskList[0] != 3 && statusAry[0] == 1)
         {
            (NewsPaper.timeIcon["ball"] as MovieClip).visible = true;
            (NewsPaper.timeIcon["ball"] as MovieClip).play();
         }
      }
   }
}

