package com.robot.app.mapProcess
{
   import com.robot.app.sceneInteraction.MazeController;
   import com.robot.core.manager.map.config.BaseMapProcess;
   
   public class MapProcess_302 extends BaseMapProcess
   {
      
      public function MapProcess_302()
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

