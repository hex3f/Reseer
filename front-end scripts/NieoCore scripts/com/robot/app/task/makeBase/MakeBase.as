package com.robot.app.task.makeBase
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.event.FitmentEvent;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.manager.FitmentManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class MakeBase
   {
      
      private static var panel:AppModel;
      
      private static var icon:MovieClip;
      
      public static const TASK_ID:uint = 18;
      
      public function MakeBase()
      {
         super();
      }
      
      public static function start() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.UN_ACCEPT)
         {
            TasksManager.accept(TASK_ID,onAccept);
         }
         else if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.complete(TASK_ID,3,function(param1:Boolean):void
            {
               if(param1)
               {
                  SocketConnection.removeCmdListener(CommandID.SET_FITMENT,getStorageList);
                  NpcTipDialog.show("看来已经布置妥当了！接受我的谢礼吧！",null,NpcTipDialog.CICI);
               }
               else
               {
                  NpcTipDialog.show("还没有办完吗？基地对小赛尔们可是很重要的哦！",null,NpcTipDialog.CICI);
               }
            });
         }
      }
      
      private static function getStorageList(param1:*) : void
      {
         var array:Array = null;
         var ar:Array = null;
         var i:int = 0;
         var e:* = param1;
         var info:FitmentInfo = null;
         FitmentManager.removeEventListener(FitmentEvent.USED_LIST,getStorageList);
         array = FitmentManager.getUsedList();
         ar = FitmentManager.getUnUsedList();
         i = 0;
         while(i < array.length)
         {
            info = array[i];
            if(info.id == 500502)
            {
               TasksManager.getProStatus(TASK_ID,0,function(param1:Boolean):void
               {
                  if(!param1)
                  {
                     TasksManager.complete(TASK_ID,0,null);
                  }
               });
            }
            else if(info.id == 500503)
            {
               TasksManager.getProStatus(TASK_ID,2,function(param1:Boolean):void
               {
                  if(!param1)
                  {
                     TasksManager.complete(TASK_ID,2,null);
                  }
               });
            }
            else if(info.id == 500514)
            {
               TasksManager.getProStatus(TASK_ID,1,function(param1:Boolean):void
               {
                  if(!param1)
                  {
                     TasksManager.complete(TASK_ID,1,null);
                  }
               });
            }
            i++;
         }
      }
      
      private static function getUsedlist() : void
      {
         if(MapManager.currentMap.id != MainManager.actorID)
         {
            return;
         }
         FitmentManager.addEventListener(FitmentEvent.USED_LIST,getStorageList);
         FitmentManager.getUsedInfo(MainManager.actorID);
      }
      
      private static function getSomeThing(param1:CommandID) : void
      {
         getUsedlist();
      }
      
      public static function lightIcon() : void
      {
         icon.light_mc.gotoAndPlay(1);
         icon.light_mc.visible = true;
      }
      
      private static function noLightIcon() : void
      {
         icon.light_mc.gotoAndStop(1);
         icon.light_mc.visible = false;
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         noLightIcon();
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("MakeBasePanel"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
         ToolTipManager.remove(icon);
      }
      
      public static function setup() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            showIcon();
         }
      }
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = UIManager.getMovieClip("MakeBaseICON");
            icon.light_mc.mouseChildren = false;
            icon.light_mc.mouseEnabled = false;
            ToolTipManager.add(icon,TasksXMLInfo.getName(TASK_ID));
         }
         TaskIconManager.addIcon(icon);
         icon.addEventListener(MouseEvent.CLICK,clickHandler);
         lightIcon();
      }
      
      public static function onAccept(param1:Boolean) : void
      {
         var str:String = null;
         var npc:String = null;
         var b:Boolean = param1;
         str = null;
         npc = null;
         if(b)
         {
            getUsedlist();
            SocketConnection.addCmdListener(CommandID.SET_FITMENT,getStorageList);
            showIcon();
            str = "我听过不少船员谈起你哦！已经去过你自己的基地了吗？";
            npc = NpcTipDialog.CICI;
            NpcTipDialog.show(str,function():void
            {
               str = "你的基地里还需要添置几样必须的设备：精灵恢复仓、经验分配器和分子转化仪。";
               NpcTipDialog.show(str,function():void
               {
                  str = TextFormatUtil.getRedTxt("精灵恢复仓") + "可以让你精灵包中的所有精灵回复体力与技能。";
                  NpcTipDialog.show(str,function():void
                  {
                     str = TextFormatUtil.getRedTxt("经验分配器") + "可以分配任务获得的积累经验给你选定的精灵。";
                     NpcTipDialog.show(str,function():void
                     {
                        str = TextFormatUtil.getRedTxt("分子转化仪") + "可以将一些高级精灵掉落的精元转化成精灵幼体，转化时间需要24小时。";
                        NpcTipDialog.show(str,function():void
                        {
                           str = "这些基地设备都可以在基地手册里买到，先去把这些设备布置好，然后再来找我。";
                           NpcTipDialog.show(str,null,npc);
                        },npc);
                     },npc);
                  },npc);
               },npc);
            },npc);
         }
      }
   }
}

