package com.robot.core.ui.loading.loadingstyle
{
   import flash.display.DisplayObjectContainer;
   
   public class ShipToSpaceLoading extends TitlePercentLoading implements ILoadingStyle
   {
      
      private static const KEY:String = "ShipToSpaceLoading";
      
      public function ShipToSpaceLoading(param1:DisplayObjectContainer, param2:String = "Loading...", param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override protected function getKey() : String
      {
         return KEY;
      }
   }
}

