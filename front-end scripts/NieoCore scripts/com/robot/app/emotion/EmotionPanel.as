package com.robot.app.emotion
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.manager.PopUpManager;
   import org.taomee.utils.DisplayUtil;
   
   public class EmotionPanel extends Sprite
   {
      
      private var _panel:Sprite;
      
      public function EmotionPanel()
      {
         var _loc1_:int = 0;
         var _loc2_:EmotionListItem = null;
         super();
         this._panel = UIManager.getSprite("Panel_Background_4");
         this._panel.mouseChildren = false;
         this._panel.mouseEnabled = false;
         this._panel.cacheAsBitmap = true;
         this._panel.width = 152;
         this._panel.height = 224;
         this._panel.alpha = 0.6;
         addChild(this._panel);
         _loc1_ = 0;
         while(_loc1_ < 23)
         {
            _loc2_ = new EmotionListItem(_loc1_);
            _loc2_.x = 6 + (_loc2_.width + 2) * int(_loc1_ % 4);
            _loc2_.y = 4 + (_loc2_.height + 2) * int(_loc1_ / 4);
            addChild(_loc2_);
            _loc2_.addEventListener(MouseEvent.CLICK,this.onItemClick);
            _loc1_++;
         }
      }
      
      public function show(param1:DisplayObject) : void
      {
         PopUpManager.showForDisplayObject(this,param1,PopUpManager.TOP_LEFT,true,new Point((width + param1.width) / 2,0));
      }
      
      public function hide() : void
      {
         DisplayUtil.removeForParent(this);
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:EmotionListItem = param1.currentTarget as EmotionListItem;
         MainManager.actorModel.chatAction("$" + _loc2_.id);
         this.hide();
      }
   }
}

