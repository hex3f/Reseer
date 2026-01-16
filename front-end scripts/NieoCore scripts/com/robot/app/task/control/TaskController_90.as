package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcController;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   
   public class TaskController_90
   {
      
      private static var _showInlTime:uint;
      
      private static var _isEnd:uint;
      
      private static var _pipi_mc:MovieClip;
      
      private static var delAdd:Function;
      
      private static var _pipi_pic:MovieClip;
      
      private static var _npc_mc:MovieClip;
      
      public static var panel1:AppModel;
      
      public static var panel:AppModel;
      
      public static const TASK_ID:uint = 90;
      
      public static var isSendRes:Boolean = false;
      
      public function TaskController_90()
      {
         super();
      }
      
      public static function catchPetEnd() : void
      {
         if(MapManager.currentMap.id != 10)
         {
            return;
         }
         TasksManager.getProStatusList(TASK_ID,function(param1:Array):void
         {
            if(Boolean(param1[0]) && !param1[1])
            {
               showTalk1();
            }
         });
      }
      
      public static function openPetBook(param1:uint = 0) : void
      {
         _isEnd = param1;
         LevelManager.closeMouseEvent();
         MainManager.getStage().addEventListener(MouseEvent.CLICK,clickdownHandler);
         _showInlTime = setInterval(delPanel,3000);
         _pipi_pic.x = 240;
      }
      
      private static function delPanel() : void
      {
         clearInterval(_showInlTime);
         MainManager.getStage().removeEventListener(MouseEvent.CLICK,clickdownHandler);
         _pipi_pic.x = 2000;
         if(_isEnd == 0)
         {
            showTalk();
         }
         else
         {
            showTalk1();
         }
      }
      
      private static function clickdownHandler(param1:MouseEvent) : void
      {
         clearInterval(_showInlTime);
         MainManager.getStage().removeEventListener(MouseEvent.CLICK,clickdownHandler);
         _pipi_pic.x = 2000;
         if(_isEnd == 0)
         {
            showTalk();
         }
         else
         {
            showTalk1();
         }
      }
      
      public static function showTalk1() : void
      {
         if(TasksManager.getTaskStatus(90) != TasksManager.ALR_ACCEPT)
         {
            return;
         }
         NpcDialog.show(NPC.SEER,["呦！我终于捉到皮皮咯！我会好好训练你的，一定要快快成长哦！"],["和皮皮成为好朋友！"],[function():void
         {
            TasksManager.complete(TASK_ID,1,function(param1:Boolean):void
            {
               if(param1)
               {
                  delAdd();
               }
            });
         }]);
      }
      
      public static function initFun(param1:Function, param2:MovieClip, param3:MovieClip) : void
      {
         _pipi_mc = param2;
         delAdd = param1;
         _pipi_pic = param3;
      }
      
      private static function showTalk() : void
      {
         LevelManager.openMouseEvent();
         NpcDialog.show(NPC.SEER,["哇！#1　皮皮看起来真是即温顺又可爱，我一定也要拥有一只！"],["用精灵胶囊捕捉皮皮！","还是下次再说吧"],[function():void
         {
            TasksManager.accept(TASK_ID,function(param1:Boolean):void
            {
               if(param1)
               {
                  showPanel();
                  isSendRes = true;
               }
            });
         }]);
      }
      
      private static function turnNpc() : void
      {
         _npc_mc.gotoAndPlay(2);
         _npc_mc.addFrameScript(_npc_mc.totalFrames - 1,endTurnNpc);
      }
      
      private static function endTurnNpc() : void
      {
         _npc_mc.addFrameScript(_npc_mc.totalFrames - 1,null);
         _npc_mc.gotoAndStop(1);
         openPetBook();
      }
      
      public static function clickPIPI() : void
      {
         _npc_mc = NpcController.curNpc.npc.npc as MovieClip;
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.UN_ACCEPT)
         {
            NpcDialog.show(NPC.PIPI,["#1 哦哒哒哒哒～～"],["逗皮皮玩"],[function():void
            {
               NpcDialog.show(NPC.PIPI,["飞啊～飞啊～ #1"],["皮皮似乎很高兴的样子"],[function():void
               {
                  if(Boolean(NpcController.curNpc))
                  {
                     turnNpc();
                  }
               }]);
            }]);
            return;
         }
         TasksManager.getProStatusList(TASK_ID,function(param1:Array):void
         {
            if(!param1[0])
            {
               _pipi_mc.visible = true;
               _pipi_mc.gotoAndPlay(2);
               _pipi_mc.addFrameScript(_pipi_mc.totalFrames - 1,endPIPI);
            }
         });
      }
      
      private static function endPIPI() : void
      {
         _pipi_mc.addFrameScript(_pipi_mc.totalFrames - 1,null);
         _pipi_mc.gotoAndStop(1);
         _pipi_mc.visible = false;
         showTalk0();
      }
      
      public static function endLX() : void
      {
         NpcDialog.show(NPC.SEER,["#7嗯．．．．．．差不多听懂了吧。那我就用茜茜给我的精灵找一只野生皮皮对战看看。"],["那我就来试试吧！"],[function():void
         {
            TasksManager.complete(TASK_ID,0,function(param1:Boolean):void
            {
               if(param1)
               {
                  showPanel();
               }
            });
         }]);
      }
      
      private static function showTalk0() : void
      {
         NpcDialog.show(NPC.PIPI,["飞啊～飞啊～ #1,（丢过去的精灵胶囊，并没有抓住皮皮）皮皮跑开了。"],["它还真是个乐天派"],[function():void
         {
            _npc_mc.visible = false;
            NpcDialog.show(NPC.SEER,["#2怎么抓不住它呢，看来我的方法可能不正确。还是问下博士吧，我得再复习下捕捉精灵的方法。"],["与博士取得联系"],[function():void
            {
               showPanel1();
            }]);
         }]);
      }
      
      public static function showPanel1() : void
      {
         if(Boolean(panel1))
         {
            panel1.destroy();
            panel1 = null;
         }
         if(panel1 == null)
         {
            panel1 = new AppModel(ClientConfig.getTaskModule("TaskPanel0_90"),"正在打开任务信息");
            panel1.setup();
            panel1.show();
         }
         else
         {
            panel1.show();
         }
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_90"),"正在打开任务信息");
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

