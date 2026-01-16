package com.robot.app.im
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class AddFriendMsgController
   {
      
      private static var _panel:AppModel;
      
      private static var _teamPanel:AppModel;
      
      public function AddFriendMsgController()
      {
         super();
      }
      
      public static function showInviteTeamPanel(param1:Boolean = true) : void
      {
         if(_teamPanel == null)
         {
            _teamPanel = new AppModel(ClientConfig.getAppModule("AddFriendMsgPanel"),"正在加载邀请面板");
         }
         _teamPanel.setup();
         _teamPanel.init(param1);
         _teamPanel.show();
      }
      
      public static function showAddFridPanel(param1:Boolean = false) : void
      {
         if(_panel == null)
         {
            _panel = new AppModel(ClientConfig.getAppModule("AddFriendMsgPanel"),"正在加载添加好友面板");
         }
         _panel.setup();
         _panel.init(param1);
         _panel.show();
      }
   }
}

