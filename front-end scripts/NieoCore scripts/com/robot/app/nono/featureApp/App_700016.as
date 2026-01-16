package com.robot.app.nono.featureApp
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class App_700016
   {
      
      private var panel1:AppModel = null;
      
      public function App_700016(param1:uint)
      {
         super();
         this.showTip();
      }
      
      private function showTip() : void
      {
         if(this.panel1 == null)
         {
            this.panel1 = new AppModel(ClientConfig.getAppModule("PetListPanel"),"正在打开精灵面板");
            this.panel1.setup();
            this.panel1.show();
         }
         else
         {
            this.panel1.show();
         }
      }
   }
}

