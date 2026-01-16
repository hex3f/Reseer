package com.robot.app.task.taskscollection
{
   import com.robot.app.fightNote.*;
   import com.robot.app.task.control.TaskController_748;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.events.MouseEvent;
   
   public class Task748
   {
      
      private static var _map:BaseMapProcess;
      
      private static var taskStep:int = -100;
      
      public function Task748()
      {
         super();
      }
      
      public static function initTaskForMap326(param1:BaseMapProcess, param2:Boolean = false) : void
      {
         var nRet:uint = 0;
         var map:BaseMapProcess = param1;
         var lock:Boolean = param2;
         map.conLevel["npcMC"].gotoAndStop(2);
         map.conLevel["weisikeMC"].visible = false;
         map.conLevel["haidaoMC"].visible = false;
         if(lock)
         {
            return;
         }
         _map = map;
         nRet = uint(TasksManager.getTaskStatus(TaskController_748.TASK_ID));
         if(nRet == TasksManager.UN_ACCEPT)
         {
            _map.conLevel["npcMC"].gotoAndStop(1);
         }
         else if(nRet == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_748.TASK_ID,function(param1:Array):void
            {
               if(Boolean(param1[0]) && !param1[1])
               {
                  taskStep = 1;
                  _map.conLevel["npcMC"].gotoAndStop(1);
               }
               else if(Boolean(param1[0]) && Boolean(param1[1]) && Boolean(param1[2]) && !param1[3])
               {
                  taskStep = 3;
                  ToolBarController.showOrHideAllUser(false);
                  _map.conLevel["npcMC"].gotoAndStop(8);
                  _map.conLevel["haidaoMC"].visible = true;
               }
               else if(Boolean(param1[0]) && Boolean(param1[1]) && Boolean(param1[2]) && Boolean(param1[3]) && !param1[4])
               {
                  taskStep = 4;
                  _map.conLevel["npcMC"].gotoAndStop(4);
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
      
      private static function initFight() : void
      {
      }
      
      public static function initTaskForMap419(param1:BaseMapProcess) : void
      {
         var map:BaseMapProcess = param1;
         _map = map;
         var nRet:uint = uint(TasksManager.getTaskStatus(TaskController_748.TASK_ID));
         if(nRet == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_748.TASK_ID,function(param1:Array):void
            {
               if(!param1[0])
               {
                  taskStep = 0;
               }
            });
         }
      }
      
      public static function taskHandler() : void
      {
      }
      
      public static function initTaskForMap62(param1:BaseMapProcess) : void
      {
         var nRet:uint = 0;
         var map:BaseMapProcess = param1;
         _map = map;
         _map.conLevel["task748MC"].visible = false;
         nRet = uint(TasksManager.getTaskStatus(TaskController_748.TASK_ID));
         if(nRet == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_748.TASK_ID,function(param1:Array):void
            {
               if(Boolean(param1[0]) && Boolean(param1[1]) && !param1[2])
               {
                  taskStep = 1;
                  _map.conLevel["task748MC"].gotoAndStop(2);
                  _map.conLevel["task748MC"].visible = true;
                  _map.conLevel["task748MC"].buttonMode = true;
                  _map.conLevel["task748MC"].addEventListener(MouseEvent.CLICK,task748ClickHandler);
               }
            });
         }
      }
      
      private static function task748ClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
      }
      
      private static function onFightComplete(param1:PetFightEvent) : void
      {
         var _loc2_:PetFightEvent = param1;
         _map.conLevel["task748MC"].buttonMode = false;
         _map.conLevel["task748MC"].removeEventListener(MouseEvent.CLICK,task748ClickHandler);
      }
      
      public static function destroy() : void
      {
         if(!_map)
         {
            return;
         }
         if(MapManager.currentMap.id == 326)
         {
            _map.conLevel["npcMC"].removeEventListener(MouseEvent.CLICK,ruiersiClickHandler);
            ToolBarController.showOrHideAllUser(true);
         }
         else if(MapManager.currentMap.id != 419)
         {
            if(MapManager.currentMap.id == 62)
            {
               _map.conLevel["task748MC"].removeEventListener(MouseEvent.CLICK,task748ClickHandler);
            }
         }
         _map = null;
      }
   }
}

