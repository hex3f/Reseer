package com.robot.app.task.control
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.SoundManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.newloader.MCLoader;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class TaskController_62
   {
      
      private static var icon:InteractiveObject;
      
      private static var lightMC:MovieClip;
      
      public static const TASK_ID:uint = 62;
      
      private static var panel:AppModel = null;
      
      public function TaskController_62()
      {
         super();
      }
      
      public static function setup() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            showIcon();
         }
      }
      
      public static function start() : void
      {
         accept();
      }
      
      private static function accept() : void
      {
         TasksManager.accept(TASK_ID);
         showIcon();
         var _loc1_:String = "resource/bounsMovie/joinin.swf";
         var _loc2_:MCLoader = new MCLoader(_loc1_,LevelManager.topLevel,1,"精灵进场准备...");
         _loc2_.addEventListener(MCLoadEvent.SUCCESS,onLoaded);
         _loc2_.doLoad();
      }
      
      private static function onLoaded(param1:MCLoadEvent) : void
      {
         var content:MovieClip = null;
         var event:MCLoadEvent = param1;
         content = null;
         SoundManager.stopSound();
         (event.currentTarget as MCLoader).removeEventListener(MCLoadEvent.SUCCESS,onLoaded);
         content = event.getContent() as MovieClip;
         MainManager.getStage().addChild(content);
         content.addEventListener("EFFECT_END",function(param1:Event):void
         {
            var event:Event = param1;
            SoundManager.playSound();
            DisplayUtil.removeForParent(content);
            TasksManager.complete(TaskController_62.TASK_ID,0,function(param1:Boolean):void
            {
               nextStep();
            });
         });
      }
      
      public static function nextStep() : void
      {
         NpcTipDialog.show("好壮观的场面啊！\n    差点给忘了！" + MainManager.actorInfo.nick + "，你还不知道冰系精灵争霸赛的比赛规则吧？要我给你介绍下吗？",function():void
         {
            loadRuleInfoSwf();
         },NpcTipDialog.IRIS);
      }
      
      private static function loadRuleInfoSwf() : void
      {
         var _loc1_:MCLoader = new MCLoader("resource/book/gamerule.swf",LevelManager.topLevel,1,"正在打开");
         _loc1_.addEventListener(MCLoadEvent.SUCCESS,onLoad);
         _loc1_.doLoad();
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         var content:MovieClip = null;
         var event:MCLoadEvent = param1;
         content = null;
         content = event.getContent() as MovieClip;
         LevelManager.appLevel.addChild(content);
         DisplayUtil.align(content,null,AlignType.MIDDLE_CENTER);
         content["close_btn"].addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            DisplayUtil.removeForParent(content);
         });
      }
      
      public static function showIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("AwardIcon");
            icon.addEventListener(MouseEvent.CLICK,clickHandler);
            ToolTipManager.add(icon,"冰系精灵王争霸赛开幕式");
         }
         TaskIconManager.addIcon(icon);
      }
      
      public static function delIcon() : void
      {
         ToolTipManager.remove(icon);
         TaskIconManager.delIcon(icon);
         icon.removeEventListener(MouseEvent.CLICK,clickHandler);
         icon = null;
         if(Boolean(panel))
         {
            panel.destroy();
            panel = null;
         }
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("Task62Panel"),"正在打开斯诺冰牌信息");
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

