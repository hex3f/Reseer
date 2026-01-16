package com.robot.app.task.tc
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import flash.display.DisplayObjectContainer;
   
   public class TaskClass_302
   {
      
      public function TaskClass_302(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(302,TasksManager.COMPLETE);
         NpcTipDialog.show("你获得了黑晶矿,快去背包看看吧!",null,"",0,null,LevelManager.iconLevel as DisplayObjectContainer);
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

