package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   
   public class TaskController_93
   {
      
      private static var panel:AppModel = null;
      
      public function TaskController_93()
      {
         super();
      }
      
      public static function taskSpeak() : void
      {
         NpcDialog.show(NPC.MAOMAO,["#3SOS！SOS！云霄星似乎来了个不速之客！我听我哥们幽浮说，提亚斯和它们正在准备开战呢！怎么办？怎么办？十万火急！"],["别急！我这就去看看！","你先让我好好想想，我一会再来找你吧！"],[function():void
         {
            NpcDialog.show(NPC.MAOMAO,["哎呀！差点忘记问你了！你有0xff0000飞行装0xffffff吗？或者你有0xff0000超能NoNo0xffffff？#7要知道云霄星可是很特别的，没有飞行装和超能NoNo的帮助你可没办法上去！"],["万事俱备！我这就出发！","我不知道去哪里准备……"],[function():void
            {
               if(panel == null)
               {
                  panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_93"),"正在打开任务信息");
                  panel.setup();
               }
               panel.show();
               TasksManager.accept(93,null);
            },function():void
            {
               NpcDialog.show(NPC.MAOMAO,["0xff0000超能NoNo0xffffff可是赛尔号里最最了不起的发明哦！它可以帮助你上天入地，毫无阻碍！至于0xff0000飞行装0xffffff，我听说你们赛尔号0xff0000机械室就有购买！"],["我这就去发明室开通超能NoNo！","我马上去机械室购买飞行装！","我都知道了，谢谢你……"],[function():void
               {
                  MapManager.changeMap(107);
               },function():void
               {
                  MapManager.changeMap(8);
               }]);
            }]);
         }]);
      }
      
      public static function highTask() : void
      {
         NpcDialog.show(NPC.TIYASI,["离我的蛋远一点！#5再不离开！我就开始进攻了！魔能风暴……"],["不好！那个精灵有危险！"],[function():void
         {
            NpcDialog.show(NPC.SEER,["不行！那个精灵如果再受到提亚斯的攻击，它肯定会受伤的！我绝不允许精灵在我面前受伤！绝不！"],["不管了！我这就挡在那个精灵前面！"],[function():void
            {
               TasksManager.complete(93,0,null,true);
            }]);
         }]);
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_93"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
         showPanel();
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

