package com.robot.app.cutBmp
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.mode.AppModel;
   
   public class CutBmpController
   {
      
      private static var panel:AppModel;
      
      public static const CHAT_TYPE:uint = 1;
      
      public function CutBmpController()
      {
         super();
      }
      
      public static function show(param1:uint, param2:uint = 1) : void
      {
         if(!panel)
         {
            panel = ModuleManager.getModule(ClientConfig.getAppModule("CutBmp"),"正在初始化载图程序");
         }
         panel.init({
            "_toID":param1,
            "_type":param2
         });
         panel.setup();
         panel.show();
      }
   }
}

