package com.robot.app.control
{
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   
   public class PetBreedController
   {
      
      public function PetBreedController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(TasksManager.getTaskStatus(123) == TasksManager.COMPLETE)
         {
            ModuleManager.showModule(ClientConfig.getAppModule("PetBreedPanel"),"正在加载精灵培育仓....");
         }
         else
         {
            AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("petBreedIntro"),function():void
            {
               TasksManager.complete(123,0);
               Alarm.show("恭喜你，1个" + TextFormatUtil.getRedTxt("精灵蛋") + "已经放入了孵蛋器！赶快去看看吧！",function():void
               {
                  ModuleManager.showModule(ClientConfig.getAppModule("PetBreedPanel"),"正在加载精灵培育仓....");
               });
            });
         }
      }
   }
}

