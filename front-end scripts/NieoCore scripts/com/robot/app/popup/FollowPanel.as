package com.robot.app.popup
{
   import com.robot.core.info.UserInfo;
   import org.taomee.utils.DisplayUtil;
   
   public class FollowPanel
   {
      
      private static var _instance:FollowPanelImpl;
      
      public function FollowPanel()
      {
         super();
      }
      
      private static function get instance() : FollowPanelImpl
      {
         if(_instance == null)
         {
            _instance = new FollowPanelImpl();
         }
         return _instance;
      }
      
      public static function show(param1:UserInfo) : void
      {
         if(DisplayUtil.hasParent(instance))
         {
            instance.destroy();
         }
         else
         {
            instance.show(param1);
         }
      }
   }
}

import com.robot.core.CommandID;
import com.robot.core.info.UserInfo;
import com.robot.core.manager.LevelManager;
import com.robot.core.manager.MainManager;
import com.robot.core.manager.MapManager;
import com.robot.core.manager.UIManager;
import com.robot.core.manager.map.config.MapConfig;
import com.robot.core.net.SocketConnection;
import com.robot.core.ui.alert.Alarm;
import com.robot.core.utils.TextFormatUtil;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.text.TextField;
import org.taomee.manager.ToolTipManager;
import org.taomee.utils.AlignType;
import org.taomee.utils.DisplayUtil;

class FollowPanelImpl extends Sprite
{
   
   private var _info:UserInfo;
   
   private var _mainUI:Sprite;
   
   private var _txt:TextField;
   
   private var _followBtn:SimpleButton;
   
   private var _inviteBtn:SimpleButton;
   
   private var _dragBtn:SimpleButton;
   
   private var _closeBtn:SimpleButton;
   
   public function FollowPanelImpl()
   {
      super();
      this._mainUI = UIManager.getSprite("Follow_Panel");
      this._followBtn = this._mainUI["outBtn"];
      this._inviteBtn = this._mainUI["inBtn"];
      this._dragBtn = this._mainUI["dragBtn"];
      this._txt = this._mainUI["txt"];
      this._closeBtn = this._mainUI["closeBtn"];
      addChild(this._mainUI);
   }
   
   public function show(param1:UserInfo) : void
   {
      this._info = param1;
      var _loc2_:String = "";
      if(this._info.mapID > MapManager.ID_MAX)
      {
         _loc2_ = this._info.nick + "的基地";
      }
      else
      {
         _loc2_ = MapConfig.getName(this._info.mapID);
      }
      this._txt.htmlText = "你的好友" + this._info.nick + "(" + this._info.userID + ")目前正在" + TextFormatUtil.getRedTxt(_loc2_) + "上";
      LevelManager.appLevel.addChild(this);
      DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
      this._followBtn.addEventListener(MouseEvent.CLICK,this.onFollow);
      this._inviteBtn.addEventListener(MouseEvent.CLICK,this.onInvite);
      this._dragBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
      this._dragBtn.addEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
      this._closeBtn.addEventListener(MouseEvent.CLICK,this.onClose);
      ToolTipManager.add(this._followBtn,"前往那里");
      ToolTipManager.add(this._inviteBtn,"邀请过来");
   }
   
   public function destroy() : void
   {
      this._followBtn.removeEventListener(MouseEvent.CLICK,this.onFollow);
      this._inviteBtn.removeEventListener(MouseEvent.CLICK,this.onInvite);
      this._dragBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
      this._dragBtn.removeEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
      this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onClose);
      ToolTipManager.remove(this._followBtn);
      ToolTipManager.remove(this._inviteBtn);
      DisplayUtil.removeForParent(this);
   }
   
   private function onDragDown(param1:MouseEvent) : void
   {
      startDrag();
   }
   
   private function onDragUp(param1:MouseEvent) : void
   {
      stopDrag();
   }
   
   private function onClose(param1:MouseEvent) : void
   {
      this.destroy();
   }
   
   private function onFollow(param1:MouseEvent) : void
   {
      if(this._info.mapID == 104)
      {
         Alarm.show("你的好友正在一个神秘的地方哦，你不可以过去！");
         this.destroy();
         return;
      }
      MapManager.changeMap(this._info.mapID);
   }
   
   private function onInvite(param1:MouseEvent) : void
   {
      if(this._info.userID > 50000 && this._info.userID < 2000000000)
      {
         if(MainManager.actorInfo.mapID != 104)
         {
            SocketConnection.send(CommandID.REQUEST_OUT,this._info.userID);
         }
         else
         {
            Alarm.show("这里是神秘领奖处,你不可以邀请好友来这里哦!");
         }
      }
      this.destroy();
   }
}
