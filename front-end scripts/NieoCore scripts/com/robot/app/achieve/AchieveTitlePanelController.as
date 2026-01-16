package com.robot.app.achieve
{
   import com.robot.core.info.AchieveTitleInfo;
   import flash.display.DisplayObjectContainer;
   
   public class AchieveTitlePanelController
   {
      
      private static var _panel:AchieveTitlePanel;
      
      private static var _status:Boolean = false;
      
      public function AchieveTitlePanelController()
      {
         super();
      }
      
      public static function hide() : void
      {
         if(Boolean(_panel))
         {
            _panel.hide();
         }
      }
      
      public static function show(param1:AchieveTitleInfo, param2:DisplayObjectContainer) : void
      {
         if(_panel == null)
         {
            _panel = new AchieveTitlePanel();
         }
         _panel.show(param1,param2);
      }
      
      public static function set setStatus(param1:Boolean) : void
      {
         _status = param1;
      }
      
      public static function get getStatus() : Boolean
      {
         return _status;
      }
   }
}

