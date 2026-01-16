package com.robot.core.ui.loading.loadingstyle
{
   import com.robot.core.manager.MainManager;
   import flash.display.DisplayObjectContainer;
   
   public class MainLoadingStyle extends TitlePercentLoading implements ILoadingStyle
   {
      
      private static const KEY:String = "mainLoad";
      
      public function MainLoadingStyle(param1:DisplayObjectContainer, param2:String = "Loading...", param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override protected function initPosition() : void
      {
         if(parentMC == null)
         {
            parentMC = MainManager.getStage();
         }
         parentMC.addChild(loadingMC);
      }
      
      override protected function getKey() : String
      {
         return KEY;
      }
   }
}

