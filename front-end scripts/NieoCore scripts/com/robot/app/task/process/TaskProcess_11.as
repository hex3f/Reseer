package com.robot.app.task.process
{
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.manager.MapManager;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.EventManager;
   
   public class TaskProcess_11
   {
      
      private static var isStart:Boolean;
      
      public static var isCatch:Boolean = false;
      
      public function TaskProcess_11()
      {
         super();
      }
      
      public static function start() : void
      {
         if(isStart)
         {
            return;
         }
         isStart = true;
         EventManager.addEventListener(PetFightEvent.CATCH_SUCCESS,onFightOver);
         MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchComplete);
      }
      
      private static function onMapSwitchComplete(param1:MapEvent) : void
      {
         if(MapManager.prevMapID == 30)
         {
            if(MapManager.getMapController().newMapID != 30)
            {
               isStart = false;
               MapManager.removeEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchComplete);
               EventManager.removeEventListener(PetFightEvent.CATCH_SUCCESS,onFightOver);
            }
         }
      }
      
      private static function onFightOver(param1:DynamicEvent) : void
      {
         if(param1.paramObject == 74)
         {
            EventManager.removeEventListener(PetFightEvent.CATCH_SUCCESS,onFightOver);
            isCatch = true;
         }
      }
   }
}

