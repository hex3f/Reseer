package com.robot.app.task.control
{
   import com.robot.app.mapProcess.MapProcess_107;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   
   public class TaskController_96
   {
      
      private static var panel:AppModel = null;
      
      public function TaskController_96()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_96"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
      }
      
      public static function acceptTask() : void
      {
         var hereNo:MapProcess_107 = null;
         hereNo = null;
         hereNo = new MapProcess_107();
         NpcDialog.show(NPC.SHAWN,["  π=3.1415926……嗨！我是赛尔号的发明家肖恩，这里就是我的发明室。什么？你问我找个小家伙是什么？它可是我的……"],["咦？这家伙还真可爱啊！是精灵吗？"],[function():void
         {
            NpcDialog.show(NPC.SHAWN,[" 它可不是精灵，而是高科技的结晶，按产品来说应该称它为“NoNo”。它能协助赛尔完成各种使命，是探索旅程中不可或缺的助手！#8"],["哇，那么我是不是也能有自己的伙伴NoNo呢？"],[function():void
            {
               NpcDialog.show(NPC.SHAWN,[" 当然啦！我已经将你的登船资料注册在NoNo的资料库中了，现在去左边0xff0000NoNo领取处0xffffff领取属于你的NoNo吧！"],["太好了，谢谢肖恩老师！"],[function():void
               {
                  TasksManager.accept(96,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        TasksManager.complete(96,0,null,true);
                        hereNo.hereNono.visible = true;
                     }
                  });
               }]);
            }]);
         }]);
      }
      
      public static function showIcon() : void
      {
      }
      
      public static function delIcon() : void
      {
      }
      
      public static function destroy() : void
      {
         if(Boolean(panel))
         {
            panel.destroy();
            panel = null;
         }
      }
   }
}

