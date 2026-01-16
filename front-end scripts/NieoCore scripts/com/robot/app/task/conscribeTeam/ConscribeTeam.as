package com.robot.app.task.conscribeTeam
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class ConscribeTeam
   {
      
      private static var icon:MovieClip;
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 19;
      
      private static var isSayB:Boolean = false;
      
      public function ConscribeTeam()
      {
         super();
      }
      
      public static function start() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            panDuan();
            showIcon();
         }
      }
      
      private static function panDuan() : void
      {
         hasFileTool();
      }
      
      private static function sayW() : void
      {
         TasksManager.complete(TASK_ID,2,function(param1:Boolean):void
         {
            var _loc2_:String = null;
            if(param1)
            {
               _loc2_ = "干得漂亮！恭喜你正式加入SPT先锋队,这些奖励是你应得的。";
               NpcTipDialog.show(_loc2_,null,NpcTipDialog.CICI);
            }
            else
            {
               _loc2_ = "还没有办完吗？加入SPT先锋队可是很光荣的哦！";
               NpcTipDialog.show(_loc2_,null,NpcTipDialog.CICI);
            }
         });
      }
      
      private static function hasKillM() : void
      {
         var str1:String = null;
         if(TasksManager.getTaskStatus(301) == 3)
         {
            TasksManager.getProStatus(TASK_ID,1,function(param1:Boolean):void
            {
               var b:Boolean = param1;
               if(!b)
               {
                  TasksManager.complete(TASK_ID,1,function(param1:Boolean):void
                  {
                     if(isSayB)
                     {
                        sayW();
                     }
                  });
               }
               else if(isSayB)
               {
                  sayW();
               }
            });
         }
         else if(isSayB)
         {
            str1 = "还没有办完吗？加入SPT先锋队可是很光荣的哦！";
            NpcTipDialog.show(str1,null,NpcTipDialog.CICI);
         }
      }
      
      private static function onAccept(param1:Boolean) : void
      {
         var str:String = null;
         var npc:String = null;
         var b:Boolean = param1;
         str = null;
         npc = null;
         if(b)
         {
            npc = NpcTipDialog.CICI;
            showIcon();
            isSayB = false;
            panDuan();
            str = "赛尔先锋队SPT是我们赛尔号上的一个特殊组织，每一个有决心完成赛尔号太空任务的船员都有机会加入先锋队。";
            NpcTipDialog.show(str,function():void
            {
               str = "想加入先锋队的话你需要完成一个考验，打败在克洛斯星肆虐的蘑菇怪。";
               NpcTipDialog.show(str,function():void
               {
                  str = "蘑菇怪自从被艾里逊的液态氮冻伤后就在" + TextFormatUtil.getRedTxt("克洛斯星深处") + "发狂到处破坏，先锋队需要像你这样的精英赛尔去那里收复它。";
                  NpcTipDialog.show(str,function():void
                  {
                     str = "要对付它必须要先使用火焰喷射器使他安静下来，火焰喷射器可以在机械室里通过氢氧燃烧实验获得。在它做出更大的破坏前快点去打败它吧。";
                     NpcTipDialog.show(str,null,npc);
                  },npc);
               },npc);
            },npc);
         }
      }
      
      private static function hasFileTool() : void
      {
         ItemManager.addEventListener(ItemEvent.CLOTH_LIST,hasFile);
         ItemManager.getCloth();
      }
      
      private static function hasFile(param1:ItemEvent) : void
      {
         var _loc2_:String = null;
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,hasFile);
         var _loc3_:Number = 100044;
         var _loc4_:Array = ItemManager.getClothIDs();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            if(_loc4_[_loc5_] == 100044)
            {
               TasksManager.complete(TASK_ID,0);
               hasKillM();
               return;
            }
            _loc5_++;
         }
         if(isSayB)
         {
            _loc2_ = "还没有办完吗？加入SPT先锋队可是很光荣的哦！";
            NpcTipDialog.show(_loc2_,null,NpcTipDialog.CICI);
         }
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
            icon = UIManager.getMovieClip("ConscribeTeamICON");
            icon.light_mc.mouseChildren = false;
            icon.light_mc.mouseEnabled = false;
            ToolTipManager.add(icon,TasksXMLInfo.getName(TASK_ID));
         }
         TaskIconManager.addIcon(icon);
         icon.addEventListener(MouseEvent.CLICK,clickHandler);
         lightIcon();
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
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
         ToolTipManager.remove(icon);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         noLightIcon();
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("ConscribeTeamPanel"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

