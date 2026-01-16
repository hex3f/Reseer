package com.robot.app.mapProcess
{
   import com.robot.app.task.newNovice.*;
   import com.robot.app.toolBar.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   
   public class MapProcess_515 extends BaseMapProcess
   {
      
      public function MapProcess_515()
      {
         super();
      }
      
      override protected function init() : void
      {
         LevelManager.closeMouseEvent();
         this.conLevel["maskMc"].visible = false;
         ToolBarController.panel.visible = false;
         LevelManager.iconLevel.visible = false;
         NewNoviceGuideTaskController.start();
      }
      
      override public function destroy() : void
      {
         ToolBarController.panel.visible = true;
         LevelManager.iconLevel.visible = true;
         LevelManager.openMouseEvent();
      }
      
      public function clickNpc() : void
      {
      }
   }
}

