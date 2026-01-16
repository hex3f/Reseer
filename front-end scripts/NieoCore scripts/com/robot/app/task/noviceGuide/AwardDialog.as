package com.robot.app.task.noviceGuide
{
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.app.task.taskUtils.taskDialog.TaskBaseDialog;
   import flash.display.MovieClip;
   
   public class AwardDialog
   {
      
      private static var sDialog:MovieClip;
      
      public function AwardDialog()
      {
         super();
      }
      
      public static function show(param1:String = "", param2:Function = null) : void
      {
         sDialog = TaskUIManage.getMovieClip("taskComAwardDialog",4);
         TaskBaseDialog.dialogMC = sDialog;
         TaskBaseDialog.showAwardDialog(param1,param2);
      }
   }
}

