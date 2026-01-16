package com.robot.app.mapProcess
{
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   
   public class MapProcess_426 extends BaseMapProcess
   {
      
      public function MapProcess_426()
      {
         super();
      }
      
      override protected function init() : void
      {
         TasksManager.getProStatusList(811,function(param1:Array):void
         {
            if(Boolean(param1[0]) && !param1[1])
            {
               return;
            }
         });
      }
      
      override public function destroy() : void
      {
         ToolBarController.showOrHideAllUser(true);
      }
   }
}

