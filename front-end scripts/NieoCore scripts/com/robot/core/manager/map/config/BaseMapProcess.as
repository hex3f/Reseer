package com.robot.core.manager.map.config
{
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.mg.MgManager;
   import flash.display.DisplayObjectContainer;
   
   public class BaseMapProcess
   {
      
      public var conLevel:DisplayObjectContainer;
      
      public var btnLevel:DisplayObjectContainer;
      
      public var topLevel:DisplayObjectContainer;
      
      public var depthLevel:DisplayObjectContainer;
      
      public var typeLevel:DisplayObjectContainer;
      
      public var animatorLevel:DisplayObjectContainer;
      
      public function BaseMapProcess()
      {
         super();
         this.conLevel = MapManager.currentMap.controlLevel;
         this.btnLevel = MapManager.currentMap.btnLevel;
         this.topLevel = MapManager.currentMap.topLevel;
         this.depthLevel = MapManager.currentMap.depthLevel;
         this.typeLevel = MapManager.currentMap.typeLevel;
         this.animatorLevel = MapManager.currentMap.animatorLevel;
         LevelManager.showMapLevel();
         if(MainManager.actorInfo.mapID >= 302 && MainManager.actorInfo.mapID <= 313)
         {
            MgManager.addIcon();
            MgManager.addMap();
         }
         else
         {
            MgManager.delIcon();
         }
         MainManager.actorModel.hideRadius();
         MainManager.actorModel.visible = true;
         this.init();
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_PROCESS_INIT,MapManager.currentMap));
      }
      
      protected function init() : void
      {
      }
      
      public function destroy() : void
      {
      }
   }
}

