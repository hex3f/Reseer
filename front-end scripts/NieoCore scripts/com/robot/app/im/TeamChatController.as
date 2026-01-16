package com.robot.app.im
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.ui.alert.Alarm;
   
   public class TeamChatController
   {
      
      private static var _panel:AppModel;
      
      public static var isOpen:Boolean = false;
      
      public function TeamChatController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(_panel == null)
         {
            if(MainManager.actorInfo.teamInfo.id < 50000)
            {
               Alarm.show("战队不存在!");
               return;
            }
            _panel = ModuleManager.getModule(ClientConfig.getAppModule("TeamChatPanel"),"正在打开战队聊天");
            _panel.init(MainManager.actorInfo.teamInfo.id);
            _panel.setup();
         }
         _panel.show();
         isOpen = true;
      }
   }
}

