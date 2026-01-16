package com.robot.app.task.doctorTrain
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   
   public class DoctorTrainController
   {
      
      private static var icon:SimpleButton;
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 16;
      
      public function DoctorTrainController()
      {
         super();
      }
      
      public static function setup() : void
      {
      }
      
      private static function onCatchPet(param1:DynamicEvent) : void
      {
      }
      
      public static function start() : void
      {
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
            str = "看来你已经学会如何用精灵对战了。好吧，该是时候让你试试身手了。";
            NpcTipDialog.show(str,function():void
            {
               str = "我已经给了你一些" + TextFormatUtil.getRedTxt("精灵胶囊") + "。使用胶囊就可以捕获精灵，在精灵虚弱时能更容易捕获成功。";
               NpcTipDialog.show(str,function():void
               {
                  str = "在" + TextFormatUtil.getRedTxt("克洛斯星") + "的" + TextFormatUtil.getRedTxt("皮皮、海洋星") + "的" + TextFormatUtil.getRedTxt("贝尔、云霄星") + "的" + TextFormatUtil.getRedTxt("毛毛") + "中任意捕获一只野生精灵后来我这里领取奖励。";
                  NpcTipDialog.show(str,function():void
                  {
                     clickHandler(null);
                     checkPet();
                  },npc);
               },npc);
            },npc);
            showIcon();
         }
      }
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = UIManager.getButton("doctorTrainIcon");
            ToolTipManager.add(icon,TasksXMLInfo.getName(TASK_ID));
         }
         TaskIconManager.addIcon(icon);
         icon.addEventListener(MouseEvent.CLICK,clickHandler);
      }
      
      private static function checkPet() : void
      {
         if(getPetBoolean())
         {
            lightIcon();
         }
      }
      
      public static function lightIcon() : void
      {
         icon.filters = [new GlowFilter(16776960,1,8,8)];
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
         ToolTipManager.remove(icon);
         EventManager.removeEventListener(PetFightEvent.CATCH_SUCCESS,onCatchPet);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         icon.filters = [];
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("DoctorTrainTask"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function getPetBoolean() : Boolean
      {
         var _loc1_:PetInfo = null;
         var _loc2_:Boolean = false;
         var _loc3_:Array = [10,11,12,22,23,24,30,31,32];
         for each(_loc1_ in PetManager.infos)
         {
            if(_loc3_.indexOf(_loc1_.id) != -1)
            {
               _loc2_ = true;
               break;
            }
         }
         return _loc2_;
      }
   }
}

