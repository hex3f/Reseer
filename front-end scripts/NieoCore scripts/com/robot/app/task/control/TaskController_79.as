package com.robot.app.task.control
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import org.taomee.utils.DisplayUtil;
   
   public class TaskController_79
   {
      
      private static var longMc:MovieClip;
      
      private static var _long:MovieClip;
      
      private static var btn:SimpleButton;
      
      private static var btn1:SimpleButton;
      
      public static var panel0:AppModel;
      
      public static var panel:AppModel;
      
      public static const TASK_ID:uint = 79;
      
      public static var isMoFangB:Boolean = false;
      
      public static var clickSt:uint = 0;
      
      private static var overn:uint = 0;
      
      public function TaskController_79()
      {
         super();
      }
      
      public static function start() : void
      {
         showPanel();
      }
      
      public static function dongHua2() : void
      {
         _long.visible = false;
         longMc.gotoAndPlay(90);
         longMc.addFrameScript(306,endDh1);
         MainManager.actorModel.visible = false;
      }
      
      private static function endDh1() : void
      {
         longMc.addFrameScript(306,null);
         longMc.stop();
         clickHuMo0();
      }
      
      public static function initLong(param1:MovieClip, param2:MovieClip, param3:SimpleButton, param4:SimpleButton) : void
      {
         longMc = param1;
         _long = param2;
         btn = param3;
         btn1 = param4;
      }
      
      public static function clickS0() : void
      {
         NpcTipDialog.show("咦？怎么没反应啊？是不是我找错地方了呢？要不我再踩两脚试试？",function():void
         {
            overn = 2;
            playD();
         },NpcTipDialog.SEER,0,null,null,false);
      }
      
      public static function hamolt() : void
      {
         NpcTipDialog.show("好家伙！你比我还大( ⊙ o ⊙ )！你好，我叫哈莫雷特，你可以管我叫哈莫，你呢？",function():void
         {
            _long.visible = false;
            longMc.gotoAndPlay(2);
            longMc.addFrameScript(88,endDh0);
         },NpcTipDialog.HAMULEITE,0,null,null,false);
      }
      
      private static function endDh0() : void
      {
         _long.visible = false;
         longMc.addFrameScript(88,null);
         longMc.stop();
         TasksManager.complete(TASK_ID,1,function(param1:Boolean):void
         {
            if(param1)
            {
               showPanel();
            }
         });
      }
      
      public static function playD() : void
      {
         playMovie("resource/bounsMovie/task79donghua1.swf");
         overn = 2;
      }
      
      public static function inScean() : void
      {
         if(isMoFangB)
         {
            NpcTipDialog.show(MainManager.actorInfo.nick + "，我也不知道为什么，我就是莫名的紧张……难道是因为马上要和族人见面了？但是，我总感觉O__O!…",function():void
            {
               NpcTipDialog.show("大块头，别想这么多啦！我这就用博士的仪器帮你测测那个精灵所在的方位哦！",function():void
               {
                  TasksManager.complete(TASK_ID,0,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        _long.visible = true;
                        btn.enabled = true;
                        showPanel();
                     }
                  });
               },NpcTipDialog.SEER,0,null,null,false);
            },NpcTipDialog.HAMULEITE,0,null,null,false);
         }
      }
      
      private static function seerOut() : void
      {
         NpcTipDialog.show("……大块头你刚才和那家伙叽里呱啦到底在说些什么？什么塔西什么吼吼的？",function():void
         {
            NpcTipDialog.show("它说这里是它的领地，我们涉足了它的地盘！它是不会就此罢休的……至于我说了什么呢？嘿嘿，我才不告诉你呢！不过，" + MainManager.actorInfo.nick + "你永远都会是我的伙伴！！！！",function():void
            {
               NpcTipDialog.show("刚才那家伙一定是龙系的精灵！但是它为什么不认识哈莫呢？哈莫的背后到底藏着什么样的故事呢？算了！不要想这么多了……我相信谜底终究会有一天解开的！哈莫永远都是我的朋友！！",function():void
               {
                  TasksManager.complete(TASK_ID,2,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        btn.visible = false;
                     }
                  });
               },NpcTipDialog.SEER,0,null,null,false);
            },NpcTipDialog.HAMULEITE,0,null,null,false);
         },NpcTipDialog.SEER,0,null,null,false);
      }
      
      public static function clickHuMo0() : void
      {
         NpcTipDialog.show("你……你快走！我不会让你受到任何伤害的！快！快……",function():void
         {
            NpcTipDialog.show("呆子！我们是朋友不是吗？我们共同进退！哈莫你不能用蛮力去对抗它，你听我说，现在你先使出" + TextFormatUtil.getRedTxt("龙之意志") + "，它可以提升你的能力！",function():void
            {
               longMc.gotoAndPlay(309);
               longMc.addFrameScript(383,endDH2);
            },NpcTipDialog.SEER,0,null,null,false);
         },NpcTipDialog.HAMULEITE,0,null,null,false);
      }
      
      private static function endDH2() : void
      {
         longMc.addFrameScript(383,null);
         longMc.stop();
         talkSeer();
      }
      
      private static function talkSeer() : void
      {
         NpcTipDialog.show("再使出" + TextFormatUtil.getRedTxt("龙王灭碎阵") + "…恶龙！接招吧！！！",function():void
         {
            longMc.gotoAndPlay(385);
            longMc.addFrameScript(458,endDH3);
         },NpcTipDialog.SEER,0,null,null,false);
      }
      
      private static function endDH3() : void
      {
         longMc.addFrameScript(458,null);
         longMc.stop();
         talkEl();
      }
      
      private static function talkEl() : void
      {
         NpcTipDialog.show("叽咕吼…*&#吼吧喇喷！…%#&",function():void
         {
            NpcTipDialog.show("塔西摩多…哈莫%…￥…#吼巳！！！！！！！！",function():void
            {
               longMc.gotoAndPlay(460);
               longMc.addFrameScript(546,endDH4);
            },NpcTipDialog.HAMULEITE,0,null,null,false);
         },NpcTipDialog.ELONG,0,null,null,false);
      }
      
      private static function endDH4() : void
      {
         longMc.gotoAndStop(1);
         longMc.addFrameScript(546,null);
         _long.visible = true;
         MainManager.actorModel.visible = true;
         seerOut();
      }
      
      public static function clickHuMo() : void
      {
         TasksManager.getProStatusList(TASK_ID,function(param1:Array):void
         {
            var arr:Array = param1;
            if(!arr[0])
            {
               NpcTipDialog.show("吼吼吼……我是大块头！大块头有大智慧！走!" + MainManager.actorInfo.nick + "，我们一起去塔克星找我的族人吧！我想它们一定和我一样高大威猛！到时候，我一定介绍给你认识！O(∩_∩)O",function():void
               {
                  NpcTipDialog.show("不知道大块头的族人长着什么样呢？和那家伙一样这么大吗？它们是不是很好相处呢？算了，不想这么多了！我们这就启程！塔克星……我们来啦！",function():void
                  {
                     playMovie("resource/bounsMovie/task79donghua0.swf");
                     overn = 1;
                  },NpcTipDialog.SEER,0,null,null,false);
               },NpcTipDialog.HAMULEITE,0,null,null,false);
            }
         });
      }
      
      public static function playMovie(param1:String) : void
      {
         var _loc2_:MCLoader = new MCLoader(param1,LevelManager.appLevel,1,"正在打开动画");
         _loc2_.addEventListener(MCLoadEvent.SUCCESS,onLoadMovie);
         _loc2_.doLoad();
      }
      
      private static function onLoadMovie(param1:MCLoadEvent) : void
      {
         var content:MovieClip = null;
         var event:MCLoadEvent = param1;
         content = null;
         content = event.getContent() as MovieClip;
         MainManager.getStage().addChild(content);
         content.gotoAndPlay(2);
         content.addEventListener("EFFECT_END",function(param1:Event):void
         {
            content.removeEventListener("EFFECT_END",arguments.callee);
            DisplayUtil.removeForParent(content);
            content = null;
            dongHuaOver();
         });
      }
      
      private static function dongHuaOver() : void
      {
         if(overn == 1)
         {
            isMoFangB = true;
            MapManager.changeMap(60);
         }
         else if(overn == 2)
         {
            hamolt();
            btn1.visible = false;
            overn = 3;
         }
      }
      
      public static function showPanel0() : void
      {
         if(panel0 == null)
         {
            panel0 = new AppModel(ClientConfig.getTaskModule("TaskPanel0_79"),"正在打开任务信息");
            panel0.setup();
            panel0.show();
            panel0 = null;
            clickSt = 1;
         }
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_79"),"正在打开任务信息");
            panel.setup();
            panel.show();
         }
         else
         {
            panel.show();
         }
      }
   }
}

