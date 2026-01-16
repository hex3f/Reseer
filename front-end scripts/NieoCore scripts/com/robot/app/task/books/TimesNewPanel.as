package com.robot.app.task.books
{
   import com.robot.app.task.noviceGuide.GuideTaskModel;
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.DisplayUtil;
   
   public class TimesNewPanel
   {
      
      private static var mc:MovieClip;
      
      private static var app:ApplicationDomain;
      
      public static var messageIcon:MovieClip;
      
      private static var PATH:String = "resource/task/timeNews.swf";
      
      public function TimesNewPanel()
      {
         super();
      }
      
      public static function loadPanel() : void
      {
         var _loc1_:MCLoader = null;
         if(!mc)
         {
            _loc1_ = new MCLoader(PATH,LevelManager.topLevel,1,"正在打开《航行日志》");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,onLoad);
            _loc1_.doLoad();
         }
         else
         {
            show();
            mc.stop();
            (mc["bookMC"] as MovieClip).gotoAndStop(1);
         }
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         app = param1.getApplicationDomain();
         mc = new (app.getDefinition("timeNews") as Class)() as MovieClip;
         mc.stop();
         (mc["bookMC"] as MovieClip).stop();
         show();
      }
      
      private static function show() : void
      {
         mc.x = 567;
         mc.y = 294;
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(mc);
         var _loc1_:SimpleButton = mc["exitBtn"];
         _loc1_.addEventListener(MouseEvent.CLICK,closeHandler);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mc);
         LevelManager.openMouseEvent();
         if(GuideTaskModel.statusAry[0] == 1 && TasksManager.getTaskStatus(1) != TasksManager.COMPLETE)
         {
            SocketConnection.send(CommandID.COMPLETE_TASK,1,1);
         }
      }
      
      public static function closeBook() : void
      {
         DisplayUtil.removeForParent(mc);
         LevelManager.openMouseEvent();
      }
   }
}

