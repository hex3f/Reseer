package com.robot.app.games.waterGunGame
{
   import com.robot.core.event.ItemEvent;
   import com.robot.core.manager.ItemManager;
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   
   public class WaterGameAward
   {
      
      public static var bExist:Boolean = false;
      
      public static const GET_WATER_GUN_GAME_AWARD_OK:String = "getWaterGunGameAwardOK";
      
      public function WaterGameAward()
      {
         super();
         ItemManager.addEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
         ItemManager.getCloth();
      }
      
      public function destroy() : void
      {
         EventManager.dispatchEvent(new Event(GET_WATER_GUN_GAME_AWARD_OK));
      }
      
      private function onClothList(param1:Event) : void
      {
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
         if(Boolean(ItemManager.containsCloth(100052)) && Boolean(ItemManager.containsCloth(100053)) && Boolean(ItemManager.containsCloth(100053)))
         {
            bExist = true;
         }
         this.destroy();
      }
   }
}

