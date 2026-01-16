package com.robot.app.task.newNovice
{
   import com.robot.app.petbag.PetBagController;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.taomee.utils.DisplayUtil;
   
   public class NewNoviceStepThreeController
   {
      
      private static var _mcLoader:MCLoader;
      
      private static var _content:MovieClip;
      
      private static var _app:AppModel;
      
      private static const STEP_ID:uint = 87;
      
      public static var isPlay:Boolean = true;
      
      private static const DIA_1_A:Array = ["这是精灵包，用来存放你收集到的精灵。在这里你能看到精灵的状况，并能使用各种与精灵有关的功能、道具。现在打开它阅览一下吧。","在星球探索中，你会遇到各种各样的危险，精灵将会成为你的强大助力，帮助你化解各种威胁。你要与它们心意相通，并努力锻炼培养它们成长！现在让我来为你介绍一下精灵对战的基本操作吧！","在星球探索中，你会遇到各种各样的危险，精灵将会成为你的强大助力，帮助你化解各种威胁。你要与它们心意相通，并努力锻炼培养它们成长！现在让我来为你介绍一下精灵对战的基本操作吧！"];
      
      private static const HANDLER_1_A:Array = [null,showPetBag,null];
      
      private static const DIA_2_A:Array = ["怎么样，是不是很想亲自试试精灵战斗的乐趣？现在让我们来一场模拟对战吧！"];
      
      private static const HANDLER_2_A:Array = [function():void
      {
         showFight();
         NewNoviceGuideTaskController.showTip(1);
      }];
      
      private static var PATH_1:String = "resource/bounsMovie/firstLoginAim_3.swf";
      
      public function NewNoviceStepThreeController()
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
                     if(!isPlay)
                     {
                        TasksManager.complete(87,0);
                        return;
                     }
                     continueHandler();
                  }
               });
               break;
            case TasksManager.ALR_ACCEPT:
               if(!isPlay)
               {
                  TasksManager.complete(87,0);
                  return;
               }
               continueHandler();
         }
      }
      
      public static function continueHandler() : void
      {
         NewNoviceGuideTaskController.showTip(10);
         NewNpcDiaDialog.show(DIA_1_A,HANDLER_1_A,playAi);
      }
      
      private static function showPetBag() : void
      {
         PetBagController.show();
         PetBagController.closeEvent();
         NewNoviceGuideTaskController.showTip(10);
      }
      
      private static function playAi() : void
      {
         _mcLoader = new MCLoader(PATH_1,LevelManager.topLevel,1,"正在打开动画");
         _mcLoader.addEventListener(MCLoadEvent.SUCCESS,onLoad);
         _mcLoader.doLoad();
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         _mcLoader.removeEventListener(MCLoadEvent.SUCCESS,onLoad);
         _content = param1.getContent() as MovieClip;
         LevelManager.topLevel.addChild(_content);
         _content.addEventListener(Event.CLOSE,onAiCloseHandler);
      }
      
      private static function onAiCloseHandler(param1:Event) : void
      {
         _content.removeEventListener(Event.CLOSE,onAiCloseHandler);
         DisplayUtil.removeForParent(_content);
         _content = null;
         NewNpcDiaDialog.show(DIA_2_A,HANDLER_2_A);
      }
      
      private static function showFight() : void
      {
         if(!_app)
         {
            _app = new AppModel(ClientConfig.getTaskModule("NewNoviceFightPetPanel"),"正在打开");
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
         if(Boolean(_mcLoader))
         {
            _mcLoader.clear();
            _mcLoader = null;
         }
         _content = null;
         NewNpcDiaDialog.hide();
      }
   }
}

