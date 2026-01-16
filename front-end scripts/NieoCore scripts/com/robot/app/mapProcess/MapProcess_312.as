package com.robot.app.mapProcess
{
   import com.robot.app.sceneInteraction.MazeController;
   import com.robot.core.manager.map.config.BaseMapProcess;
   
   public class MapProcess_312 extends BaseMapProcess
   {
      
      public function MapProcess_312()
      {
         super();
      }
      
      override protected function init() : void
      {
         MazeController.setup();
      }
      
      override public function destroy() : void
      {
         MazeController.destroy();
      }
   }
}

