package com.robot.app.taskPanel
{
   import com.robot.core.mode.NpcModel;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class TaskPanelController
   {
      
      private static var _panel:TaskListPanel;
      
      public function TaskPanelController()
      {
         super();
      }
      
      public static function show(param1:NpcModel) : void
      {
         panel.setInfo(param1);
         panel.show();
         DisplayUtil.align(panel,null,AlignType.MIDDLE_CENTER);
      }
      
      private static function get panel() : TaskListPanel
      {
         if(!_panel)
         {
            _panel = new TaskListPanel();
         }
         return _panel;
      }
   }
}

