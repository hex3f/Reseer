package com.robot.app.task.newNovice
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class NewNoviceStepOneController
   {
      
      private static var _curPath:String;
      
      private static var _mcLoader:MCLoader;
      
      private static var _content:MovieClip;
      
      private static var _tipApp1:AppModel;
      
      private static var _tipApp2:AppModel;
      
      private static const STEP_ID:uint = 85;
      
      private static const Ai_1_Str:String = "resource/bounsMovie/firstLoginAim_1.swf";
      
      private static const Ai_2_Str:String = "resource/bounsMovie/firstLoginAim_2.swf";
      
      private static var DIA_1_A:Array = ["我是飞船机械师茜茜，欢迎你登上赛尔号飞船！看完了精彩的动画，对即将开始的探索之旅是不是很向往呢？","不过在这之前你需要对赛尔号有个大致的了解，这样才能尽快适应在飞船上的生活！我已经安排好了一堂内容丰富的课程。事不宜迟，现在就让我们开始吧！","在赛尔号内走动是很简单的，鼠标左键点击一下空地，就能移动到该位置了，当然有些地方是不可行走的！","与Npc对话也是一样，比如你以后要找我聊天时，到机械室点我就能进行交流了！","现在茜茜会为你介绍一下我们通常会使用到的一些功能。请注意看下方功能栏中最左边的选项，这是快捷语言栏，可以方便你进行一些简单的交流。","这是表情栏，你的喜怒哀乐，用适当的表情来体现，会让身边的朋友感受更深刻哦！","这是动作栏，当你穿齐一些特殊的装备时，可以做出一些特别的动作，甚至改变自己的形态！","这是瞄准栏，我们赛尔拥有头部射击的能力，这是星球中探索不可缺少的！配备不同的头具时，我们能发出的头部射击效果也会有所改变。另外一些特殊的投掷道具也会存放在这里。","嘿嘿，看你听的这么认真！嗯……好吧！我身边这套闪闪发亮的装备就送给你咯！快用鼠标左键去点它，把它收入你的储存箱中吧！","嘿嘿，看你听的这么认真！嗯……好吧！我身边这套闪闪发亮的装备就送给你咯！快用鼠标左键去点它，把它收入你的储存箱中吧！"];
      
      private static var handler_A:Array = [null,null,null,null,showTip,showTip,showTip,showTip,function():void
      {
         NewNoviceGuideTaskController.showTip(1);
      },null];
      
      private static var _index:uint = 2;
      
      public function NewNoviceStepOneController()
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
                     playAnimation(Ai_1_Str);
                  }
               });
               break;
            case TasksManager.ALR_ACCEPT:
               playAnimation(Ai_1_Str);
         }
      }
      
      public static function playAnimation(param1:String) : void
      {
         _curPath = param1;
         _mcLoader = new MCLoader(param1,LevelManager.topLevel,1,"正在打开动画");
         _mcLoader.addEventListener(MCLoadEvent.SUCCESS,onLoad);
         _mcLoader.doLoad();
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         _mcLoader.removeEventListener(MCLoadEvent.SUCCESS,onLoad);
         _content = param1.getContent() as MovieClip;
         LevelManager.topLevel.addChild(_content);
         if(_curPath == Ai_2_Str)
         {
            _content["closeBtn"].addEventListener(MouseEvent.CLICK,onAiCloseHandler);
         }
         _content.addEventListener(Event.ENTER_FRAME,onPlayComHandler);
      }
      
      private static function onPlayComHandler(param1:Event) : void
      {
         if(_content.totalFrames == _content.currentFrame)
         {
            switch(_curPath)
            {
               case Ai_1_Str:
                  showLoginTipOne();
                  break;
               case Ai_2_Str:
                  _content["closeBtn"].removeEventListener(MouseEvent.CLICK,onAiCloseHandler);
                  NewNpcDiaDialog.show(DIA_1_A,handler_A,comStep);
            }
            _content.removeEventListener(Event.ENTER_FRAME,onPlayComHandler);
            DisplayUtil.removeForParent(_content);
            _content = null;
         }
      }
      
      private static function onAiCloseHandler(param1:MouseEvent) : void
      {
         _content["closeBtn"].removeEventListener(MouseEvent.CLICK,onAiCloseHandler);
         _content.removeEventListener(Event.ENTER_FRAME,onPlayComHandler);
         DisplayUtil.removeForParent(_content);
         NewNpcDiaDialog.show(DIA_1_A,handler_A,comStep);
      }
      
      private static function showLoginTipOne() : void
      {
         if(!_tipApp1)
         {
            _tipApp1 = new AppModel(ClientConfig.getTaskModule("NewNovieTipPanelOne"),"正在打开");
            _tipApp1.setup();
            _tipApp1.sharedEvents.addEventListener(Event.OPEN,onAppOneOpenHandler);
            _tipApp1.sharedEvents.addEventListener(Event.CLOSE,onAppOneCloseHandler);
         }
         _tipApp1.show();
      }
      
      private static function hide1() : void
      {
         if(Boolean(_tipApp1))
         {
            _tipApp1.sharedEvents.removeEventListener(Event.OPEN,onAppOneOpenHandler);
            _tipApp1.sharedEvents.removeEventListener(Event.CLOSE,onAppOneCloseHandler);
            _tipApp1.destroy();
            _tipApp1 = null;
         }
      }
      
      private static function hide2() : void
      {
         if(Boolean(_tipApp2))
         {
            _tipApp2.sharedEvents.removeEventListener(Event.OPEN,onAppTwoOpenHandler);
            _tipApp2.sharedEvents.removeEventListener(Event.CLOSE,onAppTwoCloseHandler);
            _tipApp2.destroy();
            _tipApp2 = null;
         }
      }
      
      private static function onAppOneOpenHandler(param1:Event) : void
      {
         hide1();
         showLoginTipTwo();
      }
      
      private static function onAppOneCloseHandler(param1:Event) : void
      {
         hide1();
         MapManager.changeMap(8);
      }
      
      private static function showLoginTipTwo() : void
      {
         if(!_tipApp2)
         {
            _tipApp2 = new AppModel(ClientConfig.getTaskModule("NewNoviceTipPanelTwo"),"正在打开");
            _tipApp2.setup();
            _tipApp2.sharedEvents.addEventListener(Event.OPEN,onAppTwoOpenHandler);
            _tipApp2.sharedEvents.addEventListener(Event.CLOSE,onAppTwoCloseHandler);
         }
         _tipApp2.show();
      }
      
      private static function onAppTwoOpenHandler(param1:Event) : void
      {
         hide2();
         playAnimation(Ai_2_Str);
      }
      
      private static function onAppTwoCloseHandler(param1:Event) : void
      {
         hide2();
         NewNpcDiaDialog.show(DIA_1_A,handler_A,comStep);
      }
      
      private static function showTip() : void
      {
         NewNoviceGuideTaskController.showTip(_index);
         ++_index;
      }
      
      private static function comStep() : void
      {
         var mc:MovieClip = null;
         mc = null;
         LevelManager.openMouseEvent();
         mc = MapManager.currentMap.controlLevel["itemMc"];
         mc["mc"].alpha = 1;
         mc["mc1"].visible = true;
         mc["mc1"].play();
         mc.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            mc.removeEventListener(MouseEvent.CLICK,arguments.callee);
            NewNoviceGuideTaskController.comStep(STEP_ID);
            LevelManager.closeMouseEvent();
         });
      }
      
      public static function destroy() : void
      {
         DIA_1_A = null;
         handler_A = null;
         if(Boolean(_content))
         {
            _content.removeEventListener(Event.ENTER_FRAME,onPlayComHandler);
            _content = null;
         }
         if(Boolean(_mcLoader))
         {
            _mcLoader.clear();
            _mcLoader = null;
         }
         hide1();
         hide2();
         NewNpcDiaDialog.hide();
      }
   }
}

