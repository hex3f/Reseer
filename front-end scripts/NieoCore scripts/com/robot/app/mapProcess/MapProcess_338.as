package com.robot.app.mapProcess
{
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.events.*;
   
   public class MapProcess_338 extends BaseMapProcess
   {
      
      public function MapProcess_338()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.conLevel["task738_1"].visible = false;
         this.conLevel["door"].visible = false;
         conLevel["machine"].addEventListener(MouseEvent.CLICK,this.onClickMachine);
      }
      
      private function onClickMachine(param1:Event) : void
      {
      }
      
      override public function destroy() : void
      {
         conLevel["machine"].removeEventListener(MouseEvent.CLICK,this.onClickMachine);
      }
   }
}

