package com.robot.app.task.control
{
   import com.robot.app.freshFightLevel.FightLevelModel;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   
   public class TaskController_89
   {
      
      private static var arrFun:Array;
      
      private static var lightMC:MovieClip;
      
      private static var panel:AppModel = null;
      
      private static var userName:String = MainManager.actorInfo.nick;
      
      public static var eableToGoing:String = "canNotGo";
      
      public function TaskController_89()
      {
         super();
      }
      
      public static function task89Hander(param1:MovieClip) : void
      {
         var light:MovieClip = param1;
         NpcDialog.show(NPC.LYMAN,["立正！" + userName + "，你来教官办公室找我有什么事情吗？"],["教官，我想询问一下关于试炼之塔的事情。","不好意思，我走错了……"],[function():void
         {
            NpcDialog.show(NPC.LYMAN,["试炼之塔？这可是我为赛尔新船员们量身打造！在这里新船员们可以体验到精灵对战的快感，从而磨练自己！哦对了！你想来试试身手吗？"],["我正有这个意思呢！","我想我还需要再考虑一下……"],[function():void
            {
               NpcDialog.show(NPC.LYMAN,["你看到我正前方的那个试炼之塔入口了吗，你可以点击那里进入到这个封闭式的精灵试练塔！"],["好！我去看看！"],[function():void
               {
                  light.visible = true;
                  lightMC = light;
                  TasksManager.accept(89,null);
                  showPanel();
               }]);
            }]);
         }]);
      }
      
      public static function oneStage(param1:MovieClip) : void
      {
         var light:MovieClip = param1;
         lightMC = light;
         if(TasksManager.getTaskStatus(89) == TasksManager.COMPLETE || TasksManager.getTaskStatus(89) == TasksManager.UN_ACCEPT)
         {
            LevelManager.closeMouseEvent();
            FightLevelModel.setUp();
         }
         if(TasksManager.getTaskStatus(89) != TasksManager.COMPLETE)
         {
            TasksManager.getProStatusList(89,function(param1:Array):void
            {
               var arr:Array = param1;
               if(TasksManager.getTaskStatus(89) == TasksManager.ALR_ACCEPT)
               {
                  if(!arr[0])
                  {
                     NpcDialog.show(NPC.LYMAN,["这就是新手试炼之塔的入口，试炼之塔一共分为30层，作为一个小小的磨练，我想你必须要通过10层考验吧！想接受这个挑战吗？"],["我一定能做到！","我看我还是考虑下吧……"],[function():void
                     {
                        eableToGoing = "canGoing";
                        TasksManager.complete(89,0,null,true);
                        lightMC.visible = false;
                     }]);
                  }
                  else if(Boolean(arr[0]) && !arr[1])
                  {
                     NpcDialog.show(NPC.LYMAN,["这就是新手试炼之塔的入口，试炼之塔一共分为30层，作为一个小小的磨练，我想你必须要通过10层考验吧！想接受这个挑战吗？"],["我一定能做到！","我看我还是考虑下吧……"],[function():void
                     {
                        lightMC.visible = false;
                        LevelManager.closeMouseEvent();
                        FightLevelModel.setUp();
                     }]);
                  }
                  else
                  {
                     LevelManager.closeMouseEvent();
                     FightLevelModel.setUp();
                  }
               }
            });
         }
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_89"),"正在打开任务信息");
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
         var _loc1_:uint = uint(TasksManager.getTaskStatus(89));
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
         lightMC = null;
         arrFun = null;
      }
   }
}

