package com.robot.app.task.SeerInstructor
{
   public class InstructorController
   {
      
      private static var instructorPanel:InstructorPanel;
      
      public function InstructorController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(instructorPanel != null)
         {
            instructorPanel = null;
         }
         instructorPanel = new InstructorPanel();
         instructorPanel.show();
      }
   }
}

