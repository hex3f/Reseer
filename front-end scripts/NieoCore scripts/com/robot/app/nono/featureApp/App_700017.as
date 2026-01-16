package com.robot.app.nono.featureApp
{
   import com.robot.app.nono.NonoController;
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class App_700017
   {
      
      public function App_700017(param1:uint)
      {
         super();
         if(MainManager.actorModel.isTransform)
         {
            Alarm.show("你目前处在变身状态不可以飞行！");
            return;
         }
         NonoController.show();
      }
   }
}

