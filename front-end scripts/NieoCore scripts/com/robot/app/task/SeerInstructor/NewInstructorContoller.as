package com.robot.app.task.SeerInstructor
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class NewInstructorContoller
   {
      
      private static var icon:InteractiveObject;
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 201;
      
      public function NewInstructorContoller()
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
      
      public static function showIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("inIcon");
            ToolTipManager.add(icon,"教官的考核");
            icon.addEventListener(MouseEvent.CLICK,clickIcon);
         }
         TaskIconManager.addIcon(icon);
      }
      
      public static function delIcon() : void
      {
         icon.removeEventListener(MouseEvent.CLICK,clickIcon);
         TaskIconManager.delIcon(icon);
         ToolTipManager.remove(icon);
         if(Boolean(panel))
         {
            panel.destroy();
         }
         panel = null;
      }
      
      private static function clickIcon(param1:MouseEvent) : void
      {
         if(!panel)
         {
            panel = ModuleManager.getModule(ClientConfig.getTaskModule("Instructor"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function fight() : void
      {
         var guard:String = null;
         guard = null;
         guard = NpcTipDialog.GUARD;
         TasksManager.getProStatus(TASK_ID,5,function(param1:Boolean):void
         {
            if(param1)
            {
               NpcTipDialog.show("你完成了教官考核中的其他步骤吗，如果完成了赶紧去找教官雷蒙拿奖励吧！",null,guard,-40);
            }
            else
            {
               NpcTipDialog.show("参加教官考核的伙伴，准备好接受我的考验了吗？",onAccept,guard,-40);
            }
         });
      }
      
      private static function onAccept() : void
      {
         FightInviteManager.fightWithBoss("NPC");
         EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
      }
      
      private static function onCloseFight(param1:PetFightEvent) : void
      {
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
         var _loc2_:FightOverInfo = param1.dataObj["data"];
         if(_loc2_.winnerID == MainManager.actorInfo.userID)
         {
            TasksManager.complete(TASK_ID,5);
         }
      }
      
      public static function chekWaste() : void
      {
         var pro:uint = 0;
         if(MainManager.actorInfo.mapID == 11)
         {
            pro = 0;
         }
         else if(MainManager.actorInfo.mapID == 17)
         {
            pro = 1;
         }
         else if(MainManager.actorInfo.mapID == 21)
         {
            pro = 2;
         }
         else if(MainManager.actorInfo.mapID == 25)
         {
            pro = 3;
         }
         else if(MainManager.actorInfo.mapID == 32)
         {
            pro = 4;
         }
         MapManager.currentMap.controlLevel["wasteMC"].visible = false;
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatus(TASK_ID,pro,function(param1:Boolean):void
            {
               MapManager.currentMap.controlLevel["wasteMC"].visible = !param1;
            });
         }
      }
      
      public static function setWaste() : void
      {
         var pro:uint = 0;
         pro = 0;
         if(MainManager.actorInfo.mapID == 11)
         {
            pro = 0;
         }
         else if(MainManager.actorInfo.mapID == 17)
         {
            pro = 1;
         }
         else if(MainManager.actorInfo.mapID == 21)
         {
            pro = 2;
         }
         else if(MainManager.actorInfo.mapID == 25)
         {
            pro = 3;
         }
         else if(MainManager.actorInfo.mapID == 32)
         {
            pro = 4;
         }
         TasksManager.complete(TASK_ID,pro,function(param1:Boolean):void
         {
            if(param1)
            {
               DisplayUtil.removeForParent(MapManager.currentMap.controlLevel["wasteMC"]);
               switch(pro)
               {
                  case 0:
                     Alarm.show("你找到了电池");
                     break;
                  case 1:
                     Alarm.show("你找到了机油");
                     break;
                  case 2:
                     Alarm.show("你找到了有毒物质");
                     break;
                  case 3:
                     Alarm.show("你找到了核废料");
                     break;
                  case 4:
                     Alarm.show("你找到了废弃电脑");
               }
            }
         });
      }
   }
}

