package com.robot.app.im.talk
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.AppModel;
   import org.taomee.ds.HashMap;
   
   public class TeamChatPanelManager
   {
      
      private static var _list:HashMap;
      
      public function TeamChatPanelManager()
      {
         super();
      }
      
      public static function showTeamChatPanel(param1:uint) : void
      {
         MapManager.addEventListener(MapEvent.MAP_SWITCH_OPEN,onMapOpen);
         var _loc2_:AppModel = getTeamChatPanel(param1);
         if(_loc2_ == null)
         {
            _loc2_ = new AppModel(ClientConfig.getAppModule("TeamChatPanel"),"正在打开战队聊天");
            _list.add(param1,_loc2_);
            _loc2_.init(param1);
            _loc2_.setup();
            _loc2_.show();
         }
      }
      
      public static function closeTalkPanel(param1:uint) : void
      {
         var _loc2_:AppModel = _list.remove(param1) as AppModel;
         if(Boolean(_loc2_))
         {
            _loc2_.destroy();
            _loc2_ = null;
         }
         if(_list.length == 0)
         {
            MapManager.removeEventListener(MapEvent.MAP_SWITCH_OPEN,onMapOpen);
         }
      }
      
      public static function closeAll() : void
      {
         _list.eachValue(function(param1:AppModel):void
         {
            param1.destroy();
            param1 = null;
         });
         _list.clear();
      }
      
      public static function getTeamChatPanel(param1:uint) : AppModel
      {
         return _list.getValue(param1) as AppModel;
      }
      
      public static function isOpen(param1:uint) : Boolean
      {
         return _list.containsKey(param1);
      }
      
      private static function onMapOpen(param1:MapEvent) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_OPEN,onMapOpen);
         closeAll();
      }
   }
}

