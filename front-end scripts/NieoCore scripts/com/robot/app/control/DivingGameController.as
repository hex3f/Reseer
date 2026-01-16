package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class DivingGameController
   {
      
      private static var panel:AppModel;
      
      public function DivingGameController()
      {
         super();
      }
      
      public static function showGame() : void
      {
         if(panel != null)
         {
            panel = null;
         }
         panel = new AppModel(ClientConfig.getGameModule("DivingBlockGame"),"正在加载游戏...");
         panel.setup();
         panel.show();
      }
      
      public static function destroy() : void
      {
         if(Boolean(panel))
         {
            panel.destroy();
         }
      }
   }
}

