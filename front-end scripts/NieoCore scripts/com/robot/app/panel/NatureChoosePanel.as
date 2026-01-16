package com.robot.app.panel
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ModuleManager;
   
   public class NatureChoosePanel
   {
      
      private static var _petName:String;
      
      private static var _fun:Function;
      
      private static var _cancel:Function;
      
      public function NatureChoosePanel()
      {
         super();
      }
      
      public static function show(param1:String, param2:Function, param3:Function = null) : void
      {
         LevelManager.closeMouseEvent();
         MapManager.addEventListener(MapEvent.MAP_DESTROY,onMapDestory);
         _petName = param1;
         _fun = param2;
         _cancel = param3;
         ModuleManager.showModule(ClientConfig.getAppModule("NatureChooseExtPanel"),"正在加载....");
      }
      
      private static function onMapDestory(param1:MapEvent) : void
      {
         destory();
      }
      
      public static function get petName() : String
      {
         return _petName;
      }
      
      public static function fun(param1:uint) : void
      {
         if(_fun != null)
         {
            _fun(param1);
         }
         destory();
      }
      
      public static function cancel() : void
      {
         if(_cancel != null)
         {
            _cancel();
         }
         destory();
      }
      
      private static function destory() : void
      {
         LevelManager.openMouseEvent();
         MapManager.removeEventListener(MapEvent.MAP_DESTROY,onMapDestory);
         _fun = null;
         _cancel = null;
         ModuleManager.destroy(ClientConfig.getAppModule("NatureChooseExtPanel"));
      }
   }
}

