package com.robot.app.paintBook
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.mode.AppModel;
   
   public class PaintBookController
   {
      
      private static var panel:AppModel;
      
      public function PaintBookController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(!panel)
         {
            panel = ModuleManager.getModule(ClientConfig.getBookModule("PaintBook"),"正在打开赛尔画廊");
            panel.setup();
         }
         panel.show();
      }
   }
}

