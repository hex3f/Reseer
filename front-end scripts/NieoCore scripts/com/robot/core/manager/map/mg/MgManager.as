package com.robot.core.manager.map.mg
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.mode.AppModel;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import org.taomee.ds.HashMap;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MgManager
   {
      
      private static var icon:SimpleButton;
      
      private static var panel:AppModel;
      
      private static var hashMap:HashMap = new HashMap();
      
      public function MgManager()
      {
         super();
      }
      
      public static function addMap() : void
      {
         var _loc1_:uint = MainManager.actorInfo.mapID;
         hashMap.add(_loc1_,_loc1_);
      }
      
      public static function getMaps() : Array
      {
         return hashMap.getValues();
      }
      
      public static function addIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("mg_icon") as SimpleButton;
            icon.addEventListener(MouseEvent.CLICK,clickIcon);
            DisplayUtil.align(icon,null,AlignType.MIDDLE_CENTER);
            icon.x = MainManager.getStageWidth() - icon.width - 10;
            ToolTipManager.add(icon,"NoNo雷达");
         }
         LevelManager.iconLevel.addChild(icon);
      }
      
      public static function delIcon() : void
      {
         DisplayUtil.removeForParent(icon,false);
      }
      
      private static function clickIcon(param1:MouseEvent) : void
      {
         if(!panel)
         {
            panel = ModuleManager.getModule(ClientConfig.getAppModule("MgMap"),"正在打开迷宫地图");
            panel.setup();
         }
         panel.show();
      }
   }
}

