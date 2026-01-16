package com.robot.app.task.taskscollection
{
   import com.robot.app.task.control.TaskController_775;
   import com.robot.core.aimat.AimatController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class Task775
   {
      
      private static var _map:BaseMapProcess;
      
      private static var taskStep:int = -100;
      
      public function Task775()
      {
         super();
      }
      
      public static function initTaskForMap419(param1:BaseMapProcess, param2:Boolean = false) : void
      {
         var map:BaseMapProcess = param1;
         var lock:Boolean = param2;
         _map = map;
         var nRet:uint = uint(TasksManager.getTaskStatus(TaskController_775.TASK_ID));
         if(nRet == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_775.TASK_ID,function(param1:Array):void
            {
               if(!param1[0])
               {
                  taskStep = 0;
                  gotoStep1();
               }
            });
         }
      }
      
      public static function acceptTask() : void
      {
         TasksManager.accept(TaskController_775.TASK_ID,function(param1:Boolean):void
         {
            var _loc2_:Boolean = param1;
            if(_loc2_)
            {
            }
         });
      }
      
      private static function gotoStep1() : void
      {
         AnimateManager.playMcAnimate(_map.conLevel["blackMC1"],1,"mc1",function():void
         {
            AnimateManager.playMcAnimate(_map.conLevel["blackMC2"],1,"mc1",function():void
            {
               AnimateManager.playMcAnimate(_map.conLevel["blackMC3"],1,"mc1",function():void
               {
                  NpcDialog.show(NPC.SEER,["我好像也看见一些黑乎乎的东东，它们躲在了角落里。"],["（点击场景里的黑影）"],[function():void
                  {
                     _map.conLevel["blackMC1"].buttonMode = true;
                     _map.conLevel["blackMC2"].buttonMode = true;
                     _map.conLevel["blackMC3"].buttonMode = true;
                     _map.conLevel["blackMC1"].addEventListener(MouseEvent.CLICK,blackClickHandler);
                     _map.conLevel["blackMC2"].addEventListener(MouseEvent.CLICK,blackClickHandler);
                     _map.conLevel["blackMC3"].addEventListener(MouseEvent.CLICK,blackClickHandler);
                  }]);
               });
            });
         });
      }
      
      private static function blackClickHandler(param1:MouseEvent) : void
      {
         var mc:MovieClip = null;
         mc = null;
         var evt:MouseEvent = param1;
         if(MapManager.currentMap.id == 419)
         {
            mc = evt.currentTarget as MovieClip;
            AnimateManager.playMcAnimate(mc,2,"mc2",function():void
            {
               mc.visible = false;
               if(!_map.conLevel["blackMC1"].visible && !_map.conLevel["blackMC2"].visible && !_map.conLevel["blackMC3"].visible)
               {
                  NpcDialog.show(NPC.SEER,["呀，它们往觅食林方向逃走了，哼！我一定要知道那些到底是什么。"],["（前往觅食林）"],[function():void
                  {
                     TasksManager.complete(TaskController_775.TASK_ID,0,function():void
                     {
                        taskStep = 1;
                        MapManager.changeMap(414);
                     });
                  }]);
               }
            });
         }
         else if(MapManager.currentMap.id == 414)
         {
            NpcDialog.show(NPC.SEER,["嘿嘿！这次可别想逃了，看我不一炮把你们给轰下来。"],["（用头部射击攻击黑影）"]);
         }
      }
      
      public static function initTaskForMap414(param1:BaseMapProcess, param2:Boolean = false) : void
      {
         var map:BaseMapProcess = param1;
         var lock:Boolean = param2;
         _map = map;
         var nRet:uint = uint(TasksManager.getTaskStatus(TaskController_775.TASK_ID));
         if(nRet == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_775.TASK_ID,function(param1:Array):void
            {
               if(Boolean(param1[0]) && !param1[1])
               {
                  taskStep = 1;
                  gotoStep2();
               }
            });
         }
      }
      
      private static function gotoStep2() : void
      {
         _map.conLevel["blackMC1"].visible = true;
         _map.conLevel["blackMC2"].visible = true;
         _map.conLevel["blackMC3"].visible = true;
         AnimateManager.playMcAnimate(_map.conLevel["blackMC1"],1,"mc1",function():void
         {
            AnimateManager.playMcAnimate(_map.conLevel["blackMC2"],1,"mc1",function():void
            {
               AnimateManager.playMcAnimate(_map.conLevel["blackMC3"],1,"mc1",function():void
               {
                  NpcDialog.show(NPC.SEER,["嘿嘿！这次可别想逃，看我不一炮把你们给轰下来。"],["（用头部射击攻击黑影）"],[function():void
                  {
                     _map.conLevel["blackMC1"].buttonMode = true;
                     _map.conLevel["blackMC2"].buttonMode = true;
                     _map.conLevel["blackMC3"].buttonMode = true;
                     _map.conLevel["blackMC1"].addEventListener(MouseEvent.CLICK,blackClickHandler);
                     _map.conLevel["blackMC2"].addEventListener(MouseEvent.CLICK,blackClickHandler);
                     _map.conLevel["blackMC3"].addEventListener(MouseEvent.CLICK,blackClickHandler);
                     AimatController.addEventListener(AimatEvent.PLAY_END,onAimatEnd);
                  }]);
               });
            });
         });
      }
      
      private static function onAimatEnd(param1:AimatEvent) : void
      {
         var mc:MovieClip = null;
         mc = null;
         var evt:AimatEvent = param1;
         if(Boolean(_map.conLevel["blackMC1"].hitTestPoint(evt.info.endPos.x,evt.info.endPos.y)))
         {
            mc = _map.conLevel["blackMC1"];
         }
         else if(Boolean(_map.conLevel["blackMC2"].hitTestPoint(evt.info.endPos.x,evt.info.endPos.y)))
         {
            mc = _map.conLevel["blackMC2"];
         }
         else if(Boolean(_map.conLevel["blackMC3"].hitTestPoint(evt.info.endPos.x,evt.info.endPos.y)))
         {
            mc = _map.conLevel["blackMC3"];
         }
         if(Boolean(mc) && mc.visible)
         {
            AnimateManager.playMcAnimate(mc,2,"mc2",function():void
            {
               mc.visible = false;
               if(!_map.conLevel["blackMC1"].visible && !_map.conLevel["blackMC2"].visible && !_map.conLevel["blackMC3"].visible)
               {
                  AimatController.removeEventListener(AimatEvent.PLAY_END,onAimatEnd);
               }
            });
         }
      }
      
      public static function initTaskForMap325(param1:BaseMapProcess, param2:Boolean = false) : void
      {
         var map:BaseMapProcess = param1;
         var lock:Boolean = param2;
         _map = map;
         var nRet:uint = uint(TasksManager.getTaskStatus(TaskController_775.TASK_ID));
         if(nRet == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_775.TASK_ID,function(param1:Array):void
            {
               if(Boolean(param1[0]) && Boolean(param1[1]) && !param1[2])
               {
                  taskStep = 2;
                  _map.conLevel["npcMC"].gotoAndStop(1);
               }
            });
         }
         _map.conLevel["npcMC"].buttonMode = true;
         _map.conLevel["npcMC"].addEventListener(MouseEvent.CLICK,npcClickHandler1);
      }
      
      private static function npcClickHandler1(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
      }
      
      public static function initTaskForMap326(param1:BaseMapProcess, param2:Boolean = false) : void
      {
         var nRet:uint = 0;
         var map:BaseMapProcess = param1;
         var lock:Boolean = param2;
         _map = map;
         _map.conLevel["npcMC"].gotoAndStop(2);
         nRet = uint(TasksManager.getTaskStatus(TaskController_775.TASK_ID));
         if(nRet == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_775.TASK_ID,function(param1:Array):void
            {
               if(Boolean(param1[0]) && Boolean(param1[1]) && Boolean(param1[2]) && !param1[3])
               {
                  taskStep = 3;
                  _map.conLevel["npcMC"].gotoAndStop(1);
               }
            });
         }
         _map.conLevel["npcMC"].buttonMode = true;
         _map.conLevel["npcMC"].addEventListener(MouseEvent.CLICK,ruiersiClickHandler);
      }
      
      private static function ruiersiClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
      }
      
      private static function onFightComplete(param1:PetFightEvent) : void
      {
         var _loc2_:PetFightEvent = param1;
      }
      
      public static function destroy() : void
      {
         if(!_map)
         {
            return;
         }
         if(MapManager.currentMap.id == 419)
         {
            _map.conLevel["blackMC1"].removeEventListener(MouseEvent.CLICK,blackClickHandler);
            _map.conLevel["blackMC2"].removeEventListener(MouseEvent.CLICK,blackClickHandler);
            _map.conLevel["blackMC3"].removeEventListener(MouseEvent.CLICK,blackClickHandler);
         }
         else if(MapManager.currentMap.id == 414)
         {
            AimatController.removeEventListener(AimatEvent.PLAY_END,onAimatEnd);
            _map.conLevel["blackMC1"].removeEventListener(MouseEvent.CLICK,blackClickHandler);
            _map.conLevel["blackMC2"].removeEventListener(MouseEvent.CLICK,blackClickHandler);
            _map.conLevel["blackMC3"].removeEventListener(MouseEvent.CLICK,blackClickHandler);
         }
         else if(MapManager.currentMap.id == 325)
         {
            _map.conLevel["npcMC"].removeEventListener(MouseEvent.CLICK,npcClickHandler1);
         }
         else if(MapManager.currentMap.id == 326)
         {
            _map.conLevel["npcMC"].removeEventListener(MouseEvent.CLICK,ruiersiClickHandler);
         }
         _map = null;
      }
   }
}

