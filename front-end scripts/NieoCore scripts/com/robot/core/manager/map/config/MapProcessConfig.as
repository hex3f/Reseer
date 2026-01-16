package com.robot.core.manager.map.config
{
   import com.robot.core.manager.map.MapType;
   import org.taomee.utils.Utils;
   
   public class MapProcessConfig
   {
      
      public static var currentProcessInstance:BaseMapProcess;
      
      private static var PATH:String = "com.robot.app.mapProcess.MapProcess_";
      
      public function MapProcessConfig()
      {
         super();
      }
      
      public static function configMap(param1:uint, param2:uint = 0) : void
      {
         var _loc3_:String = null;
         if(param1 > 50000)
         {
            switch(param2)
            {
               case MapType.HOOM:
                  _loc3_ = "com.robot.app.mapProcess.RoomMap";
                  break;
               case MapType.CAMP:
                  _loc3_ = "com.robot.app.mapProcess.FortressMap";
                  break;
               case MapType.HEAD:
                  _loc3_ = "com.robot.app.mapProcess.HeadquartersMap";
                  break;
               case MapType.PK_TYPE:
                  _loc3_ = "com.robot.app.mapProcess.PKMap";
            }
            if(_loc3_ == null || _loc3_ == "")
            {
               return;
            }
         }
         else
         {
            _loc3_ = PATH + param1.toString();
         }
         var _loc4_:Class = Utils.getClass(_loc3_);
         if(Boolean(_loc4_))
         {
            currentProcessInstance = new _loc4_() as BaseMapProcess;
         }
         else
         {
            currentProcessInstance = new BaseMapProcess();
         }
      }
      
      public static function destroy() : void
      {
         if(Boolean(currentProcessInstance))
         {
            currentProcessInstance.destroy();
         }
         currentProcessInstance = null;
      }
   }
}

