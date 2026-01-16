package com.robot.app.im.talk
{
   import com.robot.app.emotion.EmotionListItem;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.manager.PopUpManager;
   import org.taomee.utils.DisplayUtil;
   
   public class TEmotionPanel extends Sprite
   {
      
      private var _panel:Sprite;
      
      private var _userID:uint;
      
      public function TEmotionPanel(param1:uint)
      {
         var _loc2_:EmotionListItem = null;
         super();
         this._userID = param1;
         this._panel = UIManager.getSprite("Panel_Background_4");
         this._panel.mouseChildren = false;
         this._panel.mouseEnabled = false;
         this._panel.cacheAsBitmap = true;
         this._panel.width = 299;
         this._panel.height = 118;
         this._panel.alpha = 0.6;
         addChild(this._panel);
         var _loc3_:int = 0;
         while(_loc3_ < 23)
         {
            _loc2_ = new EmotionListItem(_loc3_);
            _loc2_.x = 6 + (_loc2_.width + 2) * int(_loc3_ / 3);
            _loc2_.y = 6 + (_loc2_.height + 2) * int(_loc3_ % 3);
            addChild(_loc2_);
            _loc2_.addEventListener(MouseEvent.CLICK,this.onItemClick);
            _loc3_++;
         }
      }
      
      public function show(param1:DisplayObject) : void
      {
         PopUpManager.showForDisplayObject(this,param1,PopUpManager.TOP_RIGHT,true,new Point(-30,0));
      }
      
      public function hide() : void
      {
         DisplayUtil.removeForParent(this);
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:EmotionListItem = param1.currentTarget as EmotionListItem;
         MainManager.actorModel.chatAction("#" + _loc2_.id,this._userID);
         this.hide();
      }
   }
}

