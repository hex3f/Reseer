package com.robot.app.task.taskscollection
{
   import com.robot.app.ogre.OgreController;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class Task947
   {
      
      private static var _map:BaseMapProcess;
      
      private static const TASK_ID:uint = 947;
      
      public function Task947()
      {
         super();
      }
      
      public static function initForMap348(param1:BaseMapProcess) : void
      {
         var map:BaseMapProcess = param1;
         _map = map;
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TASK_ID,function(param1:Array):void
            {
               ToolBarController.showOrHideAllUser(false);
               OgreController.isShow = false;
               if(Boolean(param1[0]) && !param1[1])
               {
                  initStep1();
               }
               else
               {
                  destroy();
               }
            });
         }
         else
         {
            destroy();
         }
      }
      
      public static function initForMap712(param1:BaseMapProcess) : void
      {
         var map:BaseMapProcess = param1;
         _map = map;
         _map.animatorLevel["task947mc"].visible = false;
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TASK_ID,function(param1:Array):void
            {
               ToolBarController.showOrHideAllUser(false);
               OgreController.isShow = false;
               if(Boolean(param1[1]) && !param1[2])
               {
                  initStep2();
               }
               else if(Boolean(param1[2]) && !param1[3])
               {
                  initStep3();
               }
               else if(Boolean(param1[3]) && !param1[4])
               {
                  initStep4();
               }
               else
               {
                  destroy();
               }
            });
         }
         else
         {
            destroy();
         }
      }
      
      private static function initStep1() : void
      {
         _map.conLevel["hamo"].visible = false;
         _map.conLevel["taxiya"].visible = false;
         _map.conLevel["saiweier"].visible = false;
         _map.conLevel["takelin"].visible = false;
         taskMC.gotoAndStop(1);
         taskMC.buttonMode = true;
         taskMC.addEventListener(MouseEvent.CLICK,onStepHandler_1_0);
      }
      
      private static function onStepHandler_1_0(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
         taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_1_0);
         taskMC.buttonMode = false;
      }
      
      private static function initStep2() : void
      {
         taskMC.gotoAndStop(1);
         taskMC.buttonMode = true;
         taskMC.addEventListener(MouseEvent.CLICK,onStepHandler_2_0);
      }
      
      private static function onStepHandler_2_0(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
         taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_2_0);
         taskMC.buttonMode = false;
      }
      
      private static function onStepHandler_2_1(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
         taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_2_1);
         taskMC.buttonMode = false;
      }
      
      private static function initStep3() : void
      {
      }
      
      private static function onStepHandler_3_0(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_3_0);
         taskMC.buttonMode = false;
         AnimateManager.playMcAnimate(taskMC,9,"mc",function():void
         {
            NpcDialog.show(NPC.SEER,["太好了，果然有效，看你还往哪里逃！"],["继续转动水晶石！"],[function():void
            {
               taskMC.gotoAndStop(10);
               taskMC.buttonMode = true;
               taskMC.addEventListener(MouseEvent.CLICK,onStepHandler_3_1);
            }]);
         });
      }
      
      private static function onStepHandler_3_1(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
         taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_3_1);
         taskMC.buttonMode = false;
      }
      
      private static function initStep4() : void
      {
         taskMC.gotoAndStop(11);
      }
      
      private static function get taskMC() : MovieClip
      {
         if(MapManager.currentMap.id == 712)
         {
            return _map.conLevel["task947mc"];
         }
         if(MapManager.currentMap.id == 348)
         {
            return _map.conLevel["task947mc"];
         }
         return null;
      }
      
      public static function destroy() : void
      {
         if(!_map)
         {
            return;
         }
         OgreController.isShow = true;
         ToolBarController.showOrHideAllUser(true);
         if(Boolean(taskMC))
         {
            if(MapManager.currentMap.id == 348)
            {
               taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_1_0);
               _map.conLevel["hamo"].visible = true;
               _map.conLevel["taxiya"].visible = true;
               _map.conLevel["saiweier"].visible = true;
               _map.conLevel["takelin"].visible = true;
            }
            else if(MapManager.currentMap.id == 712)
            {
               _map.animatorLevel["task947mc"].visible = true;
               taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_2_0);
               taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_2_1);
               taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_3_0);
               taskMC.removeEventListener(MouseEvent.CLICK,onStepHandler_3_1);
            }
            DisplayUtil.removeForParent(taskMC);
         }
         _map = null;
      }
   }
}

