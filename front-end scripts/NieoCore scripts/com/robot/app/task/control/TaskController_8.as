package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class TaskController_8
   {
      
      private static var _panel:AppModel;
      
      public function TaskController_8()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(_panel == null)
         {
            _panel = new AppModel(ClientConfig.getTaskModule("XitaTaskPanel"),"正在打开西塔的珍贵回忆");
            _panel.setup();
         }
         _panel.show();
      }
   }
}

