package com.robot.app.mapProcess
{
   import com.robot.core.manager.map.config.BaseMapProcess;
   import org.taomee.manager.*;
   
   public class MapProcess_104 extends BaseMapProcess
   {
      
      public function MapProcess_104()
      {
         super();
      }
      
      override protected function init() : void
      {
         ToolTipManager.add(conLevel["giftMc"],"神秘领奖处");
      }
      
      override public function destroy() : void
      {
         ToolTipManager.remove(conLevel["giftMc"]);
      }
      
      public function onGiftHandler() : void
      {
         conLevel["giftMc"].gotoAndStop(2);
      }
   }
}

