package com.robot.app.mapProcess
{
   import com.robot.app.energy.utils.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.MovieClip;
   
   public class MapProcess_328 extends BaseMapProcess
   {
      
      private var count:uint = 0;
      
      private var _door_0:MovieClip;
      
      public function MapProcess_328()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._door_0 = conLevel["door_0"];
         this._door_0.visible = true;
      }
      
      override public function destroy() : void
      {
      }
      
      public function exploitGas() : void
      {
         EnergyController.exploit();
      }
   }
}

