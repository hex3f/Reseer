package com.robot.app.task.control
{
   import com.robot.app.buyItem.ItemAction;
   import com.robot.app.messagetool.MessageTool;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.NonoEvent;
   import com.robot.core.info.NonoImplementsToolResquestInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class TaskController_38
   {
      
      private static var icon:InteractiveObject;
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 38;
      
      public function TaskController_38()
      {
         super();
      }
      
      public static function start(param1:Boolean = false) : void
      {
         var b:Boolean = param1;
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatus(TASK_ID,0,function(param1:Boolean):void
            {
               var bl:Boolean = param1;
               if(!bl)
               {
                  NonoManager.addEventListener(NonoEvent.GET_INFO,function(param1:NonoEvent):void
                  {
                     var e:NonoEvent = param1;
                     NonoManager.removeEventListener(NonoEvent.GET_INFO,arguments.callee);
                     if(!NonoManager.info.func[8])
                     {
                        SocketConnection.addCmdListener(CommandID.NONO_IMPLEMENT_TOOL,onChange);
                     }
                     else
                     {
                        TasksManager.setProStatus(TaskController_38.TASK_ID,0,true,function():void
                        {
                        });
                     }
                  });
                  NonoManager.getInfo();
               }
            });
            if(!b)
            {
               NpcTipDialog.show("恩，非常好。有勇气和决断力的赛尔才是我们赛尔号的核心船员！接下来你先要进行一些赶赴现场的准备，以最佳的状态进入那个危险地带，注意安全！我会给你相应的指导。",function():void
               {
                  showIcon();
                  showTaskPanel(null);
               },NpcTipDialog.IRIS);
            }
            else
            {
               showIcon();
               MessageTool.start();
            }
         }
      }
      
      private static function onChange(param1:SocketEvent) : void
      {
         var e:SocketEvent = param1;
         var data:NonoImplementsToolResquestInfo = e.data as NonoImplementsToolResquestInfo;
         if(data.itemId == 700009)
         {
            SocketConnection.removeCmdListener(CommandID.NONO_IMPLEMENT_TOOL,onChange);
            TasksManager.setProStatus(TaskController_38.TASK_ID,0,true,function():void
            {
               showTaskPanel(null);
            });
         }
      }
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("ghost_ship_icon");
            icon.addEventListener(MouseEvent.CLICK,showTaskPanel);
            ToolTipManager.add(icon,"神秘幽灵船");
         }
         TaskIconManager.addIcon(icon);
      }
      
      public static function delIcon() : void
      {
         ToolTipManager.remove(icon);
         TaskIconManager.delIcon(icon);
         icon.removeEventListener(MouseEvent.CLICK,showTaskPanel);
         icon = null;
         if(Boolean(panel))
         {
            panel.destroy();
            panel = null;
         }
      }
      
      public static function showTaskPanel(param1:MouseEvent) : void
      {
         if(!panel)
         {
            panel = new AppModel(ClientConfig.getTaskModule("GhostShipTask"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function getItem(param1:uint, param2:uint) : void
      {
         var itemid:uint = param1;
         var taskid:uint = param2;
         var name:String = null;
         if(itemid == 0)
         {
            NpcTipDialog.show("在危险的环境中，随时和我保持联络，我会及时给你准确的指导。\n    通讯器的功率非常强大，放心使用吧。",function():void
            {
               TasksManager.setProStatus(TASK_ID,taskid,true);
               MessageTool.start();
               MessageTool.showMessagePanel(null);
            },NpcTipDialog.IRIS);
         }
         else
         {
            name = ItemXMLInfo.getName(itemid);
            switch(name)
            {
               case "侦查眼罩":
                  NpcTipDialog.show(MainManager.actorInfo.nick + "，目前赛尔号的航行遇到了阻碍，需要每个小赛尔行动起来帮忙呢。我已经为大家准备好了功能最全的环境侦查用具——<font color=\'#ff0000\'>侦查眼罩</font>，在黑暗环境中它会给你带来很大的帮助。",function():void
                  {
                     ItemAction.buyItem(itemid,false);
                     TasksManager.setProStatus(TASK_ID,taskid,true,function():void
                     {
                     });
                  },NpcTipDialog.CICI);
                  break;
               case "暗能吸纳仪":
                  NpcTipDialog.show(MainManager.actorInfo.nick + "，那艘飞船上的精灵属性非常特别，肯定是至今为止我们都没有看到过的，这是我特制的精灵束缚工具——<font color=\'#ff0000\'>暗能吸纳仪</font>，带着吧，要给我带精灵样本哦！",function():void
                  {
                     ItemAction.buyItem(itemid,false);
                     TasksManager.setProStatus(TASK_ID,taskid,true,function():void
                     {
                     });
                  },NpcTipDialog.DOCTOR);
            }
         }
      }
   }
}

