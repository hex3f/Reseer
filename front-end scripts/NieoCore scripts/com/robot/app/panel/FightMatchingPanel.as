package com.robot.app.panel
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class FightMatchingPanel
   {
      
      private static var _ui:MovieClip;
      
      private static var _close:Function;
      
      public function FightMatchingPanel()
      {
         super();
      }
      
      public static function show(param1:Function) : void
      {
         if(_ui == null)
         {
            LevelManager.closeMouseEvent();
            _close = param1;
            ResourceManager.getResource(ClientConfig.getAppModule("FightWait"),onLoadTopFightMC,"TopFightWait_mc",3,false);
            MapManager.addEventListener(MapEvent.MAP_DESTROY,onMapDestory);
         }
      }
      
      private static function onLoadPvpMC(param1:MovieClip) : void
      {
         _ui = param1;
         LevelManager.appLevel.addChild(_ui);
         _ui.x = 0;
         _ui.y = 0;
         _ui["loading"].gotoAndPlay(1);
         _ui["close"].addEventListener(MouseEvent.CLICK,onCloseClick);
      }
      
      private static function onLoadTopFightMC(param1:MovieClip) : void
      {
         _ui = param1;
         LevelManager.appLevel.addChild(_ui);
         DisplayUtil.align(_ui,null,AlignType.MIDDLE_CENTER);
         _ui.x = 304;
         _ui["loading"].gotoAndPlay(1);
         _ui["drag"].addEventListener(MouseEvent.MOUSE_DOWN,onDown);
         _ui["drag"].addEventListener(MouseEvent.MOUSE_UP,onUp);
         _ui["close"].addEventListener(MouseEvent.CLICK,onCloseClick);
      }
      
      public static function hide() : void
      {
         removePanel();
         _close = null;
      }
      
      private static function onDown(param1:MouseEvent) : void
      {
         _ui.startDrag();
      }
      
      private static function onUp(param1:MouseEvent) : void
      {
         _ui.stopDrag();
      }
      
      private static function onCloseClick(param1:MouseEvent) : void
      {
         removePanel();
         if(_close != null)
         {
            _close();
            _close = null;
         }
      }
      
      private static function onMapDestory(param1:MapEvent) : void
      {
         removePanel();
         _close = null;
      }
      
      private static function removePanel() : void
      {
         if(_ui != null)
         {
            LevelManager.openMouseEvent();
            if(Boolean(_ui["drag"]))
            {
               _ui["drag"].removeEventListener(MouseEvent.MOUSE_DOWN,onDown);
               _ui["drag"].removeEventListener(MouseEvent.MOUSE_UP,onUp);
            }
            _ui["close"].removeEventListener(MouseEvent.CLICK,onCloseClick);
            DisplayUtil.removeForParent(_ui);
            _ui = null;
            MapManager.removeEventListener(MapEvent.MAP_DESTROY,onMapDestory);
            ResourceManager.cancel(ClientConfig.getAppModule("FightWait"),onLoadPvpMC);
            ResourceManager.cancel(ClientConfig.getAppModule("FightWait"),onLoadTopFightMC);
         }
      }
   }
}

