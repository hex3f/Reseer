package com.robot.app.task.newNovice
{
   import com.robot.app.bag.BagController;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   
   public class NewNoviceStepTwoController
   {
      
      private static var _app:AppModel;
      
      private static const STEP_ID:uint = 86;
      
      public static var isPlay:Boolean = true;
      
      private static var DIA_1_A:Array = ["这套装备是预备船员的标志，现在你可以打开储存箱看一下哦。"];
      
      private static var HANDLER_A:Array = [showBag];
      
      private static var DIA_2_A:Array = ["刚刚打开的存储箱，除了存放装备外，还能收藏各种道具，在你探索的历程中会经常用到它哦。","这是战队快捷栏，当你加入或创建了战队后，你可以使用这里的快捷功能进入战队要塞，并与战队中的伙伴们通讯。","这是好友栏，在星际探索中我们离不开好友的协助，记得广交朋友，并将他们加入到你的好友名单中吧，在这里你能方便管理你的好友们。","这是基地快捷通道，每个赛尔在飞船上都有独享的一片空间。将来你可以按照自己的意愿把基地装扮得漂漂亮亮，邀请你的朋友们一起来参观哦。","你在赛尔号上的生活绝不是孤单的，除了能结交到很多朋友，更有神奇的精灵陪伴着你。来，从它们中选择你喜欢的伙伴吧！","你在赛尔号上的生活绝不是孤单的，除了能结交到很多朋友，更有神奇的精灵陪伴着你。来，从它们中选择你喜欢的伙伴吧！"];
      
      private static var HANDLER_1_A:Array = [shwoTip,shwoTip,shwoTip,shwoTip,null,showChoicePet];
      
      private static var _curIndex:uint = 7;
      
      public function NewNoviceStepTwoController()
      {
         super();
      }
      
      public static function start() : void
      {
         var stu:uint = uint(TasksManager.getTaskStatus(STEP_ID));
         switch(stu)
         {
            case TasksManager.UN_ACCEPT:
               TasksManager.accept(STEP_ID,function(param1:Boolean):void
               {
                  if(param1)
                  {
                     if(isPlay == false)
                     {
                        showChoicePet();
                        return;
                     }
                     continueHandler();
                  }
               });
               break;
            case TasksManager.ALR_ACCEPT:
               if(isPlay == false)
               {
                  showChoicePet();
                  return;
               }
               continueHandler();
         }
      }
      
      public static function continueHandler() : void
      {
         NewNoviceGuideTaskController.showTip(6);
         NewNpcDiaDialog.show(DIA_1_A,HANDLER_A);
      }
      
      private static function showBag() : void
      {
         BagController.show();
         EventManager.addEventListener(Event.CLOSE,onCloseHandler);
         EventManager.addEventListener(Event.COMPLETE,onComHandler);
      }
      
      private static function onComHandler(param1:Event) : void
      {
         EventManager.removeEventListener(Event.COMPLETE,onComHandler);
         BagController.closeEvent();
      }
      
      private static function onCloseHandler(param1:Event) : void
      {
         BagController.openEvent();
         EventManager.removeEventListener(Event.CLOSE,onCloseHandler);
         NewNpcDiaDialog.show(DIA_2_A,HANDLER_1_A);
      }
      
      private static function shwoTip() : void
      {
         NewNoviceGuideTaskController.showTip(_curIndex);
         ++_curIndex;
      }
      
      private static function showChoicePet() : void
      {
         NewNoviceGuideTaskController.showTip(1);
         if(!_app)
         {
            _app = new AppModel(ClientConfig.getTaskModule("NewNoviceTaskChoicePetPanel"),"正在打开选择精灵面板");
            _app.setup();
         }
         _app.show();
      }
      
      public static function destroy() : void
      {
         if(Boolean(_app))
         {
            _app.destroy();
            _app = null;
         }
         EventManager.removeEventListener(Event.CLOSE,onCloseHandler);
         EventManager.removeEventListener(Event.COMPLETE,onComHandler);
         DIA_2_A = null;
         HANDLER_1_A = null;
         DIA_1_A = null;
         HANDLER_A = null;
         NewNpcDiaDialog.hide();
      }
   }
}

