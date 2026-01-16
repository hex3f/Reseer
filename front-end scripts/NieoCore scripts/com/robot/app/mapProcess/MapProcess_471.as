package com.robot.app.mapProcess
{
   import com.robot.app.task.petstory.app.train.TrainControl;
   import com.robot.core.manager.map.config.BaseMapProcess;
   
   public class MapProcess_471 extends BaseMapProcess
   {
      
      private var _mapID:uint = 471;
      
      public function MapProcess_471()
      {
         super();
      }
      
      override protected function init() : void
      {
         TrainControl.init(this);
      }
      
      override public function destroy() : void
      {
         TrainControl.destory();
      }
   }
}

