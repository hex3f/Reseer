package com.robot.app.popup
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class PetDocPanel extends Sprite
   {
      
      private var _mainUI:Sprite;
      
      private var _okBtn:SimpleButton;
      
      public function PetDocPanel()
      {
         super();
         this._mainUI = UIManager.getSprite("ui_PetDoc_Panel");
         addChild(this._mainUI);
         this._okBtn = this._mainUI["okBtn"];
         this._okBtn.addEventListener(MouseEvent.CLICK,this.onOK);
         LevelManager.appLevel.addChild(this);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
      }
      
      private function onOK(param1:MouseEvent) : void
      {
         LevelManager.openMouseEvent();
         this._okBtn.removeEventListener(MouseEvent.CLICK,this.onOK);
         DisplayUtil.removeForParent(this);
         this._mainUI = null;
         this._okBtn = null;
      }
   }
}

