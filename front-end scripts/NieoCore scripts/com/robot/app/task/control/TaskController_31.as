package com.robot.app.task.control
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.newloader.MCLoader;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.manager.ToolTipManager;
   
   public class TaskController_31
   {
      
      private static var icon:InteractiveObject;
      
      private static var lightMC:MovieClip;
      
      public static const TASK_ID:uint = 31;
      
      private static var panel:AppModel = null;
      
      public function TaskController_31()
      {
         super();
      }
      
      public static function setup() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            showIcon();
         }
      }
      
      public static function start() : void
      {
         var _loc1_:String = "不要轻敌，眼前的每一个敌人都是可怕，这是一场硬仗，只有胆大心细的小赛尔才能突破重重包围进入海盗基地，为赛尔大部队的开辟安全的进攻道路。";
         NpcTipDialog.show(_loc1_,accept,NpcTipDialog.INSTRUCTOR);
      }
      
      private static function accept() : void
      {
         TasksManager.accept(TASK_ID);
         showIcon();
         var _loc1_:String = "resource/bounsMovie/PirateFortFightTask.swf";
         var _loc2_:MCLoader = new MCLoader(_loc1_,LevelManager.topLevel,1,"正在打开任务...");
         _loc2_.addEventListener(MCLoadEvent.SUCCESS,onLoaded);
         _loc2_.doLoad();
      }
      
      private static function onLoaded(param1:MCLoadEvent) : void
      {
         var _loc3_:MovieClip = null;
         (param1.currentTarget as MCLoader).removeEventListener(MCLoadEvent.SUCCESS,onLoaded);
         var _loc2_:ApplicationDomain = param1.getApplicationDomain();
         _loc3_ = new (_loc2_.getDefinition("ReceiveTaskMC") as Class)() as MovieClip;
         LevelManager.appLevel.addChild(_loc3_);
         _loc3_.x = 480;
         _loc3_.y = 280;
      }
      
      public static function showIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("icon_31");
            icon.addEventListener(MouseEvent.CLICK,clickHandler);
            ToolTipManager.add(icon,"海盗要塞前的战斗");
            lightMC = icon["lightMC"];
         }
         TaskIconManager.addIcon(icon);
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         lightMC.gotoAndStop(lightMC.totalFrames);
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("PirateFortFight"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

