package com.robot.app.taskPanel
{
   import com.robot.core.manager.MainManager;
   
   public class TaskCondition
   {
      
      public function TaskCondition()
      {
         super();
      }
      
      public static function haveTeam() : Boolean
      {
         return MainManager.actorInfo.teamInfo.id > 50000;
      }
   }
}

