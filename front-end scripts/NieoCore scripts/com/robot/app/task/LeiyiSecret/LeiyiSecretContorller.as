package com.robot.app.task.LeiyiSecret
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   import org.taomee.utils.DisplayUtil;
   
   public class LeiyiSecretContorller
   {
      
      private static var panel:AppModel = null;
      
      public function LeiyiSecretContorller()
      {
         super();
      }
      
      public static function show() : void
      {
         if(panel != null)
         {
            DisplayUtil.removeForParent(null);
            panel == null;
         }
         panel = new AppModel(ClientConfig.getGameModule("SpecimenAnalysis"),"正在打开任务信息");
         panel.setup();
         panel.show();
      }
   }
}

