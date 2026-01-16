package com.robot.app.PlanetExploration
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class PlanetExplorationController
   {
      
      private static var panel:AppModel;
      
      public function PlanetExplorationController()
      {
         super();
         panel = new AppModel(ClientConfig.getAppModule("PlanetExploration/PlanetExploration"),"正在打开...");
      }
      
      public static function getPanel() : AppModel
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getAppModule("PlanetExploration/PlanetExploration"),"正在打开...");
         }
         return panel;
      }
      
      public static function init() : void
      {
         var _loc1_:Object = null;
         if(panel != null)
         {
            _loc1_ = new Object();
            _loc1_.planetName = "双子阿尔法星";
            panel.init(_loc1_);
         }
      }
   }
}

