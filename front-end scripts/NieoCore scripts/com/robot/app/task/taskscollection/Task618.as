package com.robot.app.task.taskscollection
{
   import com.robot.app.task.control.TaskController_618;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class Task618
   {
      
      private static var _map:BaseMapProcess;
      
      public function Task618()
      {
         super();
      }
      
      public static function initTask() : void
      {
         MapManager.changeMap(414);
      }
      
      public static function initTask_414(param1:BaseMapProcess) : void
      {
         var map:BaseMapProcess = null;
         map = param1;
         _map = map;
         if(TasksManager.getTaskStatus(TaskController_618.TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_618.TASK_ID,function(param1:Array):void
            {
               if(!param1[0])
               {
                  startPro_0();
               }
               else
               {
                  removeResouce_414(map);
               }
            });
         }
         else
         {
            removeResouce_414(map);
         }
      }
      
      public static function removeResouce_414(param1:BaseMapProcess) : void
      {
         DisplayUtil.removeForParent(param1.conLevel["arrow"]);
         param1.conLevel["arrow"] = null;
         DisplayUtil.removeForParent(param1.conLevel["task_618_1"]);
         param1.conLevel["task_618_1"] = null;
         DisplayUtil.removeForParent(param1.conLevel["task_618_2"]);
         param1.conLevel["task_618_2"] = null;
      }
      
      private static function startPro_0() : void
      {
         ToolBarController.showOrHideAllUser(false);
         _map.conLevel["arrow"].visible = false;
      }
      
      public static function onGaiyaClcik(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         _map.conLevel["arrow"].visible = false;
         _map.conLevel["task_618_1"].buttonMode = false;
         _map.conLevel["task_618_1"].removeEventListener(MouseEvent.CLICK,onGaiyaClcik);
         AnimateManager.playMcAnimate(_map.conLevel["task_618_1"],2,"mc_2",function():void
         {
            if(Boolean(MainManager.actorModel.pet))
            {
               MainManager.actorModel.showPet(MainManager.actorModel.pet.info);
            }
            if(Boolean(MainManager.actorModel.nono))
            {
               MainManager.actorModel.showNono(MainManager.actorModel.nono.info,MainManager.actorInfo.actionType);
            }
            MainManager.actorModel.visible = true;
            TasksManager.complete(TaskController_618.TASK_ID,0,function(param1:Boolean):void
            {
               if(param1)
               {
                  MapManager.changeMap(423);
               }
            });
         });
      }
      
      public static function initTask_423(param1:BaseMapProcess) : void
      {
         var map:BaseMapProcess = null;
         map = param1;
         _map = map;
         if(TasksManager.getTaskStatus(TaskController_618.TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_618.TASK_ID,function(param1:Array):void
            {
               if(Boolean(param1[0]) && !param1[1])
               {
                  startPro_1();
               }
               else
               {
                  removeResouce_423(map);
               }
            });
         }
         else
         {
            removeResouce_423(map);
         }
      }
      
      public static function removeResouce_423(param1:BaseMapProcess) : void
      {
         DisplayUtil.removeForParent(_map.conLevel["arrow"]);
         _map.conLevel["arrow"] = null;
         DisplayUtil.removeForParent(_map.conLevel["tielian"]);
         _map.conLevel["tielian"] = null;
         DisplayUtil.removeForParent(_map.animatorLevel["task_618_1"]);
         _map.animatorLevel["task_618_1"] = null;
         DisplayUtil.removeForParent(_map.animatorLevel["task_618_2"]);
         _map.animatorLevel["task_618_2"] = null;
         DisplayUtil.removeForParent(_map.animatorLevel["task_618_3"]);
         _map.animatorLevel["task_618_3"] = null;
         DisplayUtil.removeForParent(_map.animatorLevel["task_618_4"]);
         _map.animatorLevel["task_618_4"] = null;
         DisplayUtil.removeForParent(_map.animatorLevel["task_618_5"]);
         _map.animatorLevel["task_618_5"] = null;
         DisplayUtil.removeForParent(_map.animatorLevel["task_618_6"]);
         _map.animatorLevel["task_618_6"] = null;
      }
      
      private static function startPro_1() : void
      {
         ToolBarController.showOrHideAllUser(false);
         MainManager.actorModel.hidePet();
         MainManager.actorModel.hideNono();
         MainManager.actorModel.visible = false;
         _map.conLevel["arrow"].visible = false;
         _map.animatorLevel["task_618_2"].visible = false;
         _map.animatorLevel["task_618_3"].visible = false;
         _map.animatorLevel["task_618_4"].visible = false;
         _map.animatorLevel["task_618_5"].visible = false;
         _map.animatorLevel["task_618_6"].visible = false;
      }
      
      public static function onTielianClcik(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
         _map.conLevel["arrow"].visible = false;
         _map.conLevel["tielian"].buttonMode = false;
         _map.conLevel["tielian"].removeEventListener(MouseEvent.CLICK,onTielianClcik);
         _map.animatorLevel["task_618_2"].visible = false;
         _map.animatorLevel["task_618_3"].visible = true;
      }
      
      public static function destroy() : void
      {
         ToolBarController.showOrHideAllUser(true);
         if(Boolean(MainManager.actorModel.pet))
         {
            MainManager.actorModel.showPet(MainManager.actorModel.pet.info);
         }
         if(Boolean(MainManager.actorModel.nono))
         {
            MainManager.actorModel.showNono(MainManager.actorModel.nono.info,MainManager.actorInfo.actionType);
         }
         MainManager.actorModel.visible = true;
         if(Boolean(_map))
         {
            if(Boolean(_map.conLevel["task_618_1"]))
            {
               _map.conLevel["task_618_1"].removeEventListener(MouseEvent.CLICK,onGaiyaClcik);
            }
            if(Boolean(_map.conLevel["tielian"]))
            {
               _map.conLevel["tielian"].removeEventListener(MouseEvent.CLICK,onTielianClcik);
            }
         }
      }
   }
}

