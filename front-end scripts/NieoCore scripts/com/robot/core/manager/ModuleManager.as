package com.robot.core.manager
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   import flash.utils.getQualifiedClassName;
   import org.taomee.ds.HashMap;
   
   public class ModuleManager
   {
      
      private static var app:AppModel;
      
      private static var _moduleMap:HashMap = new HashMap();
      
      public function ModuleManager()
      {
         super();
      }
      
      public static function get currentApp() : AppModel
      {
         return app;
      }
      
      public static function getModule(param1:String, param2:String) : AppModel
      {
         var _loc3_:AppModel = _moduleMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return _loc3_;
         }
         _loc3_ = new AppModel(param1,param2);
         _moduleMap.add(param1,_loc3_);
         return _loc3_;
      }
      
      public static function showModule(param1:String, param2:String = "正在打开...", param3:Object = null) : void
      {
         app = _moduleMap.getValue(param1);
         if(Boolean(app))
         {
            if(param3 != null)
            {
               app.init(param3);
            }
            app.show();
            return;
         }
         app = new AppModel(param1,param2);
         _moduleMap.add(param1,app);
         app.setup();
         if(param3 != null)
         {
            app.init(param3);
         }
         app.show();
      }
      
      public static function destroyForInstance(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = getQualifiedClassName(param1);
         var _loc6_:uint = _loc5_.split(".").length - 1;
         if(_loc6_ == 4)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc5_.length)
            {
               if(_loc5_.charAt(_loc3_) == ".")
               {
                  _loc4_++;
               }
               if(_loc4_ == 3)
               {
                  _loc2_ = _loc3_;
                  break;
               }
               _loc3_++;
            }
         }
         else
         {
            _loc2_ = int(_loc5_.lastIndexOf("."));
         }
         _loc5_ = _loc5_.substr(_loc2_ + 1);
         _loc5_ = _loc5_.split("::").join("/");
         if(_loc6_ == 4)
         {
            _loc5_ = _loc5_.split(".").join("/");
         }
         _loc5_ = ClientConfig.getModule(_loc5_);
         destroy(_loc5_);
      }
      
      public static function destroy(param1:String) : void
      {
         app = _moduleMap.remove(param1);
         if(Boolean(app))
         {
            app.destroy();
            app = null;
         }
      }
      
      public static function remove(param1:String) : void
      {
         _moduleMap.remove(param1);
      }
   }
}

