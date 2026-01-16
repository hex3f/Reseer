package com.robot.app.task.tc
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.ItemInBagAlert;
   
   public class TaskClass_55
   {
      
      public function TaskClass_55(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(55,TasksManager.COMPLETE);
         var _loc2_:Object = null;
         var _loc3_:String = null;
         for each(_loc2_ in param1.monBallList)
         {
            _loc3_ = ItemXMLInfo.getName(_loc2_.itemID);
            ItemInBagAlert.show(_loc2_.itemID,_loc2_.itemCnt + "个<font color=\'#ff0000\'>" + _loc3_ + "</font>已经放入你的储存箱中！");
         }
      }
   }
}

