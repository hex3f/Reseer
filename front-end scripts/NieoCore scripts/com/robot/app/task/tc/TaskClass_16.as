package com.robot.app.task.tc
{
   import com.robot.app.task.doctorTrain.DoctorTrainController;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.TextFormatUtil;
   
   public class TaskClass_16
   {
      
      public function TaskClass_16(param1:NoviceFinishInfo)
      {
         var _loc2_:Object = null;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:String = null;
         super();
         TasksManager.setTaskStatus(DoctorTrainController.TASK_ID,TasksManager.COMPLETE);
         DoctorTrainController.delIcon();
         for each(_loc2_ in param1.monBallList)
         {
            _loc3_ = uint(_loc2_["itemID"]);
            _loc4_ = uint(_loc2_["itemCnt"]);
            _loc5_ = ItemXMLInfo.getName(_loc3_);
            ItemInBagAlert.show(_loc3_,_loc4_ + "个" + TextFormatUtil.getRedTxt(_loc5_) + "已经放入你的储存箱中！");
         }
      }
   }
}

