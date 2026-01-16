package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.events.MouseEvent;
   
   public class MapProcess_438 extends BaseMapProcess
   {
      
      public function MapProcess_438()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.addTask534Btn();
         conLevel["fly"].visible = false;
         conLevel["revivePet"].visible = false;
         conLevel["revive"].visible = false;
         conLevel["pet"].visible = false;
         conLevel["petHealth"].visible = false;
         conLevel["stone"].visible = false;
      }
      
      private function addTask534Btn() : void
      {
         conLevel["task534Btn"].visible = true;
         conLevel["task534Btn"].addEventListener(MouseEvent.CLICK,this.onTask534BtnClick);
      }
      
      private function onTask534BtnClick(param1:MouseEvent) : void
      {
         FightInviteManager.fightWithBoss("墨杜萨");
      }
      
      override public function destroy() : void
      {
         conLevel["task534Btn"].removeEventListener(MouseEvent.CLICK,this.onTask534BtnClick);
      }
   }
}

