package com.robot.app.task.tc
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.FitmentManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   
   public class TaskClass_8
   {
      
      public function TaskClass_8(param1:NoviceFinishInfo)
      {
         var _loc2_:FitmentInfo = null;
         super();
         TasksManager.setTaskStatus(8,TasksManager.COMPLETE);
         var _loc3_:uint = uint(param1.monBallList[0].itemID);
         if(_loc3_.toString().charAt(0) == "5")
         {
            _loc2_ = new FitmentInfo();
            _loc2_.id = _loc3_;
            FitmentManager.addInStorage(_loc2_);
            Alarm.show("1个" + TextFormatUtil.getRedTxt(ItemXMLInfo.getName(_loc3_)) + "已经放入你的仓库。");
         }
      }
   }
}

