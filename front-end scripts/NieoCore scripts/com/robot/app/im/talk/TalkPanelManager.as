package com.robot.app.im.talk
{
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.MapManager;
   import org.taomee.ds.HashMap;
   
   public class TalkPanelManager
   {
      
      private static var _list:HashMap = new HashMap();
      
      public function TalkPanelManager()
      {
         super();
      }
      
      public static function showTalkPanel(param1:uint) : void
      {
         MapManager.addEventListener(MapEvent.MAP_SWITCH_OPEN,onMapOpen);
         var _loc2_:TalkPanel = getTalkPanel(param1);
         if(_loc2_ == null)
         {
            _loc2_ = new TalkPanel();
            _list.add(param1,_loc2_);
            _loc2_.show(param1);
         }
      }
      
      public static function closeTalkPanel(param1:uint) : void
      {
         var _loc2_:TalkPanel = _list.remove(param1) as TalkPanel;
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
         _list.eachValue(function(param1:TalkPanel):void
         {
            param1.destroy();
            param1 = null;
         });
         _list.clear();
      }
      
      public static function getTalkPanel(param1:uint) : TalkPanel
      {
         return _list.getValue(param1) as TalkPanel;
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

