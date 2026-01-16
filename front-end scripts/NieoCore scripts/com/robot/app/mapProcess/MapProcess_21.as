package com.robot.app.mapProcess
{
   import com.robot.app.energy.utils.EnergyController;
   import com.robot.app.task.SeerInstructor.NewInstructorContoller;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.mode.PetModel;
   import com.robot.core.ui.alert.Alarm;
   
   public class MapProcess_21 extends BaseMapProcess
   {
      
      private var panel:AppModel;
      
      public function MapProcess_21()
      {
         super();
      }
      
      override protected function init() : void
      {
         NewInstructorContoller.chekWaste();
      }
      
      override public function destroy() : void
      {
      }
      
      public function exploitOre() : void
      {
         EnergyController.exploit();
      }
      
      public function clearWaste() : void
      {
         NewInstructorContoller.setWaste();
      }
      
      public function fishTask() : void
      {
         if(TasksManager.getTaskStatus(407) == TasksManager.UN_ACCEPT)
         {
            return;
         }
         if(TasksManager.getTaskStatus(407) == TasksManager.COMPLETE)
         {
            Alarm.show("你已经为利牙鱼做过一次口腔护理咯，明天再来吧！");
            return;
         }
         var _loc1_:PetModel = MainManager.actorModel.pet;
         if(Boolean(_loc1_))
         {
            if(_loc1_.info.petID != 33 && _loc1_.info.petID != 34)
            {
               Alarm.show("这可是为<font color=\'#ff0000\'>利牙鱼</font>做口腔护理的装置呢，快带着它来做个护理吧！");
               return;
            }
            if(!this.panel)
            {
               this.panel = ModuleManager.getModule(ClientConfig.getGameModule("FishToothGame"),"正在打开游戏...");
               this.panel.setup();
            }
            this.panel.show();
            return;
         }
         Alarm.show("这可是为<font color=\'#ff0000\'>利牙鱼</font>做口腔护理的装置呢，快带着它来做个护理吧！");
      }
   }
}

