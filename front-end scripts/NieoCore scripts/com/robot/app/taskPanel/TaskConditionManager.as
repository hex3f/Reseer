package com.robot.app.taskPanel
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.xml.TaskConditionListInfo;
   import com.robot.core.config.xml.TaskConditionXMLInfo;
   import com.robot.core.config.xml.TasksXMLInfo;
   
   public class TaskConditionManager
   {
      
      public static const NPC_CLICK:uint = 0;
      
      public static const BEFOR_ACCEPT:uint = 1;
      
      public function TaskConditionManager()
      {
         super();
      }
      
      public static function getConditionStep(param1:uint) : uint
      {
         return TaskConditionXMLInfo.getConditionStep(param1);
      }
      
      public static function conditionTask(param1:uint, param2:String) : Boolean
      {
         var _loc3_:TaskConditionListInfo = null;
         if(!TasksXMLInfo.getIsCondition(param1))
         {
            return true;
         }
         var _loc4_:Array = TaskConditionXMLInfo.getConditionList(param1);
         for each(_loc3_ in _loc4_)
         {
            if(!_loc3_.getClass()[_loc3_.fun]())
            {
               NpcTipDialog.show(_loc3_.error,null,param2);
               return false;
            }
         }
         return true;
      }
   }
}

