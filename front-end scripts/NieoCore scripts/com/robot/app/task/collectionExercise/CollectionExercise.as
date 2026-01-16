package com.robot.app.task.collectionExercise
{
   import com.robot.app.buyItem.ItemAction;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class CollectionExercise
   {
      
      private static var icon:MovieClip;
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 17;
      
      public function CollectionExercise()
      {
         super();
      }
      
      public static function setup() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            showIcon();
            onAccept(true);
         }
      }
      
      public static function start() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.UN_ACCEPT)
         {
            TasksManager.accept(TASK_ID,onAccept);
         }
         else if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            isGetRes();
         }
      }
      
      private static function isGetRes() : void
      {
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,getCollection);
         ItemManager.getCollection();
      }
      
      private static function getCollection(param1:ItemEvent) : void
      {
         var e:ItemEvent = param1;
         var j:int = 0;
         var str:String = null;
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,getCollection);
         if(Boolean(ItemManager.getCollectionInfo(400001)))
         {
            j = int(ItemManager.getCollectionInfo(400001).itemNum);
            if(j >= 10)
            {
               str = "那么快就采集完了吗？嗯，就是我要的矿石。干得好，感谢你为赛尔号做出的贡献！";
               NpcTipDialog.show(str,function():void
               {
                  TasksManager.complete(TASK_ID,0);
               },NpcTipDialog.CICI);
            }
            else
            {
               str = "还没有采集到我要的矿石吗？细心些，找找看哪些星球上有黄晶矿石，记得要带上钻头啊！";
               NpcTipDialog.show(str,null,NpcTipDialog.CICI);
            }
         }
         else
         {
            str = "还没有采集到我要的矿石吗？细心些，找找看哪些星球上有黄晶矿石，记得要带上钻头啊！";
            NpcTipDialog.show(str,null,NpcTipDialog.CICI);
         }
      }
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = UIManager.getMovieClip("CollectionExercisICON");
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
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         noLightIcon();
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("CollectionExercisPanel"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
         ToolTipManager.remove(icon);
      }
      
      public static function onAccept(param1:Boolean) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         getTool();
      }
      
      public static function getTool() : void
      {
         ItemManager.addEventListener(ItemEvent.CLOTH_LIST,onClothList);
         ItemManager.getCloth();
      }
      
      private static function onClothList(param1:ItemEvent) : void
      {
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,onClothList);
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Number = 100014;
         var _loc5_:Number = 100015;
         var _loc6_:Array = ItemManager.getClothIDs();
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_.length)
         {
            if(_loc6_[_loc7_] == _loc4_)
            {
               _loc2_ = true;
            }
            if(_loc6_[_loc7_] == _loc5_)
            {
               _loc3_ = true;
            }
            _loc7_++;
         }
         if(!_loc2_)
         {
            ItemAction.buyItem(_loc4_,false);
         }
         if(!_loc3_)
         {
            ItemAction.buyItem(_loc5_,false);
         }
      }
   }
}

