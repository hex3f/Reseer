package com.robot.app.task.books
{
   import com.robot.app.task.noviceGuide.GuideTaskModel;
   import com.robot.app.task.noviceGuide.XixiDialog;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class FlyBook
   {
      
      private static var app:ApplicationDomain;
      
      private static var mainPanel:MovieClip;
      
      private static var PATH:String = "resource/book/flyBook.swf";
      
      public function FlyBook()
      {
         super();
      }
      
      public static function loadPanel() : void
      {
         var _loc1_:MCLoader = null;
         if(!mainPanel)
         {
            _loc1_ = new MCLoader(PATH,LevelManager.topLevel,1,"正在打开飞船手册");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,onLoad);
            _loc1_.doLoad();
         }
         else
         {
            mainPanel.gotoAndStop(1);
            show();
         }
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         app = param1.getApplicationDomain();
         mainPanel = new (app.getDefinition("flyBookMC") as Class)() as MovieClip;
         mainPanel.stop();
         mainPanel.cacheAsBitmap = true;
         show();
      }
      
      private static function show() : void
      {
         DisplayUtil.align(mainPanel,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(mainPanel);
         var _loc1_:SimpleButton = mainPanel["exitBtn"];
         _loc1_.addEventListener(MouseEvent.CLICK,closeHandler);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mainPanel);
         LevelManager.openMouseEvent();
         if(TasksManager.taskList[2] == 1 && !GuideTaskModel.bReadFlyBook)
         {
            GuideTaskModel.setTaskBuf("6");
         }
         if(TasksManager.taskList[2] == 0 && MapManager.currentMap.id == 8)
         {
            XixiDialog.showNextDialog();
         }
      }
   }
}

