package com.robot.app.RegisterCode
{
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class RegisterCodeIcon
   {
      
      private static var _regCodeIcon:SimpleButton;
      
      public function RegisterCodeIcon()
      {
         super();
      }
      
      public static function show() : void
      {
         if(TasksManager.taskList[0] == 3)
         {
            _regCodeIcon = UIManager.getButton("regCode_Icon");
            TaskIconManager.addIcon(_regCodeIcon);
            _regCodeIcon.addEventListener(MouseEvent.CLICK,onShowCodePanel);
         }
      }
      
      private static function onShowCodePanel(param1:MouseEvent) : void
      {
         CopyRegisterCodePanel.loadPanel();
      }
   }
}

