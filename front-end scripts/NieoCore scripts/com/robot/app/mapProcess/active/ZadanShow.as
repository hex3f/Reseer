package com.robot.app.mapProcess.active
{
   import com.robot.core.config.*;
   import com.robot.core.mode.*;
   
   public class ZadanShow
   {
      
      private static var panel_zd:AppModel;
      
      private static var zdOjb:Object;
      
      public static const GET_NOTHING:String = "sendgetnothing";
      
      public function ZadanShow()
      {
         super();
      }
      
      public static function show(param1:uint) : void
      {
         if(panel_zd == null)
         {
            zdOjb = new Object();
            zdOjb.num = param1;
            panel_zd = new AppModel(ClientConfig.getAppModule("ZadanPanel"),"正在打开抽奖信息");
            panel_zd.setup();
            panel_zd.show();
            panel_zd.init(zdOjb);
         }
         else
         {
            zdOjb.num = param1;
            panel_zd.init(zdOjb);
            panel_zd.show();
         }
      }
   }
}

