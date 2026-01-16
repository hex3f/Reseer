package com.robot.app.protectSys
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import flash.events.Event;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class KillPluginSys
   {
      
      private static var panel:KillPluginPanel;
      
      private static var wrongNum:uint = 0;
      
      public function KillPluginSys()
      {
         super();
      }
      
      public static function start() : void
      {
         show();
      }
      
      private static function show() : void
      {
         panel = new KillPluginPanel();
         DisplayUtil.align(panel,null,AlignType.MIDDLE_CENTER);
         MainManager.getStage().addChild(panel);
         panel.addEventListener(KillPluginPanel.RIGHT,onRightHandler);
         panel.addEventListener(KillPluginPanel.WRONG,onWrongHandler);
         LevelManager.closeMouseEvent();
      }
      
      private static function onWrongHandler(param1:Event) : void
      {
         ++wrongNum;
         panel.destroy();
         panel.removeEventListener(KillPluginPanel.RIGHT,onRightHandler);
         panel.removeEventListener(KillPluginPanel.WRONG,onWrongHandler);
         panel = null;
         if(wrongNum >= 2)
         {
            MapManager.changeMap(1);
            LevelManager.openMouseEvent();
            wrongNum = 0;
         }
         else
         {
            show();
         }
      }
      
      private static function onRightHandler(param1:Event) : void
      {
         wrongNum = 0;
         panel.destroy();
         panel.removeEventListener(KillPluginPanel.RIGHT,onRightHandler);
         panel.removeEventListener(KillPluginPanel.WRONG,onWrongHandler);
         panel = null;
         LevelManager.openMouseEvent();
      }
   }
}

