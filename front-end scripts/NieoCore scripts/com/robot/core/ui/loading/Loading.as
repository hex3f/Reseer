package com.robot.core.ui.loading
{
   import com.robot.core.ui.loading.loadingstyle.BaseLoadingStyle;
   import com.robot.core.ui.loading.loadingstyle.EmptyLoadingStyle;
   import com.robot.core.ui.loading.loadingstyle.ILoadingStyle;
   import com.robot.core.ui.loading.loadingstyle.MainLoadingStyle;
   import com.robot.core.ui.loading.loadingstyle.ShipToSpaceLoading;
   import com.robot.core.ui.loading.loadingstyle.TitleOnlyLoading;
   import com.robot.core.ui.loading.loadingstyle.TitlePercentLoading;
   import flash.display.DisplayObjectContainer;
   
   public class Loading
   {
      
      public static const NO_ALL:int = -1;
      
      public static const TITLE_AND_PERCENT:int = 1;
      
      public static const JUST_TITLE:int = 0;
      
      public static const ICON_ONLY:int = 2;
      
      public static const MAIN_LOAD:int = 3;
      
      public static const SHIP_TO_SPACE:int = 4;
      
      public function Loading()
      {
         super();
      }
      
      public static function getLoadingStyle(param1:int, param2:DisplayObjectContainer, param3:String = "Loading...", param4:Boolean = false) : ILoadingStyle
      {
         var _loc5_:ILoadingStyle = null;
         switch(param1)
         {
            case NO_ALL:
               _loc5_ = new EmptyLoadingStyle();
               break;
            case MAIN_LOAD:
               _loc5_ = new MainLoadingStyle(param2,param3,param4);
               break;
            case TITLE_AND_PERCENT:
               _loc5_ = new TitlePercentLoading(param2,param3,param4);
               break;
            case JUST_TITLE:
               _loc5_ = new TitleOnlyLoading(param2,param3,param4);
               break;
            case ICON_ONLY:
               _loc5_ = new BaseLoadingStyle(param2,param4);
               break;
            case SHIP_TO_SPACE:
               _loc5_ = new ShipToSpaceLoading(param2,param3,param4);
               break;
            default:
               _loc5_ = new EmptyLoadingStyle();
         }
         return _loc5_;
      }
   }
}

