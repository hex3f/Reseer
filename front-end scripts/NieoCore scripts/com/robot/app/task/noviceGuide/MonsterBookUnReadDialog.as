package com.robot.app.task.noviceGuide
{
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.app.task.taskUtils.taskDialog.TaskBaseDialog;
   import flash.display.MovieClip;
   
   public class MonsterBookUnReadDialog
   {
      
      private static var sDialog:MovieClip;
      
      public function MonsterBookUnReadDialog()
      {
         super();
      }
      
      public static function show(param1:String = "") : void
      {
         sDialog = TaskUIManage.getMovieClip("doctorUnread",4);
         TaskBaseDialog.dialogMC = sDialog;
         TaskBaseDialog.showNpcImgDialog();
      }
   }
}

