package com.robot.app.task.SeerInstructor
{
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class InstructorExam
   {
      
      private static var loader:MCLoader;
      
      private static var gamePanel:*;
      
      private static var curGame:Sprite;
      
      private static var PATH:String = "resource/Games/InstructorExam/Questions.swf";
      
      public function InstructorExam()
      {
         super();
      }
      
      public static function loadGame() : void
      {
         loader = new MCLoader(PATH,LevelManager.topLevel,1,"正在加载教官考试题目");
         loader.addEventListener(MCLoadEvent.SUCCESS,onLoad);
         loader.doLoad();
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         loader.removeEventListener(MCLoadEvent.SUCCESS,onLoad);
         LevelManager.topLevel.addChild(param1.getContent());
         DisplayUtil.align(param1.getContent(),null,AlignType.MIDDLE_CENTER);
         curGame = param1.getContent() as Sprite;
         param1.getContent().addEventListener("instructorExamOver",onGameOver);
      }
      
      private static function onGameOver(param1:Event) : void
      {
         gamePanel = param1.target as Sprite;
         var _loc2_:Object = gamePanel.obj;
         if(_loc2_.flag == 0)
         {
            curGame.mouseChildren = false;
            curGame.mouseEnabled = false;
            Alarm.show("你成功通过了教官预考,点击右上角图标查看考核内容",okFun);
         }
         else if(_loc2_.flag == 1)
         {
            curGame.mouseChildren = false;
            curGame.mouseEnabled = false;
            Alarm.show("你没有通过了教官预考,下次继续努力吧",failFun);
         }
         else if(_loc2_.flag == 2)
         {
            LevelManager.topLevel.removeChild(curGame);
         }
      }
      
      private static function okFun() : void
      {
         TasksManager.accept(201,onAccept);
      }
      
      private static function onAccept(param1:Boolean) : void
      {
         if(param1)
         {
            TasksManager.setTaskStatus(NewInstructorContoller.TASK_ID,TasksManager.ALR_ACCEPT);
            LevelManager.topLevel.removeChild(curGame);
            NewInstructorContoller.showIcon();
         }
      }
      
      private static function onChangeOK(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.CHANGE_TASK_STATUES,onChangeOK);
         TasksManager.taskList[200] = 2;
         LevelManager.topLevel.removeChild(curGame);
         SeerInstructorMain.start();
      }
      
      private static function failFun() : void
      {
         LevelManager.topLevel.removeChild(curGame);
      }
   }
}

