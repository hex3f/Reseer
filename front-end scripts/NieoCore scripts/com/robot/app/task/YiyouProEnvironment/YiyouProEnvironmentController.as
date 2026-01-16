package com.robot.app.task.YiyouProEnvironment
{
   import com.robot.core.mode.AppModel;
   import flash.display.SimpleButton;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.EventManager;
   
   public class YiyouProEnvironmentController
   {
      
      public static const TASK_ID:uint = 404;
      
      private static var icon:SimpleButton = null;
      
      private static var panel:AppModel = null;
      
      public function YiyouProEnvironmentController()
      {
         super();
      }
      
      public static function showToolPanel() : void
      {
         EventManager.dispatchEvent(new DynamicEvent("ShowYiyouToolPanel"));
      }
   }
}

