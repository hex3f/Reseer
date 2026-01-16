package com.robot.app.mapProcess
{
   import com.robot.app.sceneInteraction.MazeController;
   import com.robot.core.manager.map.config.BaseMapProcess;
   
   public class MapProcess_311 extends BaseMapProcess
   {
      
      public function MapProcess_311()
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

