package com.robot.app.nono.featureApp
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class App_700003
   {
      
      private var _panel:AppModel;
      
      public function App_700003(param1:uint)
      {
         super();
         this._panel = new AppModel(ClientConfig.getAppModule("ExpAdmPanel"),"正在打开经验分配器");
         this._panel.setup();
         this._panel.show();
      }
   }
}

