package com.robot.app.mapProcess
{
   import com.robot.app.task.petstory.app.train.TrainData;
   import com.robot.app.task.petstory.app.train.TrainItemPanel;
   import com.robot.core.manager.map.config.BaseMapProcess;
   
   public class MapProcess_485 extends BaseMapProcess
   {
      
      public function MapProcess_485()
      {
         super();
      }
      
      public function openHighTrainGradePanel() : void
      {
         TrainData.trainGrade = 1;
         new TrainItemPanel();
      }
      
      public function openLowTrainGradePanel() : void
      {
         TrainData.trainGrade = 0;
         new TrainItemPanel();
      }
   }
}

