package com.robot.app.task.SeerInstructor
{
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.core.manager.TaskIconManager;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class InstructorIcon
   {
      
      private static var _icon:SimpleButton;
      
      public function InstructorIcon()
      {
         super();
      }
      
      public static function show() : void
      {
         _icon = TaskUIManage.getButton("inIcon",201);
         TaskIconManager.addIcon(_icon);
         _icon.addEventListener(MouseEvent.CLICK,showPanel);
      }
      
      private static function showPanel(param1:MouseEvent) : void
      {
         InstructorController.show();
      }
      
      public static function removeIcon() : void
      {
         if(Boolean(_icon))
         {
            TaskIconManager.delIcon(_icon);
            _icon = null;
         }
      }
   }
}

