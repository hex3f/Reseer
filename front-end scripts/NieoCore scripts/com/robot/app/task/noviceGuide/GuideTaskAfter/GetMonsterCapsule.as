package com.robot.app.task.noviceGuide.GuideTaskAfter
{
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.app.task.taskUtils.taskDialog.TaskBaseDialog;
   import flash.display.MovieClip;
   
   public class GetMonsterCapsule
   {
      
      private static var sDialog:MovieClip;
      
      public function GetMonsterCapsule()
      {
         super();
      }
      
      public static function show(param1:String = "", param2:Function = null) : void
      {
         sDialog = TaskUIManage.getMovieClip("getMonsterCapsules",4);
         TaskBaseDialog.dialogMC = sDialog;
         TaskBaseDialog.showAwardDialog(param1,param2);
      }
   }
}

