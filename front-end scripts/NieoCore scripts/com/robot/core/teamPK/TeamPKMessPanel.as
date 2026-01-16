package com.robot.core.teamPK
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import flash.display.InteractiveObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class TeamPKMessPanel extends Sprite
   {
      
      private var _infoPanel:InteractiveObject;
      
      private var _ok_btn:SimpleButton;
      
      private var _wait_btn:SimpleButton;
      
      public function TeamPKMessPanel()
      {
         super();
      }
      
      public function setup() : void
      {
         this._infoPanel = TaskIconManager.getIcon("TeamPK1_panel");
         this._ok_btn = this._infoPanel["ok_btn"];
         this._wait_btn = this._infoPanel["wait_btn"];
         this._infoPanel.x = (MainManager.getStageWidth() - this._infoPanel.width) / 2;
         this._infoPanel.y = (MainManager.getStageHeight() - this._infoPanel.height) / 2;
         LevelManager.topLevel.addChild(this._infoPanel);
         this._wait_btn.addEventListener(MouseEvent.CLICK,this.clickWaitHandler);
         this._ok_btn.addEventListener(MouseEvent.CLICK,this.clickOKHandler);
      }
      
      private function clickOKHandler(param1:MouseEvent) : void
      {
         TeamPKManager.joinPK();
         TeamPKManager.removeIcon();
         this.destroy();
      }
      
      private function clickWaitHandler(param1:MouseEvent) : void
      {
         this.destroy();
      }
      
      public function destroy() : void
      {
         if(Boolean(this._wait_btn))
         {
            this._wait_btn.removeEventListener(MouseEvent.CLICK,this.clickWaitHandler);
            this._ok_btn.removeEventListener(MouseEvent.CLICK,this.clickOKHandler);
            LevelManager.topLevel.removeChild(this._infoPanel);
            this._wait_btn = null;
            this._ok_btn = null;
            this._infoPanel = null;
         }
      }
   }
}

