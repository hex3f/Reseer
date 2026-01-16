package com.robot.app.task.dailyTask
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.SOManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.SharedObject;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class DailyTaskController
   {
      
      private static var icon:MovieClip;
      
      private static var panel:AppModel;
      
      private static var newMC:MovieClip;
      
      public function DailyTaskController()
      {
         super();
      }
      
      public static function setup() : void
      {
         showIcon();
      }
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = UIManager.getMovieClip("ui_DailyTaskIcon");
            ToolTipManager.add(icon,"赛尔精灵训练营");
            if(uint(SOManager.getUserSO(SOManager.DAILY_TASK).data["ver"]) < ClientConfig.dailyTask)
            {
            }
         }
         TaskIconManager.addIcon(icon);
         icon.addEventListener(MouseEvent.CLICK,clickHandler);
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
         ToolTipManager.remove(icon);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         if(!TasksManager.isComNoviceTask())
         {
            Alarm.show("你还没有做完新船员任务\r快去<font color=\'#ff0000\'>机械室</font>找茜茜吧");
            return;
         }
         if(panel == null)
         {
            panel = ModuleManager.getModule(ClientConfig.getTaskModule("DailyTaskPanel"),"正在打开每日任务");
            panel.setup();
         }
         panel.show();
         DisplayUtil.removeForParent(newMC);
         var _loc2_:SharedObject = SOManager.getUserSO(SOManager.DAILY_TASK);
         _loc2_.data["ver"] = ClientConfig.dailyTask;
         SOManager.flush(_loc2_);
      }
   }
}

