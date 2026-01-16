package com.robot.app.mapProcess
{
   import com.robot.core.animate.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.events.*;
   
   public class MapProcess_330 extends BaseMapProcess
   {
      
      public function MapProcess_330()
      {
         super();
      }
      
      override protected function init() : void
      {
         conLevel["door_1"].visible = false;
         conLevel["door_2"].visible = false;
         conLevel["petAniMc"].visible = false;
         depthLevel["checkup"].visible = false;
         conLevel["grass"].addEventListener(MouseEvent.CLICK,this.onGrass);
      }
      
      private function onGrass(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(conLevel["grass"].currentFrame == 1)
         {
            AnimateManager.playMcAnimate(conLevel["grass"],0,"",function():void
            {
               conLevel["door_1"].visible = true;
               conLevel["grass"].buttonMode = false;
               conLevel["grass"].removeEventListener(MouseEvent.CLICK,onGrass);
            });
         }
      }
      
      override public function destroy() : void
      {
      }
      
      public function changeMap() : void
      {
         AnimateManager.playMcAnimate(conLevel["light"],0,"",function():void
         {
            MapManager.changeMap(331);
         });
      }
   }
}

