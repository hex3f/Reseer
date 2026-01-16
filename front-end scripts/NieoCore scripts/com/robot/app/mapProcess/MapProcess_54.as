package com.robot.app.mapProcess
{
   import com.robot.app.energy.utils.*;
   import com.robot.app.spacesurvey.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.MovieClip;
   
   public class MapProcess_54 extends BaseMapProcess
   {
      
      private var xllMineral:MovieClip;
      
      private var lnyMineral:MovieClip;
      
      private var ogdMineral:MovieClip;
      
      public function MapProcess_54()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.lnyMineral = conLevel["lnyMineralMC"];
         this.xllMineral = conLevel["xllMineralMC"];
         this.ogdMineral = conLevel["ogdMineralMC"];
         SpaceSurveyTool.getInstance().show("露希欧星");
      }
      
      override public function destroy() : void
      {
         SpaceSurveyTool.getInstance().hide();
      }
      
      public function onGatherLny() : void
      {
         EnergyController.exploit(1);
      }
      
      public function onGatherXll() : void
      {
         EnergyController.exploit(2);
      }
      
      public function onGatherOgd() : void
      {
         EnergyController.exploit(3);
      }
   }
}

