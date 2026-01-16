package com.robot.app.task.newNovice
{
   import com.robot.core.manager.TasksManager;
   
   public class NewNoviceStepFourController
   {
      
      private static const STEP_ID:uint = 88;
      
      public static var isPlay:Boolean = true;
      
      private static var DIA_1_A:Array = ["差点忘了提醒你，每期赛尔号和星球上发生的故事都会记载在航行日志上。及时关注新闻你会有更多的收获哦！","养成良好的阅读习惯，你的探索才更有目的！有了目标，那就要学会如何前往目的地。看到左下角的星盘没？上面记录着赛尔号的宇航图，通过它你就可以前往目前已经探知的星系星球了。","经历了种种学习和考验，你现在已经是名合格的飞船成员了，恭喜你！接下来的旅程会更精彩，学无止境，期待你成为赛尔号一线探索员！"];
      
      private static var HANDLER_1_A:Array = [null,showTip,conTask];
      
      public function NewNoviceStepFourController()
      {
         super();
      }
      
      public static function start() : void
      {
         var stu:uint = 0;
         if(isPlay)
         {
            NewNoviceGuideTaskController.flash();
         }
         NewNoviceGuideTaskController.showTip(1);
         stu = uint(TasksManager.getTaskStatus(STEP_ID));
         switch(stu)
         {
            case TasksManager.UN_ACCEPT:
               TasksManager.accept(STEP_ID,function(param1:Boolean):void
               {
                  if(param1)
                  {
                     if(!isPlay)
                     {
                        TasksManager.complete(88,0);
                        return;
                     }
                     continueHandler();
                  }
               });
               break;
            case TasksManager.ALR_ACCEPT:
               if(!isPlay)
               {
                  TasksManager.complete(88,0);
                  return;
               }
               continueHandler();
         }
      }
      
      public static function continueHandler() : void
      {
         NewNpcDiaDialog.show(DIA_1_A,HANDLER_1_A);
      }
      
      private static function conTask() : void
      {
         NewNoviceGuideTaskController.comStep(STEP_ID);
      }
      
      private static function showTip() : void
      {
         NewNoviceGuideTaskController.stop();
         NewNoviceGuideTaskController.showTip(11);
      }
      
      public static function destory() : void
      {
         NewNpcDiaDialog.hide();
      }
   }
}

